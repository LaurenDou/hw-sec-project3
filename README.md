# hw-sec-project3

### Create required VM with TDX enabled with c3-standard-4
```bash
gcloud compute instances create fithealthdb \
    --project=hardwaresecurity-455019 \
    --zone=us-central1-c \
    --machine-type=c3-standard-4 \
    --confidential-compute-type=TDX \
    --maintenance-policy=TERMINATE \
    --provisioning-model=STANDARD \
    --service-account=691049217200-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,\
https://www.googleapis.com/auth/logging.write,\
https://www.googleapis.com/auth/monitoring.write,\
https://www.googleapis.com/auth/service.management.readonly,\
https://www.googleapis.com/auth/servicecontrol,\
https://www.googleapis.com/auth/trace.append \
    --tags=https-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=fithealthdb,\
image=projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts,\
mode=rw,size=20,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any
```
### Check TDX
```bash
sudo dmesg | grep -i tdx
```

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

