#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone the repository (replace with your actual repo URL)
git clone https://github.com/rida999/e-wallet.git
cd e-wallet

# Pull the latest images from Docker Hub
docker pull rida999/e-wallet-frontend:latest
docker pull rida999/e-wallet-backend:latest

# Run the production compose file
docker-compose -f docker-compose.prod.yml up -d

# Optional: Install Nginx for reverse proxy if needed
sudo apt install -y nginx

# Configure Nginx (basic config for frontend on port 80)
sudo tee /etc/nginx/sites-available/e-wallet <<EOF
server {
    listen 80;
    server_name 16.170.214.112;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/e-wallet /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

echo "Deployment completed. Access the app at http://16.170.214.112"
