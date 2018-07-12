root_dirs = [
  node['zabbix']['agent']['include_dir']
]

# Create root folders
root_dirs.each do |dir|
  case node['platform_family']
  when 'windows'
    directory dir do
      notifies :enable, 'service[Zabbix Agent]'
      notifies :restart, 'service[Zabbix Agent]'
    end
  else
    directory dir do
      owner 'root'
      group 'root'
      mode '755'
      recursive true
      notifies :restart, 'service[zabbix_agentd]'
    end
  end
end

