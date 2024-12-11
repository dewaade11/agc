#!/bin/bash

# Update dan install dependencies dasar
echo "Memperbarui sistem dan menginstal curl..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl

# Menginstal nvm dan PM2
echo "Menginstal nvm dan PM2..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.bashrc
nvm list-remote
nvm install v20.13.0 && npm install pm2 -g

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
 -v ./data:/data \
 -v ./letsencrypt:/etc/letsencrypt \
 --network host \
 --restart unless-stopped \
 jc21/nginx-proxy-manager

echo "Proses selesai! Silakan logout dan login kembali agar perubahan grup Docker berlaku."

# Variabel
EMAIL="ketara@gmail.com"
NEW_PASSWORD="oliolio@651614"
CONTAINER_NAME="nginxproxymanager"
DATABASE_PATH="/data/database.sqlite"

# Cek apakah script dijalankan dengan akses root (sudo)
if [ "$(id -u)" -ne 0 ]; then
  echo "Harap jalankan script ini dengan sudo atau sebagai root"
  exit 1
fi

# Masuk ke kontainer dan buka database SQLite untuk mengganti password
echo "Mengganti password untuk email: $EMAIL..."

# Jalankan perintah SQL untuk mengupdate password
docker exec -i $CONTAINER_NAME sqlite3 $DATABASE_PATH "UPDATE user SET password='$NEW_PASSWORD' WHERE email='$EMAIL';"

# Restart kontainer Nginx Proxy Manager agar perubahan diterapkan
echo "Restarting Nginx Proxy Manager container..."
docker restart $CONTAINER_NAME

echo "Password telah berhasil diubah untuk pengguna dengan email $EMAIL."
