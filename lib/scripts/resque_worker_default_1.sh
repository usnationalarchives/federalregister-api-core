#!/usr/bin/env bash
source /usr/local/rvm/environments/ruby-1.9.3-p551

cd /var/www/apps/federalregister-api-core
nohup /usr/local/rvm/wrappers/ruby-1.9.3-p551/bundle exec rake environment resque:work RAILS_ENV=production QUEUE=public_inspection,fr_index_pdf_previewer,fr_index_pdf_publisher,default,reimport,gpo_image_import INTERVAL=1 VERBOSE=1 PIDFILE=/var/www/apps/federalregister-api-core/tmp/pids/resque_worker_default_1.pid >> /var/www/apps/federalregister-api-core/log/resque_worker_default.log 2>&1 &
