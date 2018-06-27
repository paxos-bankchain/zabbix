include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"
include_recipe 'zabbix::agent_common'

# Install configuration
template 'zabbix_agentd.conf' do
  path node['zabbix']['agent']['config_file']
  source 'zabbix_agentd.conf.erb'
  case node['platform_family']
  when 'windows'
    notifies :enable, 'service[Zabbix Agent]'
    notifies :restart, 'service[Zabbix Agent]'
  else
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[zabbix_agentd]'
  end
end

# Install optional additional agent config file containing UserParameter(s)
template 'user_params.conf' do
  path node['zabbix']['agent']['userparams_config_file']
  source 'user_params.conf.erb'
  case node['platform_family']
  when 'windows'
    notifies :enable, 'service[Zabbix Agent]'
    notifies :restart, 'service[Zabbix Agent]'
  else
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[zabbix_agentd]'
  end
  only_if { node['zabbix']['agent']['user_parameter'].length > 0 }
end

ruby_block 'start service' do
  block do
    true
  end
  case node['platform_family']
  when 'windows'
    notifies :enable, 'service[Zabbix Agent]'
    notifies :restart, 'service[Zabbix Agent]'
    notifies :run, 'execute[config_firewall]'
  else
    notifies :restart, 'service[zabbix_agentd]'
  end
end
