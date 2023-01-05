#!/bin/bash

# update apt packages
sudo apt-get -qq -y update --no-install-recommends &&
	sudo apt-get -qq -y upgrade --no-install-recommends &&
	sudo apt-get -qq autoremove -y &&
	sudo apt-get -qq clean -y

# update trunk
trunk upgrade -y --no-progress
