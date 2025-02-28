mkdir nodejsapp
cd nodejsapp
sudo yum install nodejs npm -y
sudo yum install git -y
git init
git config --global user.name tejasKhamkar2211
git config --global user.email tejaskhamkar@gmail.com
git remote add origin https://github.com/tejasKhamkar2211/nodepipeline.git
git pull origin master
npm install
sudo npm install -g pm2
sudo pm2 start index.js
