# hw-sec-project3
### Build images
```bash
docker build -t fithealth .
```

### Docker Run Command
```bash
docker run -it --rm   --device /dev/tpmrm0   --device /dev/tpm0   --mount type=bind,source=/sys/kernel/security,target=/sys/kernel/security   --privileged   --user root   --network host   fithealth
```

### Check TDX
```bash
sudo dmesg | grep -i tdx
```
### Simple Check post and get
```bash
curl -X POST http://localhost:5000/record \
  -H "Content-Type: application/json" \
  -d '{"user_id": "user1", "heart_rate": 72, "blood_pressure": "118/76", "notes": "resting"}'

curl http://localhost:5000/record/user1
```



