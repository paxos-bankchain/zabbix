root_dirs = [
  node['zabbix']['agent']['include_dir']
]

require 'win32ole'
zabbixservice = 'Zabbix Agent'
wmi = WIN32OLE.connect("winmgmts://")
services = wmi.ExecQuery("Select * from Win32_Service where Name = '#{zabbixservice}'")

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
      if services.count < 1
        notifies :run, 'execute[install_zabbix_agentd]'
      end
      notifies :enable, 'service[Zabbix Agent]'
      notifies :restart, 'service[Zabbix Agent]'
    else
      notifies :restart, 'service[zabbix_agentd]'
    end
  end
end
