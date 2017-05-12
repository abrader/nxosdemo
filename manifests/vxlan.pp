# Demo class for representing EVPN examples

class nxosdemo::vxlan {
    # Purely for demo purposes, line would be higher in stack
    require ciscopuppet::install

    cisco_vlan { '10' :
      ensure     => present,
      mapped_vni => '5510010',
      vlan_name  => 'L3VNI',
      state      => 'active',
      shutdown   => false,
    }

    cisco_vrf { 'prod' :
      ensure              => present,
      description         => 'VXLAN VRF prod',
      route_distinguisher => 'auto',
    }

    cisco_interface { 'Vlan10' :
      ensure          => present,
      interface       => 'Vlan10',
      shutdown        => false,
      description     => 'L3VNI',
      mtu             => 9216,
      vrf             => 'prod',
      ipv4_forwarding => true,
      require         => [ Cisco_vlan['10'] , Cisco_vrf['prod'] ],
    }

    cisco_vxlan_vtep { 'nve1' :
      ensure                          => present,
      description                     => 'NVE Overlay Interface',
      host_reachability               => 'evpn',
      shutdown                        => false,
      source_interface                => 'loopback1',
      source_interface_hold_down_time => 360,
    }

    # L3VNI
    cisco_vxlan_vtep_vni { 'nve1 5510010' :
      ensure    => present,
      assoc_vrf => true,
      require   => Cisco_vlan['10'],
    }

    cisco_vlan { '102' :
      ensure     => present,
      vlan_name  => 'EVPN_VNI_Test',
      mapped_vni => '5510102',
      state      => 'active',
      shutdown   => false,
    }

    cisco_vxlan_vtep_vni { 'nve1 5510102' :
      ensure          => present,
      assoc_vrf       => false,
      multicast_group => '239.96.240.102',
      suppress_arp    => true,
    }
  }
