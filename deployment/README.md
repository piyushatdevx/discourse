# FanTribe Discourse Deployment Guide

This directory contains all files needed to deploy FanTribe to production.

## Quick Start

### 1. AWS Setup (Manual Steps)

#### Create EC2 Instance
- **Type**: t3.medium (minimum)
- **OS**: Ubuntu 22.04 LTS
- **Storage**: 50GB SSD
- **Security Group**: Open ports 22, 80, 443

#### Create S3 Buckets
```
fantribe-uploads-<unique>  (for media uploads)
fantribe-backups-<unique>  (for backups)
```

#### Set Up AWS SES
1. Verify your domain in SES
2. Request production access
3. Create SMTP credentials

#### Configure DNS
Point your domain to the EC2 Elastic IP.

### 2. Server Setup

SSH into your server and run:
```bash
curl -fsSL https://raw.githubusercontent.com/<your-org>/fantribe-discourse/main/deployment/setup-server.sh | sudo bash
```

Or manually:
```bash
sudo bash deployment/setup-server.sh
```

### 3. Deploy Plugin

From your local machine:
```bash
# Copy the fantribe-theme plugin
scp -r plugins/fantribe-theme ubuntu@<SERVER_IP>:/tmp/
```

### 4. Configure Discourse

1. Copy and edit the configuration template:
```bash
cp deployment/app.yml.template app.yml
# Edit app.yml with your credentials
```

2. Upload to server:
```bash
scp app.yml root@<SERVER_IP>:/var/discourse/containers/
```

### 5. Build and Launch

On the server:
```bash
cd /var/discourse
./launcher rebuild app
```

## Files in This Directory

| File | Purpose |
|------|---------|
| `app.yml.template` | Docker container configuration template |
| `credentials.env.template` | Reference file for all required credentials |
| `setup-server.sh` | Server initialization script |
| `CHECKLIST.md` | Step-by-step deployment checklist |

## Required Credentials

Before deployment, gather:

- [ ] AWS Access Key ID
- [ ] AWS Secret Access Key
- [ ] S3 Bucket names (uploads + backups)
- [ ] SES SMTP username
- [ ] SES SMTP password
- [ ] Domain name
- [ ] Admin email address

## Maintenance Commands

```bash
# View logs
./launcher logs app

# Enter container
./launcher enter app

# Restart
./launcher restart app

# Rebuild (after config changes)
./launcher rebuild app

# Backup
./launcher enter app
discourse backup
exit

# Update Discourse
./launcher rebuild app  # pulls latest image
```

## Troubleshooting

### Email not sending
- Verify domain in SES
- Check SMTP credentials
- Ensure SES is out of sandbox mode

### Uploads failing
- Check S3 bucket permissions
- Verify IAM policy allows s3:* on bucket
- Check CORS settings on bucket

### Site not loading
- Check DNS propagation: `dig your-domain.com`
- Verify SSL: `curl -I https://your-domain.com`
- Check container logs: `./launcher logs app`

### Out of memory
- Increase EC2 instance size
- Or add swap: `fallocate -l 4G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile`
