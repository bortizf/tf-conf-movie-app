#!/bin/bash

sudo apt update -y
sudo apt install ansible -y

cat > /tmp/main.yml << EOF
- hosts: localhost
  become: yes
  
  vars:
    nodejs_version: "14.x"
    url_repo: "https://github.com/bortizf/movie-analyst-api.git"
    app_dir: "/app/movie-api"

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

    - name: Ensure MariaDB client is installed
      apt:
        name: mariadb-client
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
    
    - name: Creating init SQL script
      shell: |
        cat > /app/init.sql << EOF
        CREATE DATABASE IF NOT EXISTS moviedb;
        COMMIT;
        EOF
      args:
        executable: /bin/bash
      become_user: movie-app
    
    - name: Creating populate SQL script
      shell: |
        cat > /app/populate.sql << EOF
        CREATE TABLE moviedb.movies (
          title varchar(100) NOT NULL,
          release_v2 varchar(20) NOT NULL,
          score INTEGER UNSIGNED NOT NULL,
          reviewer varchar(100) NOT NULL,
          publication varchar(100) NOT NULL
        )
        ENGINE=InnoDB
        DEFAULT CHARSET=latin1
        COLLATE=latin1_swedish_ci;

        -- INSERT 

        INSERT INTO moviedb.movies (title, release_v2, score, reviewer, publication) VALUES('Suicide Squad', '2016', 8, 'Robert Smith', 'The Daily Reviewer');
        INSERT INTO moviedb.movies (title, release_v2, score, reviewer, publication) VALUES('Batman vs. Superma', '2016', 6, 'Chris Harris', 'International Movie Critic');
        INSERT INTO moviedb.movies (title, release_v2, score, reviewer, publication) VALUES('Captain America: Civil War', '2016', 9, 'Janet Garcia', 'MoviesNow');
        INSERT INTO moviedb.movies (title, release_v2, score, reviewer, publication) VALUES('Deadpool', '2016', 9, 'Andrew West', 'MyNextReview');
        INSERT INTO moviedb.movies (title, release_v2, score, reviewer, publication) VALUES('Avengers: Age of Ultron', '2015', 7, 'Mindy Lee', 'Movies n'' Games');
        INSERT INTO moviedb.movies (title, release_v2, score, reviewer, publication) VALUES('Ant-Man', '2015', 8, 'Martin Thomas', 'TheOne');
        INSERT INTO moviedb.movies (title, release_v2, score, reviewer, publication) VALUES('Guardians of the Galaxy', '2014', 10, 'Anthony Miller', 'ComicBookHero.com');


        -- REVIEWERS TABLE

        CREATE TABLE moviedb.reviewers (
          name varchar(100) NOT NULL,
          publication varchar(100) NOT NULL,
          avatar varchar(100) NOT NULL
        )
        ENGINE=InnoDB
        DEFAULT CHARSET=latin1
        COLLATE=latin1_swedish_ci;

        -- INSERT

        INSERT INTO moviedb.reviewers (name, publication, avatar) VALUES('Robert Smith', 'The Daily Reviewer', 'https://s3.amazonaws.com/uifaces/faces/twitter/angelcolberg/128.jpg');
        INSERT INTO moviedb.reviewers (name, publication, avatar) VALUES('Chris Harris', 'International Movie Critic', 'https://s3.amazonaws.com/uifaces/faces/twitter/bungiwan/128.jpg');
        INSERT INTO moviedb.reviewers (name, publication, avatar) VALUES('Janet Garcia', 'MoviesNow', 'https://s3.amazonaws.com/uifaces/faces/twitter/grrr_nl/128.jpg');
        INSERT INTO moviedb.reviewers (name, publication, avatar) VALUES('Andrew West', 'MyNextReview', 'https://s3.amazonaws.com/uifaces/faces/twitter/d00maz/128.jpg');
        INSERT INTO moviedb.reviewers (name, publication, avatar) VALUES('Mindy Lee', 'Movies n'' Games', 'https://s3.amazonaws.com/uifaces/faces/twitter/laurengray/128.jpg');
        INSERT INTO moviedb.reviewers (name, publication, avatar) VALUES('Martin Thomas', 'TheOne', 'https://s3.amazonaws.com/uifaces/faces/twitter/karsh/128.jpg');
        INSERT INTO moviedb.reviewers (name, publication, avatar) VALUES('Anthony Miller', 'ComicBookHero.com', 'https://s3.amazonaws.com/uifaces/faces/twitter/9lessons/128.jpg');


        -- PUBLICATIONS TABLE

        CREATE TABLE moviedb.publications (
          name varchar(100) NOT NULL,
          avatar varchar(100) NOT NULL
        )
        ENGINE=InnoDB
        DEFAULT CHARSET=latin1
        COLLATE=latin1_swedish_ci;

        -- INSERT

        INSERT INTO moviedb.publications (name, avatar) VALUES('The Daily Reviewer', 'glyphicon-eye-open');
        INSERT INTO moviedb.publications (name, avatar) VALUES('International Movie Criti', 'glyphicon-fire');
        INSERT INTO moviedb.publications (name, avatar) VALUES('MoviesNow', 'glyphicon-time');
        INSERT INTO moviedb.publications (name, avatar) VALUES('MyNextReview', 'glyphicon-record');
        INSERT INTO moviedb.publications (name, avatar) VALUES('Movies n'' Games', 'glyphicon-heart-empty');
        INSERT INTO moviedb.publications (name, avatar) VALUES('TheOne', 'glyphicon-globe');
        INSERT INTO moviedb.publications (name, avatar) VALUES('ComicBookHero.com', 'glyphicon-flash');

        -- PENDING TABLE

        CREATE TABLE moviedb.pending (
          title varchar(100) NOT NULL,
          release_v2 varchar(100) NOT NULL,
          score INTEGER NOT NULL,
          reviewer varchar(100) NOT NULL,
          publication varchar(100) NOT NULL
        )
        ENGINE=InnoDB
        DEFAULT CHARSET=latin1
        COLLATE=latin1_swedish_ci;

        -- INSERT

        INSERT INTO moviedb.pending (title, release_v2, score, reviewer, publication) VALUES('Superman: Homecoming', '2017', 10, 'Chris Harris', 'International Movie Critic');
        INSERT INTO moviedb.pending (title, release_v2, score, reviewer, publication) VALUES('Wonder Woman', '2017', 8, 'Martin Thomas', 'TheOne');
        INSERT INTO moviedb.pending (title, release_v2, score, reviewer, publication) VALUES('Doctor Strange', '2016', 7, 'Anthony Miller', 'ComicBookHero.com');

        COMMIT;
        EOF
      
      args:
        executable: /bin/bash
      become_user: movie-app
    
    - name: Executing SQL scripts
      shell: |
        mariadb -h ${ db_host } -u admin -padmin_pass < /app/init.sql
        mariadb -h ${ db_host } -u admin -padmin_pass < /app/populate.sql
      args:
        executable: /bin/bash
      become_user: movie-app
      ignore_errors: yes
    
    - name: Executing the application
      shell: |
        cat > .env << EOF
        #!/bin/bash
        export PORT=3000
        export DB_USER=admin
        export DB_PASS=admin_pass
        export DB_NAME=moviedb
        export DB_HOST=${ db_host }
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