#!/usr/bin/env bash

repositories=('notifications-api' 'notifications-admin' 'notifications-template-preview' 'document-download-api' 'document-download-frontend' 'notifications-antivirus' 'notifications-utils' 'notifications-sms-provider-stub')
for repository in ${repositories[@]}; do
    (cd .. && git clone "git@github.com:Worth-NL/$repository")
    (cd ../$repository && make generate-version-file)
done
