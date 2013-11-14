if node['graphite']['apache']['mod_wsgi']
  include_recipe "apache2::mod_wsgi"

  template "#{node['graphite']['base_dir']}/conf/graphite.wsgi" do
    mode 0755
  end
else
  include_recipe "apache2::mod_python"
end

include_recipe "apache2::mod_headers"
if node['graphite']['ssl']['enabled']
  include_recipe "apache2::mod_ssl"
end

execute "create apache basic_auth file for graphite" do
  command "htpasswd -bc #{node['graphite']['apache']['basic_auth']['file_path']} #{node['graphite']['apache']['basic_auth']['user']} #{node['graphite']['apache']['basic_auth']['pass']}"
  only_if { node['graphite']['apache']['basic_auth']['enabled'] }
end

template "#{node['apache']['dir']}/sites-available/graphite" do
  unless node['graphite']['apache']['vhost']['cookbook'].nil?
    cookbook node['graphite']['apache']['vhost']['cookbook']
  end
  source node['graphite']['apache']['vhost']['source']
  notifies :reload, "service[apache2]"
end

apache_site "graphite"

apache_site "000-default" do
  enable false
end
