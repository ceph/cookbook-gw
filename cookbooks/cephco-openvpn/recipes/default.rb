package 'openvpn'
package 'gnutls-bin'

directory '/etc/openvpn/cephco-sepia.data' do
  owner 'root'
  group 'root'
  mode '0755'
end

execute "certtool create ca key" do
  command "cd /etc/openvpn/cephco-sepia.data && certtool --generate-privkey --outfile ca.key.tmp && mv ca.key.tmp ca.key"
  creates "/etc/openvpn/cephco-sepia.data/ca.key"
  action :run
end

cookbook_file '/etc/openvpn/cephco-sepia.data/ca.template' do
  source 'ca.template'
  owner 'root'
  group 'root'
  mode '0644'
end

execute "certtool create ca cert" do
  command "cd /etc/openvpn/cephco-sepia.data && certtool --generate-self-signed --load-privkey ca.key --template ca.template --outfile ca.crt.tmp && mv ca.crt.tmp ca.crt"
  creates "/etc/openvpn/cephco-sepia.data/ca.crt"
  action :run
end

execute "certtool create server key" do
  command "cd /etc/openvpn/cephco-sepia.data && certtool --generate-privkey --outfile server.key.tmp && mv server.key.tmp server.key"
  creates "/etc/openvpn/cephco-sepia.data/server.key"
  action :run
end

cookbook_file '/etc/openvpn/cephco-sepia.data/server.template' do
  source 'server.template'
  owner 'root'
  group 'root'
  mode '0644'
end

execute "certtool create server cert" do
  command "cd /etc/openvpn/cephco-sepia.data && certtool --generate-certificate --load-privkey server.key --load-ca-certificate ca.crt --load-ca-privkey ca.key --template server.template --outfile server.crt.tmp && mv server.crt.tmp server.crt"
  creates "/etc/openvpn/cephco-sepia.data/server.crt"
  action :run
end

execute "certtool create dh" do
  command "cd /etc/openvpn/cephco-sepia.data && certtool --generate-dh-params --outfile dh1024.pem.tmp && mv dh1024.pem.tmp dh1024.pem"
  creates "/etc/openvpn/cephco-sepia.data/dh1024.pem"
  action :run
end

cookbook_file '/etc/openvpn/cephco-sepia.data/auth-openvpn' do
  source 'auth-openvpn'
  owner 'root'
  group 'root'
  mode '0755'
end

user 'cephco-openvpn' do
  comment 'OpenVPN server'
  home '/nonexistent'
  system true
  shell '/bin/false'
end

cookbook_file '/etc/openvpn/cephco-sepia.data/users' do
  source 'users'
  owner 'root'
  group 'cephco-openvpn'
  mode '0640'
end

execute "generate random tlsauth" do
  command "cd /etc/openvpn/cephco-sepia.data && openvpn --genkey --secret tlsauth.tmp && chgrp cephco-openvpn tlsauth.tmp && chmod ug=r,o= tlsauth.tmp && mv tlsauth.tmp tlsauth"
  creates "/etc/openvpn/cephco-sepia.data/tlsauth"
  action :run
end

cookbook_file '/etc/openvpn/cephco-sepia.conf' do
  source 'cephco-sepia.conf'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[openvpn]"
end

cookbook_file '/etc/openvpn/cephco-sepia.data/client.conf' do
  source 'client.conf'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/etc/openvpn/cephco-sepia.data/new-client' do
  source 'new-client'
  owner 'root'
  group 'root'
  mode '0644'
end

execute "generate cephco-sepia-client.tar.gz" do
  command "cd /etc/openvpn/cephco-sepia.data && tar cf client.tar --owner=root --group=root --transform 's,^,cephco-sepia.client/,' tlsauth ca.crt client.conf && tar rf client.tar --owner=root --group=root --transform 's,^,cephco-sepia.client/,' --mode=0755 new-client && gzip <client.tar >client.tar.gz.tmp && rm client.tar && mv client.tar.gz.tmp cephco-sepia-client.tar.gz"
  creates "/etc/openvpn/cephco-sepia.data/cephco-sepia-client.tar.gz"
  action :run
end

service "openvpn" do
  action [:enable, :start]
end
