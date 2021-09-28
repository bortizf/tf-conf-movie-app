#!/bin/bash

sudo apt update -y
sudo apt install ansible -y

cat > /tmp/main.yml << EOF
- hosts: localhost
  become: yes
  
  vars:
    nodejs_version: "14.x"
    url_repo: "https://github.com/bortizf/movie-analyst-ui.git"
    app_dir: "/app/movie-ui"

  tasks:
      
    - name: Update apt cache if repo was added
      apt:
        update_cache: yes
        force_apt_get: yes
        cache_valid_time: 3600

    - name: Ensure Git CVS is installed
      apt:
        name: git
        state: latest

    - name: Ensure npm & nodejs are installed
      apt:
        name: npm
        state: present

    - name: Ensure pm2 is installed
      npm:
        name: pm2
        global: yes
    
    - name: Ensure group "movie-app" exists
      group:
        name: movie-app
        state: present
    
    - name: Ensure a non-root user exists to execute the app
      user:
        name: movie-app
        comment: user to execute the node app
        group: movie-app
        home: /app/
        password_lock: yes
        shell: /bin/bash
        state: present
    
    - name: Getting the app repo
      git:
        repo: "{{ url_repo }}"
        dest: "{{ app_dir }}"
      become_user: movie-app

    - name: Installing app modules
      npm:
        path: "{{ app_dir }}"
        state: present
      become_user: movie-app
    
    - name: Executing the applicatioin
      shell: |
        cat > .env << EOF
        #!/bin/bash
        export BACK_HOST=${ lb-int-dns }
        EOF
        source .env
        pm2 -f start server.js 
      args:
        executable: /bin/bash
        chdir: "{{ app_dir }}"
      become_user: movie-app
EOF

# Execute provisioning
sudo ansible-playbook /tmp/main.yml