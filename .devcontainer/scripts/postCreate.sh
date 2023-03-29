#!/bin/bash

# update apt packages
sudo apt-get -qq -y update --no-install-recommends &&
	sudo apt-get -qq -y install --no-install-recommends bash-completion unixodbc-dev &&
	sudo apt-get -qq -y upgrade --no-install-recommends &&
	sudo apt-get -qq autoremove -y &&
	sudo apt-get -qq clean -y

# update pip
python -m pip install --no-cache-dir --upgrade pip

# install pdm dependencies
pdm config strategy.update eager

# git config
git config pull.rebase false
