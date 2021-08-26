#!/bin/bash
yum update -y
yum install httpd -y
systemctl start httpd.service
systemctl enable httpd
sudo echo "<html><body><h1>Hello from Webserver at instance id `curl http://169.254.169.254/latest/meta-data/instance-id` </h1></body></html>" > /var/www/html/index.html
