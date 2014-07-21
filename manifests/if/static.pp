# == Definition: network::if::static
#
# Creates a normal interface with static IP address.
#
# === Parameters:
#
#   $ensure        - required - up|down
#   $ipaddress     - required
#   $netmask       - required
#   $gateway       - optional
#   $macaddress    - optional - defaults to macaddress_$title
#   $userctl       - optional - defaults to false
#   $mtu           - optional
#   $ethtool_opts  - optional
#   $peerdns       - optional
#   $dns1          - optional
#   $dns2          - optional
#   $domain        - optional
#   $enable_ipv6   - optional - defaults to false
#   $ipv6_autoconf - optional - defaults to yes
#   $ipv6addr      - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if::static { 'eth0':
#     ensure     => 'up',
#     ipaddress  => '10.21.30.248',
#     netmask    => '255.255.255.128',
#     macaddress => $::macaddress_eth0,
#     domain     => 'is.domain.com domain.com',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network::if::static (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway       = '',
  $macaddress    = '',
  $userctl       = false,
  $mtu           = '',
  $ethtool_opts  = '',
  $peerdns       = false,
  $dns1          = '',
  $dns2          = '',
  $domain        = '',
  $enable_ipv6   = false,
  $ipv6_autoconf = 'yes',
  $ipv6addr
) {
  # Validate our data
  if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }

  if ! is_mac_address($macaddress) {
    $macaddy = getvar("::macaddress_${title}")
  } else {
    $macaddy = $macaddress
  }
  # Validate booleans
  validate_bool($userctl)
  
  # Validate IPv6 data
  if $enable_ipv6 {
    $yesno  = [ '^yes$', '^no$' ]
    validate_re($ipv6_autoconf, $yesno, '$ipv6_autoconf must be either "yes" or "no".')
    
    if $ipv6_autoconf == 'no' {
      if ! validate_ipv6_address($ipv6addr) { fail("${$ipv6addr} is not an IPv6 address.") }
    }
  }

  network_if_base { $title:
    ensure        => $ensure,
    ipaddress     => $ipaddress,
    netmask       => $netmask,
    gateway       => $gateway,
    macaddress    => $macaddy,
    bootproto     => 'none',
    userctl       => $userctl,
    mtu           => $mtu,
    ethtool_opts  => $ethtool_opts,
    peerdns       => $peerdns,
    dns1          => $dns1,
    dns2          => $dns2,
    domain        => $domain,
    if $enable_ipv6 {
      ipv6init      => 'yes',
      ipv6_autoconf => $ipv6_autoconf,
      ipv6addr      => $ipv6addr,
    }
  }
} # define network::if::static
