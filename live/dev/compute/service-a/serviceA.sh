#!/bin/bash
sudo apt update -y
sudo apt upgrade -y
sudo apt install openjdk-17-jdk -y
sudo apt install maven -y
sudo apt install git -y
sudo mkdir -p /home/ubuntu/app
cd /home/ubuntu/app
sudo git clone https://github.com/shantannuu/serviceA.git
cd serviceA/
sudo chown -R ubuntu:ubuntu /home/ubuntu/app
mvn clean install
java -jar target/*.jar