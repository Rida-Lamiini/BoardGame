# Deployment Guide for E-Wallet Application on AWS EC2

## Prerequisites

- AWS EC2 instance with Ubuntu
- Security groups configured as provided:
  - Port 22 (SSH)
  - Port 80 (HTTP)
  - Port 443 (HTTPS)
  - Port 3000 (Frontend)
  - Port 8080 (Backend)

## Deployment Steps

1. **Connect to your EC2 instance:**

   ```bash
   ssh -i your-key.pem ubuntu@16.170.214.112
   ```

2. **Run the deployment script:**

   ```bash
   wget https://raw.githubusercontent.com/rida999/e-wallet/main/deploy.sh
   chmod +x deploy.sh
   ./deploy.sh
   ```

3. **Set up environment variables:**
   Create a `.env` file in the project root with your database credentials and other configurations.

4. **Access the application:**
   - Frontend: http://16.170.214.112
   - Backend API: http://16.170.214.112/api

## Manual Deployment (Alternative)

If you prefer to deploy manually:

1. Install Docker and Docker Compose on your EC2 instance.
2. Clone the repository: `git clone https://github.com/rida999/e-wallet.git`
3. Navigate to the project directory: `cd e-wallet`
4. Pull Docker images: `docker pull rida999/e-wallet-frontend:latest && docker pull rida999/e-wallet-backend:latest`
5. Run the application: `docker-compose -f docker-compose.prod.yml up -d`
6. Configure Nginx using the provided `nginx.conf` file.

## Notes

- Ensure your Docker Hub repositories are public or authenticate if private.
- Update the repository URL in `deploy.sh` if different.
- The application uses PostgreSQL database, make sure to configure it properly.
- For production, consider using a domain name and SSL certificate.
