#!/bin/bash
# Provision script

# Create a new user and group to run the app
groupadd -r movie-app
useradd -m -d /app movie-app -r -g movie-app

# Prevent logginng in
usermod -L movie-app

# CREATE DATABASE;
# SQL SCRIPTS DEFINITION
sudo -H -u movie-app bash -c "cat > /app/init.sql << EOF
CREATE DATABASE IF NOT EXISTS moviedb;
COMMIT;
EOF"

sudo -H -u movie-app bash -c "cat > /app/populate.sql << EOF
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
EOF"

sudo apt update -y

install_req () {
    if [ $(apt list --installed | grep -w $1 | wc -l) -eq 0 ]; then
        sudo apt install -y $1
    else
        echo "It's already installed."
    fi
}

# INSTALLING DEPENDENCIES
install_req "git"
install_req "nodejs"
install_req "npm"
install_req "mariadb-client"

# SQL SCRIPTS EXECUTION
sudo -H -u movie-app bash -c "mariadb -h ${db_host} -u admin -padmin_pass < /app/init.sql"
sudo -H -u movie-app bash -c "mariadb -h ${db_host} -u admin -padmin_pass < /app/populate.sql"

# GETTING REPOS
if ! [[ -d /app/api ]]; then
    sudo -H -u movie-app bash -c "git clone https://github.com/bortizf/movie-analyst-api.git /app/api"
else
    echo "The repo already exists"
fi
sudo -H -u movie-app bash -c "npm install --prefix /app/api"

# DATABASE CREDENTIALS
sudo -H -u movie-app bash -c "cat > /app/.env << EOF
#!/bin/bash
export PORT=3000
export DB_USER=admin
export DB_PASS=admin_pass
export DB_NAME=moviedb
export DB_HOST=${db_host}
EOF"

# Check if the app is already running
if [ $(pidof node server | wc -l ) -eq 0 ]; then
    sudo -H -u movie-app bash -c "source /app/.env; node /app/api/server.js > /app/app-out.log 2> /app/app-err.log &"
    sudo -H -u movie-app bash -c "disown -h"
else
    echo "App is already running."
fi