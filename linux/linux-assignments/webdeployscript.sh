#!/bin/bash

set -e  # Exit immediately if any command fails

USER=$(whoami)
DATE=$(date)

echo "Hello $USER"
echo "Today is: $DATE"

echo "========================================"
echo "1. Directory Setup"
echo "========================================"

WAPP_DIR="webdir/"

if [ -d "$WAPP_DIR" ]; then
    echo "Dir already exists"
else
    echo "Creating webdir..."
    mkdir -p "$WAPP_DIR"
    echo "'WAPP_DIR' created successfully"
fi

echo "========================================"
echo "2. Web Application Deployment"
echo "========================================"

DEPLOY_DIR="/var/www/phantom.local"
SERVER_NAME="phantom.local"

if [ -d "$DEPLOY_DIR" ]; then
    echo "Deploy directory already exists"
else
    echo "Creating deploy directory..."
    sudo mkdir -p "$DEPLOY_DIR"
    echo "'DEPLOY_DIR' created successfully"
fi

# -------------------- FIX 1: Absolute path for zip file --------------------
ZIP_FILE="$HOME/Downloads/html5up-phantom.zip"
if [ ! -f "$ZIP_FILE" ]; then
    echo "Error: Zip file not found at $ZIP_FILE" >&2
    exit 1
fi

# -------------------- FIX 2: Unzip and overwrite safely --------------------
sudo unzip "$ZIP_FILE" -d "$DEPLOY_DIR"

# -------------------- FIX 3: Set proper ownership & permissions (CentOS) --------------------
# Nginx runs as 'nginx' on CentOS by default
sudo chown -R nginx:nginx "$DEPLOY_DIR"
sudo find "$DEPLOY_DIR" -type d -exec chmod 755 {} \;
sudo find "$DEPLOY_DIR" -type f -exec chmod 644 {} \;

# -------------------- FIX 4: SELinux context --------------------
# Allows Nginx to read files if SELinux is enforcing
sudo chcon -Rt httpd_sys_content_t "$DEPLOY_DIR"

# Ensure index.html exists
if [ ! -f "$DEPLOY_DIR/index.html" ]; then
    echo "<h1>Welcome to $SERVER_NAME</h1>" | sudo tee "$DEPLOY_DIR/index.html"
fi

echo "========================================"
echo "3. Configuring Nginx"
echo "========================================"

NGINX_CONF="/etc/nginx/conf.d/phantom.local.conf"

# Remove old config if exists
sudo rm -f "$NGINX_CONF"

# -------------------- FIX 5: Use sudo tee for Nginx config (works on CentOS) --------------------
sudo tee "$NGINX_CONF"> /dev/null <<EOF
server {
    listen 80;
    server_name $SERVER_NAME;
    root $DEPLOY_DIR;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Test and reload Nginx
sudo nginx -t
sudo systemctl restart nginx

echo "========================================"
echo "4. Domain Resolution"
echo "========================================"

HOSTS="/etc/hosts"
SERVER_IP="127.0.0.1"

# -------------------- FIX 6: Append to /etc/hosts safely --------------------
if grep -q "$SERVER_NAME" "$HOSTS"; then
    echo "$SERVER_NAME already exists in $HOSTS"
else
    echo "$SERVER_IP    $SERVER_NAME" | sudo tee -a "$HOSTS"
    echo "Added $SERVER_NAME to $HOSTS"
fi

echo "========================================"
echo "5. Nginx Service Management"
echo "========================================"

sudo nginx -t >&2
sudo systemctl restart nginx

echo "========================================"
echo "6. Smoke Testing"
echo "========================================"

curl -I "http://$SERVER_NAME" | grep -Fi "200 OK" && echo "Site is available!" || echo "Site is down or returned another status."

echo "========================================"
echo "Deployment completed ✅"
echo "Access app at: http://$SERVER_NAME"
echo "========================================"
