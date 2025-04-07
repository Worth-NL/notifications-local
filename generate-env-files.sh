#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Checking for git"
if ! command -v git &> /dev/null; then
  echo -e "......................................... [ ${RED}ERROR${NC} ]"
  echo "`git` is not installed :: https://git-scm.com"
  exit 1
fi
echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"

echo "Checking for pass"
if ! command -v pass &> /dev/null; then
  echo -e "......................................... [ ${RED}ERROR${NC} ]"
  echo "`pass` is not installed :: https://www.passwordstore.org"
  exit 2
fi
echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"
 
echo "Checking for gpg"
if ! command -v gpg &> /dev/null; then
  echo -e "......................................... [ ${RED}ERROR${NC} ]"
  echo "`gpg` is not installed :: https://gnupg.org"
  exit 3
fi
echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"

echo "Checking for GPG key"
gpg --list-secret-keys --keyid-format LONG 4C06577B191A880E47FBB78F899D043C294C0F48 > /dev/null 2>&1
GPG_EXIT_CODE=$?

if [ $GPG_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}ERROR[3][${GPG_EXIT_CODE}]${NC} :: The [Worth Ventures B.V. (NotifyNL) <info@worth.nl>] GPG key is required to continue"
    exit $GPG_EXIT_CODE
fi

echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"

export TMPL_SENTRY_ENVIRONMENT="dev-$(whoami)"
export TMPL_NOTIFICATIONS_QUEUE_PREFIX="local_dev_$(whoami)_"

if [ ! -f "private/local-aws-creds.env" ]; then
  echo "Enter your local development user's aws_access_key_id: "
  read TMPL_AWS_ACCESS_KEY_ID
  export TMPL_AWS_ACCESS_KEY_ID="${TMPL_AWS_ACCESS_KEY_ID}"

  echo "Enter your local development user's aws_secret_access_key: "
  read TMPL_AWS_SECRET_ACCESS_KEY
  export TMPL_AWS_SECRET_ACCESS_KEY="${TMPL_AWS_SECRET_ACCESS_KEY}"

  echo "Generating private/local-aws-creds.env"
  envsubst < templates/local-aws-creds.env.tmpl > private/local-aws-creds.env
  
  echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"
fi

echo "Checking out credentials repository"
pass git clone git@github.com:Worth-NL/notifynl-credentials.git > /dev/null 2>&1
echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"

echo "Reading secrets from store"
# API keys
export TMPL_MMG_API_KEY=$(pass notifynl-credentials/credentials/mmg)
export TMPL_FIRETEXT_API_KEY=$(pass notifynl-credentials/credentials/firetext)
export TMPL_SPRYNG_API_KEY=$(pass notifynl-credentials/credentials/spryng)
# export TMPL_ZENDESK_API_KEY=$(pass notifynl-credentialscredentials/zendesk)
# Sentry DSNs
export TMPL_NOTIFY_API_SENTRY_DSN=$(pass notifynl-credentials/credentials/sentry/dsn/api)
export TMPL_NOTIFY_ADMIN_SENTRY_DSN=$(pass notifynl-credentials/credentials/sentry/dsn/admin)
export TMPL_DOCUMENT_DOWNLOAD_API_SENTRY_DSN=$(pass notifynl-credentials/credentials/sentry/dsn/ddapi)
export TMPL_DOCUMENT_DOWNLOAD_FRONTEND_SENTRY_DSN=$(pass notifynl-credentials/credentials/sentry/dsn/ddfrontend)
export TMPL_TEMPLATE_PREVIEW_API_SENTRY_DSN=$(pass notifynl-credentials/credentials/sentry/dsn/tpapi)
export TMPL_ANTIVIRUS_API_SENTRY_DSN=$(pass notifynl-credentials/credentials/sentry/dsn/avapi)
echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"

mkdir -p private

for service in \
  "api" \
  "admin"
do
  echo -e "Generating ../notifications-${service}/environment.sh"
  envsubst < templates/environment.${service}.sh.tmpl > ../notifications-${service}/environment.sh
  echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"

  echo -e "Generating ../notifications-${service}/.env"
  envsubst < templates/${service}.env.tmpl > ../notifications-${service}/.env
  echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"
done

for service in \
  "antivirus-api" \
  "document-download-api" \
  "document-download-frontend" \
  "notify-admin" \
  "notify-api" \
  "template-preview-api"
do
  echo -e "Generating private/${service}.env"
  envsubst < templates/${service}.env.tmpl > private/${service}.env
  echo -e "......................................... [ ${GREEN}SUCCESS${NC} ]"
done
