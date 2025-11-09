#!/bin/bash
# -------------------------------
# Melih Can Müzik Botu Otomatik Kurulum & PM2 Yönetimi (Ubuntu 22.04+)
# -------------------------------

GREEN='\033[0;32m'
NC='\033[0m'

BOT_DIR="/opt/melih-bot"
REPO_URL="https://github.com/melih022/123.git"

echo -e "${GREEN}Melih Can Müzik Botu kurulumu başlatılıyor...${NC}"

# 1. Sistem güncelleme
sudo apt update && sudo apt upgrade -y

# 2. Gerekli paketler
sudo apt install -y git python3 python3-venv python3-pip ffmpeg tmux htop curl build-essential

# 3. Node.js ve PM2 kurulumu
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs
sudo npm install pm2 -g

# 4. Eğer Redis veya MongoDB istersen Docker üzerinden kurabilirsin (opsiyonel)
# sudo apt install -y docker.io
# sudo systemctl enable docker
# sudo systemctl start docker
# docker run -d --name redis -p 6379:6379 redis
# docker run -d --name mongodb -p 27017:27017 mongo

# 5. Eski bot dizini varsa sil
if [ -d "$BOT_DIR" ]; then
    echo -e "${GREEN}Eski bot dizini bulunuyor, siliniyor...${NC}"
    sudo rm -rf "$BOT_DIR"
fi

# 6. GitHub repoyu klonla
echo -e "${GREEN}Repo klonlanıyor...${NC}"
sudo git clone "$REPO_URL" "$BOT_DIR"

# 7. Klonlanan repoya git
cd "$BOT_DIR" || { echo "Repo bulunamadı!"; exit 1; }

# 8. Python sanal ortam oluştur ve pip kur
sudo python3 -m venv venv --upgrade-deps
source venv/bin/activate

# 9. Python paketlerini kur
pip install --upgrade pip
pip install -r requirements.txt
pip install pymongo redis

# 10. Temp temizleme cronjob ekle (20 dakikada bir)
(crontab -l 2>/dev/null; echo "*/20 * * * * rm -rf $BOT_DIR/temp/*") | crontab -

# 11. PM2 ile botu başlat
pm2 start venv/bin/python3 --name "melih-bot" -- main.py

# 12. PM2 kaydet ve sistem başlatmaya ekle
pm2 save
sudo pm2 startup systemd -u $USER --hp $HOME

echo -e "${GREEN}Kurulum tamamlandı! Bot PM2 ile çalıştırılıyor.${NC}"
echo -e "${GREEN}.env dosyasını düzenleyip BOT_TOKEN ve SESSION_STRING eklemeyi unutmayın.${NC}"
