# Argument definition and parsing
config.define_string_list('profiles', args=True)
cfg = config.parse()
available_profiles = [
  'sms-provider-stub',
  'beat',
  'antivirus',
  'notify-api',
  'notify-admin'
]

profiles = []

for arg in cfg.get('profiles', []):
  if arg in available_profiles:
    profiles.append(arg)

# Repo checkout
repo_base = 'git@github.com:Worth-NL/'
repo_list = [
  'notifications-api',
  'notifications-admin',
  'notifications-template-preview',
  'document-download-api',
  'document-download-frontend',
  'notifications-antivirus',
  'notifications-utils',
  'notifications-sms-provider-stub',
  'notifynl-frontend',
  'notifynl-frontend-jinja'
]

load('ext://git_resource', 'git_checkout')

if not os.path.exists(path='../notifynl.code-workspace'):
    local(command='cp templates/notifiynl.code-workspace.tmpl ../notifynl.code-workspace', quiet=True, echo_off=True)

if config.tilt_subcommand == 'up':
  for repo in repo_list:
    if not os.path.exists(path='../{}'.format(repo)):
      git_checkout(repository_url='{}{}'.format(repo_base, repo), checkout_dir='../{}'.format(repo))
      if repo == 'notifynl-frontend-jinja':
        local(command='git checkout notifynl/rijkshuisstijl', dir='../{}'.format(repo), quiet=True, echo_off=True)

  # Repo fixes
  ## General
  if not os.path.exists(path='./data/db'):
    local(command='mkdir -p ./data/db', quiet=True, echo_off=True)

  need_version_file = [
    'document-download-api',
    'document-download-frontend',
    'notifications-admin',
    'notifications-antivirus',
    'notifications-api',
    'notifications-template-preview'
  ]
  for repo in need_version_file:
    local(command="make generate-version-file", dir='../{}'.format(repo), quiet=True, echo_off=True)

  ## Admin
  local(command='npm install', dir='../notifications-admin', env={'NOTIFY_ENVIRONMENT': 'development'})
  local(command='npm run build', dir='../notifications-admin', env={'NOTIFY_ENVIRONMENT': 'development'})

  ## Utils
  utils_version = 'main'
  file = str(read_file("../notifications-admin/requirements.txt"))
  for line in file.splitlines():
      if "notifications-utils @" in line:
          parts = line.split('@')
          if len(parts) > 2:
              utils_version = parts[-1].strip()

  current_utils_branch = str(local(command='git branch --show-current', dir='../notifications-utils')).strip()

  if current_utils_branch != utils_version:
    local(command='git checkout {}'.format(utils_version), dir='../notifications-utils', quiet = True)

## Venv
  local(command='pip install uv', quiet=True, echo_off=True)

  if not os.path.exists(path='./.venv'):
    local(command='uv venv', quiet=True, echo_off=True)

  local(command='./scripts/venv_wrapper.sh uv pip install -r ../notifications-admin/requirements_for_test.txt', quiet=True)
  local(command='./scripts/venv_wrapper.sh uv pip uninstall notifications-utils', quiet=True)
  local(command='./scripts/venv_wrapper.sh uv pip install -e ../notifications-utils --config-settings editable_mode=compat', quiet=True)
  local(command='./scripts/venv_wrapper.sh uv pip uninstall govuk-frontend-jinja')
  local(command='./scripts/venv_wrapper.sh uv pip install -e ../notifynl-frontend-jinja --config-settings editable_mode=compat')

# Docker compose
os.environ['DC_ANTIVIRUS'] = 'ANTIVIRUS_ENABLED=0'
if 'antivirus' in profiles:
  os.putenv('DC_ANTIVIRUS', 'ANTIVIRUS_ENABLED=1')
if 'sms-provider-stub' in profiles:
  os.putenv('DC_SMS_PROVIDER_STUB_MMG', 'MMG_URL=http://host.docker.internal:6300/mmg')
  os.putenv('DC_SMS_PROVIDER_STUB_FIRETEXT', 'FIRETEXT_URL=http://host.docker.internal:6300/firetext')

docker_compose('./docker-compose.yml', profiles=profiles)

## defaults
dc_resource('db', labels=['plumbing'], trigger_mode=TRIGGER_MODE_MANUAL)
dc_resource('redis', labels=['plumbing'], trigger_mode=TRIGGER_MODE_MANUAL)
dc_resource('notify-api-db-migration', labels=['plumbing'], trigger_mode=TRIGGER_MODE_MANUAL, resource_deps=['db'])
dc_resource('document-download-api', labels=['document-download'], links=['http://api.document-download.localhost:7000'], infer_links=False)
dc_resource('document-download-frontend', labels=['document-download'], links=['http://frontend.document-download.localhost:7001'], resource_deps=['document-download-api'], infer_links=False)
dc_resource('template-preview-api', labels=['template-preview'], links=['http://template-preview-api.localhost:6013'], infer_links=False)
dc_resource('template-preview-celery', labels=['template-preview'], resource_deps=['document-download-api'])

## From 'notify-api' profile
if 'notify-api' in profiles:
  dc_resource('notify-api', labels=['notify'], links=['http://notify-api.localhost:6011', 'http://notify-api.localhost:5678'], resource_deps=['notify-api-db-migration', 'db', 'redis', 'template-preview-api'], infer_links=False)
  dc_resource('notify-api-celery', labels=['notify'], resource_deps=['db', 'redis'])

## From 'notify-admin' profile
if 'notify-admin' in profiles:
  dc_resource('notify-admin', labels=['notify'], links=['http://notify.localhost:6012', 'http://notify.localhost:5679'], resource_deps=['notify-api', 'template-preview-api'], infer_links=False)

## From 'beat' profile
if 'beat' in profiles:
  dc_resource('notify-api-celery-beat', labels=['notify'], resource_deps=['db', 'redis'])

## From 'antivirus' profile
if 'antivirus' in profiles:
  dc_resource('antivirus-api', labels=['antivirus'], links=['http://antivirus-api.localhost:6016'], infer_links=False)
  dc_resource('antivirus-celery', labels=['antivirus'], resource_deps=['antivirus-api'])

## From 'sms-provider-stub' profile
if 'sms-provider-stub' in profiles:
  dc_resource('sms-provider-stub', labels=['side-services'])

## Misc fixes, set as buttons because local commands happen before docker compose
load('ext://uibutton', 'cmd_button', 'location')
cmd_button('notify-admin:utils fix',
           argv=['docker', 'exec', 'notify-admin', '/bin/sh', '-c', 'sudo pip install -e /home/vcap/utils'],
           resource='notify-admin',
           icon_name='plumbing',
           text='Fix utils'
)

cmd_button('notify-admin:npm build',
           argv=['/bin/sh', '-c', 'cd ../notifications-admin && npm run build'],
           resource='notify-admin',
           icon_name='build',
           text='NPM build'
)

cmd_button('notify-api:utils fix',
           argv=['docker', 'exec', 'notify-admin', '/bin/sh', '-c', 'sudo pip install -e /home/vcap/utils'],
           resource='notify-api',
           icon_name='plumbing',
           text='Fix utils'
)

cmd_button(name='nav-open-code',
           argv=['code', '../notifynl.code-workspace'],
           text='Open VSCode',
           location=location.NAV,
           icon_name='code')