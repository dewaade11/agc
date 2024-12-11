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


# Nama kontainer Docker
CONTAINER_NAME="nginxproxymanager"

# Email dan password baru
NEW_EMAIL="ketara@gmail.com"
NEW_PASSWORD="oliolio@651614"

# Periksa apakah kontainer berjalan
if ! sudo docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Kontainer ${CONTAINER_NAME} tidak ditemukan atau tidak berjalan."
  exit 1
fi

# Masuk ke dalam kontainer dan instal sqlite3 jika diperlukan
echo "Menginstal sqlite3 di dalam kontainer ${CONTAINER_NAME}..."
sudo docker exec -it $CONTAINER_NAME bash -c "apt-get update && apt-get install sqlite3 -y"

# Jalankan query untuk mengubah email dan password
echo "Memperbarui email dan password di database SQLite..."
sudo docker exec -it $CONTAINER_NAME bash -c "sqlite3 /data/database.sqlite \"UPDATE user SET email='${NEW_EMAIL}', password='${NEW_PASSWORD}' WHERE email='admin@example.com';\""

# Restart kontainer
echo "Merestart kontainer ${CONTAINER_NAME}..."
sudo docker restart $CONTAINER_NAME

echo "Perubahan email dan password selesai. Login dengan email: ${NEW_EMAIL} dan password baru."

