# == Class: tweaks_and_fixes
#
# Tweaks and fixes to several minor problems:
#
# *Enable Serial Port Access; 
# *Fix PulseAudio;
# *Remove LightLocker;
# *Remove Amazon Search;
# *Hide Update Notifier;
# *Add Launcher Defaults.
#
class tweaks_and_fixes (
  $do_grant_serial_port_access = $tweaks_and_fixes::params::do_grant_serial_port_access,
  $do_fix_pulseaudio           = $tweaks_and_fixes::params::do_fix_pulseaudio,
  $do_remove_lightlocker       = $tweaks_and_fixes::params::do_remove_lightlocker,
  $do_remove_amazon            = $tweaks_and_fixes::params::do_remove_amazon,
  $do_hide_update_notifier     = $tweaks_and_fixes::params::do_hide_update_notifier,
  $do_add_launcher_defaults    = $tweaks_and_fixes::params::do_add_launcher_defaults,
) inherits tweaks_and_fixes::params {

# Grant serial port access.
  if $do_grant_serial_port_access {
    file{ '/etc/udev/rules.d/99-serial.rules':
      owner   => root,
      group   => root,
      ensure  => present,
      mode    => "0644",
      source  => "puppet:///modules/tweaks_and_fixes/99-serial.rules",
    }
  }

  # Fix for pulse audio on 14.04 with the samba mounted home stores as we can't chgrp on them for some reason.
  if $do_fix_pulseaudio {

    #TODO: Rather than create the directories if they don't exist (which implies pulseaudio is not installed),
    #      we should instead skip this installation. 
    file{ ['/etc/xdg/','/etc/xdg/autostart/']:
      ensure  => directory,
    }

    file{ '/etc/xdg/autostart/pulseaudio.desktop':
      owner   => root,
      group   => root,
      ensure  => present,
      mode    => "0644",
      source  => "puppet:///modules/tweaks_and_fixes/pulseaudio.desktop",
    }

    file{ '/usr/local/bin/start-pulseaudio-in-tmp':
      owner   => root,
      group   => root,
      ensure  => present,
      mode    => "0755",
      source  => "puppet:///modules/tweaks_and_fixes/start-pulseaudio-in-tmp",
    }
  }

  # Remove light-locker as it does silly things when you lock the screen
  if $do_remove_lightlocker {
    package {['light-locker', 'light-locker-settings']:
      ensure => purged,
    }
  }

  # Remove amazon search crap
  if $do_remove_amazon {
    require dconf_profile

    file{'/etc/dconf/db/local.d/amazon.keys':
      ensure => present,
      source => 'puppet:///modules/tweaks_and_fixes/amazon.keys',
    } ->

    # Unfortunately must use exec here. There is no alternative.
    exec{'dconf-update-amazon':
      command     => '/usr/bin/dconf update',
      subscribe   => File['/etc/dconf/db/local.d/amazon.keys'],
      refreshonly => true,
    }
  }

  # Don't show update notifier, nobody can run updates...
  if $do_hide_update_notifier {
    require dconf_profile

    file{'/etc/dconf/db/local.d/noupdates.keys':
      ensure => present,
      source => 'puppet:///modules/tweaks_and_fixes/noupdates.keys',
    } ->

    # Unfortunately must use exec here. There is no alternative.
    exec{'dconf-update-noupdates':
      command     => '/usr/bin/dconf update',
      subscribe   => File['/etc/dconf/db/local.d/noupdates.keys'],
      refreshonly => true,
    }
  }

  # Add some useful favourites to the launcher and remove some we can't/don't use.
  if $do_add_launcher_defaults {
    require dconf_profile

    file{'/etc/dconf/db/local.d/favourites.keys':
      ensure => present,
      source => 'puppet:///modules/tweaks_and_fixes/favourites.keys',
    } ->

    # Unfortunately must use exec here. There is no alternative.
    exec{'dconf-update-favourites':
      command     => '/usr/bin/dconf update',
      subscribe   => File['/etc/dconf/db/local.d/favourites.keys'],
      refreshonly => true,
    }
  }
}
