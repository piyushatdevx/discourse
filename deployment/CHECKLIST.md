# FanTribe Deployment Checklist

Use this checklist to ensure nothing is missed during deployment.

## Pre-Deployment

### AWS Account Setup
- [ ] AWS account created with billing enabled
- [ ] IAM user created with programmatic access
- [ ] Access Key ID and Secret Access Key saved securely

### Domain
- [ ] Domain purchased
- [ ] Access to DNS management

### S3 Buckets
- [ ] Upload bucket created: `fantribe-uploads-_____`
- [ ] Backup bucket created: `fantribe-backups-_____`
- [ ] Block Public Access: **OFF** (Discourse manages ACLs)
- [ ] IAM policy attached allowing S3 access to buckets

### AWS SES (Email)
- [ ] Domain verified in SES
- [ ] Email identity verified
- [ ] Production access requested and approved
- [ ] SMTP credentials generated
- [ ] SMTP endpoint noted (e.g., `email-smtp.us-east-1.amazonaws.com`)

### EC2 Instance
- [ ] Instance created (t3.medium minimum)
- [ ] Ubuntu 22.04 LTS selected
- [ ] 50GB+ SSD storage attached
- [ ] Security group configured:
  - [ ] SSH (22) - Your IP
  - [ ] HTTP (80) - Anywhere
  - [ ] HTTPS (443) - Anywhere
- [ ] SSH key pair created/selected
- [ ] Elastic IP allocated and associated
- [ ] Can SSH into instance

### DNS Configuration
- [ ] A record @ → Elastic IP
- [ ] A record www → Elastic IP
- [ ] SES DNS records added (TXT, MX, etc.)
- [ ] DNS propagation verified: `dig your-domain.com`

---

## Server Setup

### Initial Setup
- [ ] SSH into server as ubuntu user
- [ ] Run: `sudo bash setup-server.sh`
- [ ] Docker installed and running
- [ ] Git installed
- [ ] `/var/discourse` directory exists

### Plugin Transfer
- [ ] FanTribe plugin copied to server:
  ```bash
  scp -r plugins/fantribe-theme ubuntu@SERVER:/tmp/
  ```

### Configuration
- [ ] `app.yml.template` copied and edited with real values
- [ ] All `<PLACEHOLDER>` values replaced
- [ ] Configuration uploaded:
  ```bash
  scp app.yml root@SERVER:/var/discourse/containers/
  ```

---

## Deployment

### Build
- [ ] Run: `cd /var/discourse && ./launcher rebuild app`
- [ ] Build completes without errors (takes 5-15 minutes)
- [ ] Container is running: `./launcher status app`

### Verification
- [ ] Website loads: `https://your-domain.com`
- [ ] SSL certificate valid (padlock icon)
- [ ] No mixed content warnings
- [ ] Initial setup wizard appears

---

## Post-Deployment

### Admin Setup
- [ ] Register with developer email
- [ ] Activation email received
- [ ] Account activated
- [ ] Setup wizard completed
- [ ] Can access `/admin` panel

### FanTribe Theme
- [ ] Admin > Plugins: fantribe_theme_enabled = ON
- [ ] Custom FanTribe UI visible
- [ ] Glassmorphism effects working
- [ ] Mobile navigation working

### Uploads Test
- [ ] Create test post with image
- [ ] Image uploads successfully
- [ ] Image displays correctly
- [ ] Check S3 bucket: file appears

### Email Test
- [ ] Create test user with different email
- [ ] Activation email sent
- [ ] Email arrives within 5 minutes
- [ ] Links in email work

### Backup Test
- [ ] Admin > Backups: Create backup
- [ ] Backup completes
- [ ] Backup appears in S3 backup bucket

---

## Site Settings to Configure

### Required
- [ ] Site name: "FanTribe" or your brand
- [ ] Site description
- [ ] Contact email
- [ ] Logo uploaded

### Security
- [ ] Admin > Settings > Security
- [ ] Rate limiting configured
- [ ] CORS settings verified

### Files & Uploads
- [ ] Admin > Settings > Files
- [ ] Max image size set appropriately
- [ ] Max attachment size set
- [ ] Authorized extensions configured

### Users
- [ ] Admin > Settings > Users
- [ ] Registration settings configured
- [ ] Email authentication requirements set

---

## Credentials Reference

Fill this in as you create credentials:

| Credential | Value | Where to Get |
|------------|-------|--------------|
| Domain | | Domain registrar |
| Developer Email | | Your email |
| AWS Access Key ID | | IAM Console |
| AWS Secret Access Key | | IAM Console |
| AWS Region | | AWS Console |
| S3 Upload Bucket | | S3 Console |
| S3 Backup Bucket | | S3 Console |
| SES SMTP Endpoint | | SES Console |
| SES SMTP Username | | SES Console |
| SES SMTP Password | | SES Console |
| Elastic IP | | EC2 Console |
| SSH Key Path | | Your computer |

---

## Estimated Timeline

| Task | Duration |
|------|----------|
| AWS account/IAM setup | 15 min |
| S3 bucket creation | 10 min |
| SES setup | 30 min (+ approval wait) |
| EC2 creation | 15 min |
| DNS configuration | 10 min |
| Server setup | 20 min |
| Discourse build | 10-15 min |
| Configuration & testing | 30 min |
| **Total** | **~2-3 hours** |

Note: SES production access approval may take 24-48 hours