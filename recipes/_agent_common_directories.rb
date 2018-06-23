root_dirs = [
  node['zabbix']['agent']['include_dir']
]

# Create root folders
root_dirs.each do |dir|
  directory dir do
    unless node['platform'] == 'windows'
      owner 'root'
      group 'root'
      mode '755'
    end
    recursive true
    if node['platform_family'] == 'windows'
      notifies :run, 'powershell_script[stop_zabbix_if_exist]'
      notifies :run, 'execute[install_zabbix_agentd]'
      notifies :run, 'execute[start_zabbix_agentd]'
    else
      notifies :restart, 'service[zabbix_agentd]'
    end
  end
end
