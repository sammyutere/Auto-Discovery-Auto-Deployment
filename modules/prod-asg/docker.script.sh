#!/bin/bash
# update and upgrade yum packages, install yum-utils, config manager and docker
sudo yum update -y
sudo yum upgrade -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y

# This configuration file will allow docker to communicate with nexus repo over HTTP connection
sudo cat <<EOT > /etc/docker/daemon.json
{
  "insecure-registries" : ["${nexus-ip}:8085"]
}
EOT

# Enable and start docker engine and assign ec2-user to docker group
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install New Relic
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash
sudo NEW_RELIC_API_KEY="${newrelic-license-key}" NEW_RELIC_ACCOUNT_ID="${acct-id}" NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -y

# Docker container management script
# Pull the latest image from Nexus registry
sudo docker login -u ${nexus-username} -p ${nexus-password} ${nexus-ip}:8085
sudo docker pull ${nexus-ip}:8085/${repository}/${image-name}:latest

# Check if the container is running, stop and remove it if necessary
if [ "$(sudo docker ps -q -f name=${container-name})" ]; then
    sudo docker stop ${container-name}
    sudo docker rm ${container-name}
fi

# Run the container with the latest image
sudo docker run -d --name ${container-name} -p ${host-port}:${container-port} ${nexus-ip}:8085/${repository}/${image-name}:latest

# Set up a cron job to check for updates every day at midnight
(crontab -l 2>/dev/null; echo "0 0 * * * /usr/local/bin/docker_update.sh") | crontab -

# Create the docker_update.sh script
sudo cat <<'EOF' > /usr/local/bin/docker_update.sh
#!/bin/bash
# Pull the latest image
sudo docker login -u ${nexus-username} -p ${nexus-password} ${nexus-ip}:8085
sudo docker pull ${nexus-ip}:8085/${repository}/${image-name}:latest

# Check if the container is running, stop and remove it if necessary
if [ "$(sudo docker ps -q -f name=${container-name})" ]; then
    sudo docker stop ${container-name}
    sudo docker rm ${container-name}
fi

# Run the container with the latest image
sudo docker run -d --name ${container-name} -p ${host-port}:${container-port} ${nexus-ip}:8085/${repository}/${image-name}:latest
EOF

# Make the docker_update.sh script executable
sudo chmod +x /usr/local/bin/docker_update.sh
