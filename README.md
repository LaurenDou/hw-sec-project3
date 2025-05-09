# hw-sec-project3

### install requirements
```bash
sudo apt update
sudo apt install -y python3 python3-pip sqlite3 git
```

### Docker installation
```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

### Build images
```bash
docker build -t fithealth .
```
### Create Container
```bash
docker run --name fithealth-container -p 5000:5000 fithealth
```

### Docker related commands

```bash
# Check containers
docker ps -a

# Run container
docker start -a fithealth-container

# Stop container
docker stop fithealth-container

# Delete container
docker rm fithealth-container
```

