neutron: 
  intergration_bridge: br-int
  metadata_secret: "414c66b22b1e7a20cc35"
  # uncomment to bridge all interfaces to primary interface
  # single_nic : primary_nic_name
  single_nic: "em1"
  # make sure you add eth0 to br-proxy
  # and configure br-proxy with eth0's address
  # after highstate run
  type_drivers: 
    flat: 
      physnets: 
        External: 
          bridge: "br-ex"
          hosts:
            openstack.juno: "eth3"
    vlan: 
      physnets: 
        Internal1: 
          bridge: "br-eth1"
          vlan_range: "100:200"
          hosts:
            openstack.juno: "eth2"
    gre:
      tunnel_start: "1"
      tunnel_end: "1000"
  networks:
    Internal:
      user: admin
      tenant: admin
      admin_state_up: True
      subnets:
        InternalSubnet:
          cidr: '192.168.10.0/24'
          dns_nameservers:
            - '8.8.8.8'
    ExternalNetwork:
      user: admin
      tenant: admin
      provider_physical_network: External
      provider_network_type: flat
      shared: true
      admin_state_up: True
      router_external: true
      subnets:
        ExternalSubnet:
          cidr: '10.8.127.0/24'
          allocation_pools:
            - start: '10.8.127.10'
              end: '10.8.127.30'
          enable_dhcp: false
  routers:
    ExternalRouter:
      user: admin
      tenant: admin
      interfaces:
        - InternalSubnet
      gateway_network: ExternalNetwork
  security_groups:
    Default:
      user: admin
      tenant: admin
      description: 'Default security group'
      rules:
        - direction: ingress
          ethertype: ipv4
          remote_ip_prefix: '10.8.27.0/24'
        - direction: ingress
          remote_ip_prefix: '10.8.127.0/24'
