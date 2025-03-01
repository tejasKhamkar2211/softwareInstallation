sudo yum update -y
sudo yum install python3-pip python3-virtualenv.noarch nginx git -y
mkdir pythonapp
cd pythonapp
git init
git config --global user.name tejasKhamkar2211
git config --global user.email tejaskhamkar@gmail.com
git remote add origin https://github.com/tejasKhamkar2211/python-deploy.git
git pull origin master
python3 -m venv myenv
source myenv/bin/activate
pip install -r requirements.txt




#!/bin/bash

# Define variables
APP_DIR="/home/ec2-user/pythonapp"  # Change if your app is in a different location
VENV_DIR="$APP_DIR/myenv"
GUNICORN_EXEC="$VENV_DIR/bin/gunicorn"

# Create systemd service file
echo "Creating Gunicorn systemd service..."
sudo bash -c "cat > /etc/systemd/system/gunicorn.service" <<EOL
[Unit]
Description=Gunicorn service to run Flask app
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_DIR/bin"
ExecStart=$GUNICORN_EXEC --workers 3 --bind 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the service
echo "Reloading systemd and starting Gunicorn service..."
sudo systemctl daemon-reload
sudo systemctl enable gunicorn
sudo systemctl start gunicorn

# Check service status
echo "Checking service status..."
sudo systemctl status gunicorn --no-pager





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
            proxy_pass http://127.0.0.1:5000; # gunicorn is running here
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
