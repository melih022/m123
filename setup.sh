echo -e "${GREEN}Melih Can Müzik Botu kurulumu başlatılıyor...${NC}"

# 1. Sistem güncelleme
sudo apt update && sudo apt upgrade -y

# 2. Gerekli paketler
sudo apt install -y git python3 python3-pip python3-venv ffmpeg tmux htop curl build-essential

# 3. Node.js ve PM2 kurulumu
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs
sudo npm install pm2 -g

# 4. Opsiyonel: Redis ve MongoDB kurulumu
sudo apt install -y redis-server mongodb
sudo systemctl enable redis-server mongodb
sudo systemctl start redis-server mongodb

# 5. GitHub repoyu klonla (senin repoya)
echo -e "${GREEN}Repo klonlanıyor...${NC}"
sudo git clone https://github.com/melih022/123.git /opt/melih-bot

# 6. Klonlanan repoya gir
cd /opt/melih-bot || { echo "Repo bulunamadı!"; exit 1; }

# 7. Python sanal ortam oluştur ve aktif et
sudo python3 -m venv venv
source venv/bin/activate

# 8. Python paketlerini kur
sudo pip install -U pip
sudo pip install -r requirements.txt
sudo pip install pymongo redis

# 9. Temp temizleme cronjob ekle (20 dakikada bir)
(crontab -l 2>/dev/null; echo "*/20 * * * * rm -rf /opt/melih-bot/temp/*") | sudo crontab -

# 10. PM2 ile botu başlat
sudo pm2 start venv/bin/python3 --name "melih-bot" -- main.py

# 11. PM2 kaydet ve startup
sudo pm2 save
sudo pm2 startup systemd -u root --hp /root

echo -e "${GREEN}Kurulum tamamlandı! Bot PM2 ile çalıştırılıyor.${NC}"
echo -e "${GREEN}.env dosyasını düzenleyip BOT_TOKEN ve SESSION_STRING eklemeyi unutmayın.${NC}"
