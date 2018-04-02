chef_gem 'zabbixapi' do
  action :install
  server_version = node['zabbix']['server']['version'].scan(/^\d+\.\d+/).first

  version '~> 3.0.0'
end
