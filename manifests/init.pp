# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include samba
class samba (
  Optional[String] $share_path,
  Optional[String] $share_permissions,
  Optional[String] $smb_config_location,
) {
  # Install necessary packages
  package { ['samba', 'samba-common', 'samba-client']:
    ensure => 'present',
  }

  # Enable samba service
  service { 'smb':
    ensure => 'present',
    enable => true,
  }

  # Ensure share directory exists
  file { $share_path:
    ensure => 'directory',
    owner  => 'nobody',
    group  => 'nobody',
    mode   => $share_permissions,
  }

  # Change SELinux context for samba share
  selinux::fcontext { 'set-samba-share-context':
    seltype  => 'samba_share_t',
    pathspec => $share_path,
  }

  # Set samba config
  file { $smb_config_location:
    ensure  => 'file',
    content => epp('samba/smb.conf.epp', {
        'share_name'                => $share_name,
        'share_description'         => $share_description,
        'share_path'                => $share_path,
        'share_read_only'           => $share_read_only,
        'share_inherit_permissions' => $share_inherit_permissions,
        'server_log_path'           => $server_log_path,
        'server_log_level'          => $server_log_level,
        'server_role'               => $server_role,
    }),
  }

  # Allow samba from the public zone
  firewalld_service { 'Allow Samba from the public zone':
    ensure  => 'present',
    service => 'samba',
    zone    => 'public',
  }
}
