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
            openstack.juno: "em1"
    vlan: 
      physnets: 
        Internal1: 
          bridge: "br-em1"
          vlan_range: "100:200"
          hosts:
            openstack.juno: "em1"
    gre:
      tunnel_start: "1"
      tunnel_end: "1000"
