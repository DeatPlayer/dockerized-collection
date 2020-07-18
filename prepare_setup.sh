#!/usr/bin/env bash

#
#   Before using this script, make sure that you have copied the example file .env.sample to .env and adapted it to your needs!
#

if [ -e .env ]; then
    source .env
else 
    echo "The example file .env.sample has been copied to .env, make sure that all appropriate settings are set and run this script again afterwards."
    cp .env.sample .env
    exit 1
fi

echo "Creating docker network.."
docker network create $NETWORK $NETWORK_OPTIONS

echo "Downloading the latest nginx.tmpl file.."
curl https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl > nginx.tmpl

echo "Pulling the docker images.."
docker-compose pull

if [ ! -z ${USE_NGINX_CONF_FILES+X} ] && [ "$USE_NGINX_CONF_FILES" = true ]; then
    echo "Copy the special configurations to the nginx conf folder.."
    mkdir -p $NGINX_FILES_PATH/conf.d
    cp -R ./conf.d/* $NGINX_FILES_PATH/conf.d

    if [ $? -ne 0 ]; then
        sudo cp -R ./conf.d/* $NGINX_FILES_PATH/conf.d
    fi

    if [ $? -ne 0 ]; then
        echo "###################################################"
        echo "An error occurred while copying the configurations."
        echo "The standard configuration is used."
        echo "###################################################"
    fi


echo "Starting proxy.."
docker-compose up -d