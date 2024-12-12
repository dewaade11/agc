#!/bin/bash

# Update dan install dependencies dasar
echo "Memperbarui sistem dan menginstal curl..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl

# Menginstal nvm
echo "Menginstal nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Memuat nvm ke dalam lingkungan
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \ . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \ . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Memeriksa versi Node.js yang tersedia dan menginstal Node.js serta npm
echo "Menginstal Node.js dan npm..."
nvm install v20.13.0
nvm use v20.13.0

# Menginstal PM2
echo "Menginstal PM2..."
npm install pm2 -g

# Menginstal Docker
echo "Menginstal Docker..."
curl -sSL https://get.docker.com | sh

# Menambahkan user ke grup Docker
echo "Menambahkan user ke grup Docker..."
sudo usermod -aG docker $(whoami)

# Menarik image Docker untuk Nginx Proxy Manager
echo "Menarik image Docker Nginx Proxy Manager..."
docker pull jc21/nginx-proxy-manager:latest

# Menjalankan container Docker untuk Nginx Proxy Manager
echo "Menjalankan container Docker Nginx Proxy Manager..."
docker run -d --name=nginxproxymanager \
 -v $PWD/data:/data \
 -v $PWD/letsencrypt:/etc/letsencrypt \
 --network host \
 --restart unless-stopped \
 jc21/nginx-proxy-manager

echo "Proses selesai! Silakan logout dan login kembali agar perubahan grup Docker berlaku."
