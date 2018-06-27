# Manage Agent service
# For windows, installing and starting service by commands, https://www.zabbix.com/documentation/3.4/manual/appendix/install/windows_agent
# Also need to configure firewall to let Zabbix server talk to agent.

if platform_family?('windows')
  require 'win32ole'
  zabbixservice = 'Zabbix Agent'
  wmi = WIN32OLE.connect("winmgmts://")

  execute 'install_zabbix_agentd' do
    command "#{node['zabbix']['agent']['agentd_dir']} --config \"#{node['zabbix']['agent']['config_file']}\" --install"
    not_if  { wmi.ExecQuery("Select * from Win32_Service where Name = '#{zabbixservice}'").count > 0 }
  end
  service 'Zabbix Agent' do
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end
  execute 'config_firewall' do
    command "netsh advfirewall firewall add rule name=\"zabbix_agentd\" dir=in action=allow program=\"#{node['zabbix']['agent']['win_agentd_dir']}.exe\" localport=#{node['zabbix']['agent']['zabbix_agent_port']} protocol=TCP enable=yes"
  end
elsif node['init_package'] == 'systemd'
  template '/lib/systemd/system/zabbix-agent.service' do
    source 'zabbix-agent.service.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  # RHEL package names it "zabbix-agent"
  service 'zabbix_agentd' do
    service_name 'zabbix-agent'
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end
else
  package 'redhat-lsb-core' if platform_family?('rhel')

  template '/etc/init.d/zabbix_agentd' do
    source value_for_platform_family(['rhel'] => 'zabbix_agentd.init-rh.erb', 'default' => 'zabbix_agentd.init.erb')
    owner 'root'
    group 'root'
    mode '754'
  end

  # Define zabbix_agentd service
  service 'zabbix_agentd' do
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end
end
