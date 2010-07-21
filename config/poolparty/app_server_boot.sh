#!/bin/bash -ex
runurl https://s3.amazonaws.com/config.internal.federalregister.gov/app_server_key_update.sh
runurl https://s3.amazonaws.com/config.internal.federalregister.gov/app_server_backup_cron.sh
runurl https://s3.amazonaws.com/config.internal.federalregister.gov/app_server_code_update.sh