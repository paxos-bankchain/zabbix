include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"
include_recipe 'zabbix::agent_common'

# Install configuration and optional additional agent config file containing UserParameter(s)
case node['platform_family']
when 'windows'
  template 'zabbix_agentd.conf' do
    path node['zabbix']['agent']['config_file']
    source 'zabbix_agentd.conf.erb'
    notifies :enable, 'service[Zabbix Agent]'
    notifies :restart, 'service[Zabbix Agent]'
    notifies :run, 'execute[config_firewall]'
  end
  template 'user_params.conf' do
    path node['zabbix']['agent']['userparams_config_file']
    source 'user_params.conf.erb'
    notifies :enable, 'service[Zabbix Agent]'
    notifies :restart, 'service[Zabbix Agent]'
    notifies :run, 'execute[config_firewall]'
    only_if { node['zabbix']['agent']['user_parameter'].length > 0 }
  end
else
  template 'zabbix_agentd.conf' do
    path node['zabbix']['agent']['config_file']
    source 'zabbix_agentd.conf.erb'
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[zabbix_agentd]'
  end
  template 'user_params.conf' do
    path node['zabbix']['agent']['userparams_config_file']
    source 'user_params.conf.erb'
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[zabbix_agentd]'
    only_if { node['zabbix']['agent']['user_parameter'].length > 0 }
  end
end

