package 'ferm'

cookbook_file '/etc/ferm/ferm.conf' do
  source "ferm.conf"
  mode 0644
  owner "root"
  group "adm"
  notifies :reload, "service[ferm]"
end

service "ferm" do
  action [:enable, :start]
  supports [:reload]
  reload_command "service ferm reload"
end

file '/etc/sysctl.d/60-cephco-gw.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<-EOH
net.ipv4.ip_forward=1
#net.ipv6.conf.all.forwarding=1
  EOH
  notifies :reload, "service[procps]"
end

service "procps" do
  action [:enable, :start]
  supports [:reload]
  reload_command "service procps reload"
end

package 'iptstate'
