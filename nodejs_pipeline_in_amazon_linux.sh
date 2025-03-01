mkdir nodejsapp
cd nodejsapp
sudo yum install nodejs npm -y
sudo yum install git nginx -y
git init
git config --global user.name tejasKhamkar2211
git config --global user.email tejaskhamkar@gmail.com
git remote add origin https://github.com/tejasKhamkar2211/nodepipeline.git
git pull origin master
npm install
sudo npm install -g pm2
sudo pm2 start index.js



#!/bin/bash

# Define the target file location
TARGET_FILE="/etc/nginx/nginx.conf"

# Backup the existing Nginx config
sudo cp "$TARGET_FILE" "$TARGET_FILE.bak"

# Write the new configuration to the target file
sudo tee "$TARGET_FILE" > /dev/null <<EOL
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
            proxy_pass http://127.0.0.1:3000; # pm2 is running here
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}
EOL

# Restart Nginx to apply changes
sudo systemctl restart nginx

# Check if Nginx restarted successfully
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx restarted successfully with the new configuration."
else
    echo "❌ Failed to restart Nginx. Check the configuration for errors."
fi


sudo service nginx restart
