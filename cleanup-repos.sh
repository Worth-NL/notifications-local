#!/usr/bin/env bash

repositories=('notifications-api' 'notifications-admin' 'notifications-template-preview' 'document-download-api' 'document-download-frontend' 'notifications-antivirus' 'notifications-utils' 'NotifyNL-OMC')
for repository in ${repositories[@]}; do
    (cd .. && rm -rf $repository)
done
