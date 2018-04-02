def whyrun_supported?
  true
end

def load_current_resource
  require 'mysql'
  @current_resource = Chef::Resource::ZabbixDatabase.new(@new_resource.dbname)
  @current_resource.dbname(@new_resource.dbname)
  @current_resource.host(@new_resource.host)
  @current_resource.port(@new_resource.port)
  @current_resource.root_username(@new_resource.root_username)
  @current_resource.root_password(@new_resource.root_password)

  @current_resource.exists = true if database_exists?(
    @current_resource.dbname,
    @current_resource.host,
    @current_resource.port,
    @current_resource.root_username,
    @current_resource.root_password)
end

def database_exists?(dbname, host, port, root_username, root_password)
  exists = false
  db = nil
  connection = false
  begin
    db = ::Mysql.new(host, root_username, root_password, dbname, port)
    connection = true
    # Make sure the last query is completed for database population
    rs = db.query("SELECT sysmap_shapeid FROM sysmap_shape LIMIT 1")
    if rs.num_rows < 1
      raise ::Mysql::Error
    end
    exists = true
    Chef::Log.info("Connection to database '#{dbname}' on '#{host}' successful")
  rescue ::Mysql::Error
    if connection
      Chef::Log.info("Database '#{dbname}' population incomplete, clean database and re-run")
      db.query("DROP DATABASE #{dbname}")
      db.query("CREATE DATABASE #{dbname}")
      Chef::Log.info("successfully dropped table '#{dbname}'")
    else
      Chef::Log.info("Connection to database '#{dbname}' on '#{host}' failed")
    end
  ensure
    db.close unless db.nil?
  end
  exists
end

action :create do
  if @current_resource.exists
    Chef::Log.info("Create #{new_resource.dbname} already exists - Nothing to do")
  else
    Chef::Log.info("Create #{new_resource.dbname} does not exists - Creating Zabbix database")
    converge_by("Create #{new_resource.dbname}") do
      create_new_database
    end
  end
end

def create_new_database
  zabbix_source 'extract_zabbix_database' do
    branch new_resource.branch
    version new_resource.branch
    source_url new_resource.source_url
    code_dir new_resource.source_dir
    target_dir "zabbix-#{new_resource.server_version}"
    install_dir new_resource.install_dir
    branch new_resource.branch
    version new_resource.version

    action :extract_only
  end

  ruby_block 'set_updated' do
    action :nothing
    block do
      new_resource.updated_by_last_action(true)
    end
  end

  #create zabbix database
  execute 'populate_database' do
    action :run
    command "echo 'start populating database for Zabbix'"
    notifies :run, 'execute[zabbix_populate_schema]', :immediately
    notifies :run, 'execute[zabbix_populate_image]', :immediately
    notifies :run, 'execute[zabbix_populate_data]', :immediately
    notifies :create, 'ruby_block[set_updated]', :immediately
  end

  # populate database
  executable = '/usr/bin/mysql'
  root_username = "-u #{new_resource.root_username}"
  root_password = "-p#{new_resource.root_password}"
  host = "-h #{new_resource.host}"
  port = "-P #{new_resource.port}"
  dbname = new_resource.dbname
  sql_command = "#{executable} #{root_username} #{root_password} #{host} #{port} #{dbname}"

  zabbix_path = ::File.join(new_resource.source_dir, "zabbix-#{new_resource.server_version}")
  sql_scripts = if new_resource.server_version.to_f < 2.0
                  Chef::Log.info 'Version 1.x branch of zabbix in use'
                  [
                    ['zabbix_populate_schema', ::File.join(zabbix_path, 'create', 'schema', 'mysql.sql')],
                    ['zabbix_populate_image', ::File.join(zabbix_path, 'create', 'data', 'images_mysql.sql')],
                    ['zabbix_populate_data', ::File.join(zabbix_path, 'create', 'data', 'data.sql')],
                  ]
                else
                  Chef::Log.info 'Version 2.x branch of zabbix in use'
                  [
                    ['zabbix_populate_schema', ::File.join(zabbix_path, 'database', 'mysql', 'schema.sql')],
                    ['zabbix_populate_image', ::File.join(zabbix_path, 'database', 'mysql', 'images.sql')],
                    ['zabbix_populate_data', ::File.join(zabbix_path, 'database', 'mysql', 'data.sql')],
                  ]
                end

  sql_scripts.each do |script_spec|
    script_name = script_spec.first
    script_path = script_spec.last

    execute script_name do
      command "#{sql_command} < #{script_path}"
      action :nothing
    end
  end

  Chef::Log.info("Finished populating Zabbix database #{new_resource.dbname}")
end
