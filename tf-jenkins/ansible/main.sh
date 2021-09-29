#!/bin/bash

sudo apt update -y
sudo apt install ansible -y

cat > /tmp/main.yml << END
- hosts: localhost
  become: yes
  tasks:
    - name: Ensure Jenkins key is installed
      apt_key:
        url: https://pkg.jenkins.io/debian-stable/jenkins.io.key
        state: present
    
    - name: Ensure Jenkins repo is present
      apt_repository:
        repo: deb https://pkg.jenkins.io/debian-stable binary/
        state: present

    - name: Update cache
      apt:
        update_cache: yes
        force_apt_get: yes

    - name: Ensure Java is installed
      apt:
        name: openjdk-11-jdk
        state: present
    
    - name: Ensure Jenkins is installed
      apt:
        name: jenkins
        state: present
      notify:
        - Start jenkins
  
  handlers:
    - name: Start jenkins
      service: 
        name: jenkins
        state: started
END

sudo ansible-playbook /tmp/main.yml