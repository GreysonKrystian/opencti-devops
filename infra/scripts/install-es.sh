#!/bin/bash

set -e  

echo "Updating package lists..."
sudo apt-get update

echo "Installing OpenJDK 11..."
sudo apt-get install -y openjdk-11-jdk

echo 'export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"' | sudo tee -a /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
echo "JAVA_HOME is set to $JAVA_HOME"

echo "Adding Elasticsearch repository..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

echo "Updating package lists again..."
sudo apt-get update

echo "Installing Elasticsearch..."
sudo apt-get install -y elasticsearch

echo "Configuring Elasticsearch..."
sudo sed -i '/^#network.host:/c\network.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml
echo "http.host: 0.0.0.0" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo "http.cors.enabled: true" | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo 'http.cors.allow-origin: "*"' | sudo tee -a /etc/elasticsearch/elasticsearch.yml

echo "Enabling and starting Elasticsearch..."
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

echo "Checking Elasticsearch status..."
if systemctl is-active --quiet elasticsearch; then
    echo "Elasticsearch is running successfully."
else
    echo "Elasticsearch failed to start. Check logs using: sudo journalctl -u elasticsearch --no-pager"
    exit 1
fi
