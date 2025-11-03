#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade -y

# Install Docker using official script to avoid conflicts
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone the repository (replace with your actual repo URL)
git clone https://github.com/rida999/e-wallet.git
cd e-wallet

# Create .env file if it doesn't exist (you may need to set actual values)
if [ ! -f .env ]; then
    echo "Creating .env file. Please update with your actual database credentials."
    cat > .env << EOF
db_name=ewallet
db_username=ewallet_user
db_password=ewallet_password
EOF
fi

# Pull the latest images from Docker Hub
sudo docker pull rida999/e-wallet-frontend:latest
sudo docker pull rida999/e-wallet-backend:latest

# Run the production compose file
sudo docker-compose -f docker-compose.prod.yml up -d

# Install Nginx for reverse proxy
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

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 30

# Check if containers are running
sudo docker ps

echo "Deployment completed. Access the app at http://16.170.214.112"
echo "Note: You may need to update the .env file with your actual database credentials."
