#
# Cookbook Name:: zabbix
# Attributes:: default

case node['platform_family']
when 'windows'
  if ENV['ProgramFiles'] == ENV['ProgramFiles(x86)']
    # if user has never logged into an interactive session then ENV['homedrive'] will be nil
    default['zabbix']['etc_dir']    = ::File.join((ENV['homedrive'] || 'C:'), 'Program Files', 'Zabbix Agent')
  else
    default['zabbix']['etc_dir']    = ::File.join(ENV['ProgramFiles'], 'Zabbix Agent')
  end
  default['zabbix']['install_dir']           = 'C:/zabbix/install'
  default['zabbix']['src_dir']               = 'C:/zabbix'
  default['zabbix']['tmp_dir']               = 'C:/tmp'
  default['zabbix']['home']                  = 'C:/zabbix'
  default['zabbix']['web_dir']               = 'C:/zabbix/web'
  default['zabbix']['external_dir']          = 'C:/zabbix/externalscripts'
  default['zabbix']['alert_dir']             = 'C:/zabbix/AlertScriptsPath'
else
  default['zabbix']['etc_dir']               = '/etc/zabbix'
  default['zabbix']['install_dir']           = '/opt/zabbix'
  default['zabbix']['src_dir']               = '/opt'
  default['zabbix']['tmp_dir']               = '/tmp'
  default['zabbix']['home']                  = '/opt/zabbix'
  default['zabbix']['web_dir']               = '/opt/zabbix/web'
  default['zabbix']['external_dir']          = '/opt/zabbix/externalscripts'
  default['zabbix']['alert_dir']             = '/opt/zabbix/AlertScriptsPath'
end

default['zabbix']['lock_dir']                = '/var/lock/subsys'

default['zabbix']['log_dir']                 = '/var/log/zabbix'
default['zabbix']['run_dir']                 = '/var/run/zabbix'

default['zabbix']['login']                   = 'zabbix'
default['zabbix']['group']                   = 'zabbix'
default['zabbix']['uid']                     = nil
default['zabbix']['gid']                     = nil
default['zabbix']['shell']                   = '/bin/bash'
default['mariadb']['use_default_repository'] = true


default['php-fpm']['user']                   = 'nginx'
default['php-fpm']['group']                  = 'nginx'
default['php-fpm']['conf_dir']               = '/etc/php-5.6.d'
default['php-fpm']['pool_conf_dir']          = '/etc/php-fpm-5.6.d'
default['php-fpm']['conf_file']              = '/etc/php-fpm-5.6.conf'
default['php-fpm']['pid']                    = '/var/run/php-fpm/php-fpm-5.6.pid'
default['php-fpm']['package_name']           = 'php56-fpm'
default['php-fpm']['service_name']           = 'php-fpm-5.6'
default['php-fpm']['yum_url']                = 'http://rpms.famillecollet.com/enterprise/7/remi/$basearch/'
default['php-fpm']['yum_mirrorlist']         = 'http://rpms.famillecollet.com/enterprise/7/remi/mirror'
default['php-fpm']['pools']                  = {
    'www' => {
        enable: true,
        access_log: true,
    },
}