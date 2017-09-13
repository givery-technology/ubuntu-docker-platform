apt-get remove -y docker docker-engine docker.io
apt-get update -y
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Verify 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88
# apt-key fingerprint 0EBFCD88

add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update -y
apt-get install -y docker-ce=17.06.2~ce-0~ubuntu

# Add user ubuntu to the docker group
gpasswd -a ubuntu docker

service docker restart

# Print docker daemon info
docker info
