#!/bin/bash
set -e  # exit on error

cd "$(dirname "$0")"

for f in secret_key.txt ssl/server.key ssl/server.crt; do
    f="../data/${f?}"
    if ! [ -e "${f?}" ]; then
        echo "${f?}" does not exist.
        must_exit=true
    fi
done
if [ "${must_exit}" == "true" ]; then
    echo You must generate a random secret key and SSL key/certificate.
    exit 1
fi

./mount.sh

# for server.py
if ! which docker; then  # if docker is not installed then install it
    curl -sSL https://get.docker.com | sh
fi
sudo apt-get --assume-yes install python2.7 python-flask python-bcrypt python-leveldb authbind
sudo apt-get --assume-yes install python-pip
sudo pip install flask-login

# for monitor.py
sudo apt-get --assume-yes install python-mechanize

sudo service docker start

# if the user grade oven does not exist *or* is not able to use docker
if ! groups gradeoven | grep docker; then
    sudo adduser gradeoven --disabled-password --disabled-login
    sudo adduser gradeoven docker
fi

sudo touch /etc/authbind/byport/443
sudo chown gradeoven:gradeoven /etc/authbind/byport/443
sudo chmod 755 /etc/authbind/byport/443

sudo docker build --build-arg GRADE_OVEN_UID="$(id -u gradeoven)" -t grade_oven/grade_oven -f grade_oven.Dockerfile --rm --memory-swap=-1 .



