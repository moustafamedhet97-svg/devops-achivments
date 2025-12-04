echo "========================================"
echo "1. NGINX Web Application Deployment CentOS"
echo "========================================"

NGINX_CONF="/etc/nginx/conf.d/"
DEPLOY_DIR="/var/www/"
SERVER1_NAME="phantom.local"
SERVER2_NAME="editorial.local"
PHANTOM_CONF="/etc/nginx/conf.d/phantom.conf"
EDITORIAL_CONF="/etc/nginx/conf.d/editorial.conf"
HOSTS="/etc/hosts"
SERVERIP="192.168.1.4"

# Remove old config if exists
sudo rm -f "$NGINX_CONF"

# Nginx phantom config

sudo tee "$PHANTOM_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $SERVER1_NAME;
    root $DEPLOY_DIR/html5up-phantom/;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Nginx editorial config

sudo tee "$EDITORIAL_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $SERVER2_NAME;
    root $DEPLOY_DIR/html5up-editorial/;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Remove old hosts if exists

sudo rm -f "$HOSTS"

echo "========================================"
echo "2. Domain Resolution"
echo "========================================"

sudo tee "$HOSTS" > /dev/null <<EOF
$SERVERIP	$SERVER1_NAME

$SERVERIP	$SERVER2_NAME

EOF


