#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

yum_package "pcre-devel" do
  action :install
end

yum_package "openssl-devel" do
  action :install
end

cookbook_file "#{node['apache']['src_dir']}#{node['apr']['version']}.tar.gz" do
  mode 0644
end

cookbook_file "#{node['apache']['src_dir']}#{node['apr_util']['version']}.tar.gz" do
  mode 0644
end

cookbook_file "#{node['apache']['src_dir']}#{node['apache']['version']}.tar.gz" do
  mode 0644
end

bash "install apache" do
  user     node['apache']['install_user']
  cwd      node['apache']['src_dir']
  not_if   "ls #{node['apache']['dir']}"
  notifies :run, 'bash[start apache]', :immediately
  code   <<-EOH
    tar xzf #{node['apache']['version']}.tar.gz
    
    ## apache2.4 requires apr, apr-util
    ## httpd automaticall build the decompressed apr and apr-util under the srclib dir
    tar xzf #{node['apr']['version']}.tar.gz
    tar xzf #{node['apr_util']['version']}.tar.gz
    mv #{node['apr']['version']} #{node['apache']['version']}/srclib/apr
    mv #{node['apr_util']['version']} #{node['apache']['version']}/srclib/apr-util

    cd #{node['apache']['version']}
    ./configure #{node['apache']['configure']}
    make
    make install
  EOH
end

bash "teardown apache" do
  user     node['apache']['install_user']
  cwd      node['apache']['src_dir']
  not_if   "ls #{node['apache']['symbolic']}"
  code   <<-EOH
    mkdir -p #{node['apache']['dir']}/conf/conf.d
    ln -s #{node['apache']['dir']} #{node['apache']['symbolic']}
  EOH
end

template "#{node['apache']['dir']}conf/conf.d/localhost.conf" do
  source "localhost.conf.erb"
  owner node['apache']['install_user']
  group node['apache']['install_group']
  mode 00644
  #notifies :run, 'bash[restart apache]', :immediately
end

for include_file in node['apache']['include_files']
  template "#{node['apache']['dir']}conf/extra/#{include_file}.conf" do
    source   "#{include_file}.conf.erb"
    owner    node['apache']['install_user']
    group    node['apache']['install_group']
    mode     00644
    #notifies :run, 'bash[restart apache]', :immediately
  end
end

template "#{node['apache']['dir']}conf/httpd.conf" do
  source   "httpd.conf.erb"
  owner    node['apache']['install_user']
  group    node['apache']['install_group']
  mode     00644
  notifies :run, 'bash[restart apache]', :immediately
end

bash "start apache" do
  action :nothing
  flags  '-ex'
  user   node['apache']['install_user']
  code   <<-EOH
    #{node['apache']['dir']}bin/apachectl start
  EOH
end

bash "restart apache" do
  action :nothing
  flags  '-ex'
  user   node['apache']['install_user']
  code   <<-EOH
    #{node['apache']['dir']}bin/apachectl restart
  EOH
end
