#
# Cookbook Name:: php
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#
# Cookbook Name:: php
# Recipe:: default
#
# Copyright 2013, 
#
# All rights reserved - Do Not Redistribute
#

cookbook_file "#{node['php']['src_dir']}/RPM-GPG-KEY-EPEL-6" do
  source "RPM-GPG-KEY-EPEL-6"
  mode 00644
end

bash "register epel" do
  user     node['php']['install_user']
  cwd      node['php']['src_dir']
  not_if "ls /etc/yum.repos.d/epel.repo"
  code   <<-EOH
    rpm --import RPM-GPG-KEY-EPEL-6
    rm -f RPM-GPG-KEY-EPEL-6
  EOH
end

cookbook_file "/etc/yum.repos.d/epel.repo" do
  source "epel.repo"
  mode 00644
end

cookbook_file "#{node['php']['src_dir']}#{node['php']['version']}.tar.gz" do
  source "#{node['php']['version']}.tar.gz"
  mode 0644
end

cookbook_file "#{node['php']['src_dir']}#{node['libiconv']['version']}.tar.gz" do
  source "#{node['libiconv']['version']}.tar.gz"
  mode 0644
end

cookbook_file "#{node['php']['src_dir']}#{node['re2c']['version']}.tar.gz" do
  source "#{node['re2c']['version']}.tar.gz"
  mode 0644
end

%W{libxml2-devel curl-devel bison}.each do |pkg|
  package pkg do
    action :install
  end
end

yum_package "libmcrypt-devel" do
  options "--enablerepo=epel"
  action :install
end

#bash "install iconv" do
#  user  node['php']['install_user']
#  cwd   node['php']['src_dir']
#  not_if "ls /usr/local/bin/iconv"
#  code <<-EOH
#    tar xzf #{node['libiconv']['version']}.tar.gz
#    cd #{node['libiconv']['version']}
#    ./configure
#    make
#    make install
#
#    echo 'include /usr/local/lib' >> /etc/ld.so.conf
#    /sbin/ldconfig
#  EOH
#end

bash "install re2c" do
  user  node['php']['install_user']
  cwd   node['php']['src_dir']
  code <<-EOH
    tar xzf #{node['re2c']['version']}.tar.gz
    cd #{node['re2c']['version']}
    ./configure
    make
    make install
  EOH
end

configure = node['php']['configure'].join(" ")

bash "install php" do
  user     node['php']['install_user']
  cwd      node['php']['src_dir']
  not_if   "which php"
  code   <<-EOH
    tar xzf #{node['php']['version']}.tar.gz
    cd #{node['php']['version']}
    ./configure #{configure}
    make
    make install
    cp #{node['php']['src_dir']}#{node['php']['version']}/php.ini-production #{node['php']['conf_dir']}php.ini
  EOH
end

bash "upgrade pear" do
  user     node['php']['install_user']
  cwd      node['php']['src_dir']
  code   <<-EOH
    /usr/local/#{node['php']['version']}/bin/pear upgrade
  EOH
end

template "#{node['php']['conf_dir']}php.ini" do
  source   "php.ini.erb"
  owner    node['php']['install_user']
  group    node['php']['install_group']
  mode     00644
end

