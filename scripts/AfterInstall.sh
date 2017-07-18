#!/bin/bash
# Thanks to: http://sfviapgh.com/blog/2016/2/18/how-to-deploy-rails-with-aws-codedeploy

export RAILS_ENV=production
cd /var/www/plazachapina.ca/html
sudo chmod 750 bin/*
logs="log/production.log log/puma-production.stdout.log log/puma-production.stderr.log"
touch $logs
sudo chown :www-data $logs
sudo chmod 660 $logs

# need to set up the database (the user)
# need rails db:create the first time
bin/bundle install # --path vendor/bundle
bin/rails db:migrate
bin/rails assets:clobber
bin/rails assets:precompile
