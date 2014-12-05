roles: 
  - "controller"
  - "network"
  - "storage"
  - "compute"
compute: 
  - "jcore-cumulus18.englab.juniper.net"
  - "jcore-cumulus19.englab.juniper.net"
controller: 
  - "jcore-cumulus17.englab.juniper.net"
network: 
  - "jcore-cumulus17.englab.juniper.net"
storage:
  - "jcore-cumulus17.englab.juniper.net"
sls: 
  controller: 
    - "mysql"
    - "mysql.client"
    - "mysql.openstack_dbschema"
    - "queue.rabbit"
    - "keystone"
    - "keystone.openstack_tenants"
    - "keystone.openstack_users"
    - "keystone.openstack_services"
    - "nova"
    - "horizon"
    - "glance"
    - "cinder"
  network: 
    - "mysql.client"
    - "neutron"
    - "neutron.service"
    - "neutron.openvswitch"
    - "neutron.ml2"
    - "neutron.guest_mtu"
  compute: 
    - "mysql.client"
    - "nova.compute_kvm"
    - "neutron.openvswitch"
    - "neutron.ml2"
  storage:
    - "cinder.volume"
