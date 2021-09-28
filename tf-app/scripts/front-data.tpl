#!/bin/bash

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

# Create a new user and group to run the app
groupadd -r movie-app
useradd -m -d /app movie-app -r -g movie-app

# Prevent logginng in
usermod -L movie-app

# Getting repo
if ! [[ -d /app/ui ]]; then
    sudo -H -u movie-app bash -c "git clone https://github.com/bortizf/movie-analyst-ui.git /app/ui"
else
    echo "The repo already exists"
fi

sudo -H -u movie-app bash -c "npm install --prefix /app/ui"

sudo -H -u movie-app bash -c "cat > /app/.env << EOF
#!/bin/bash
export BACK_HOST=${ lb-int-dns }
EOF"

if [ $(pidof node server | wc -l) -eq 0 ]; then
    sudo -H -u movie-app bash -c "source /app/.env; node /app/ui/server.js > /app/app-out.log  2> /app/app-err.log &"
    sudo -H -u movie-app bash -c "disown -h"
else
    echo "App is already running."
fi