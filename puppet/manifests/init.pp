group { 'puppet': ensure => present }
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
File { owner => 0, group => 0, mode => 0644 }

exec { "apt-update":
    command => "/usr/bin/apt-get update",
}
class { 'stdlib': }

class { 'php':
  service             => 'apache',
  service_autorestart => false,
  module_prefix       => '',
}

php::module { 'php5-mysql': }
php::module { 'php5-cli': }
php::module { 'php5-curl': }
php::module { 'php5-gd': }
php::module { 'php5-intl': }
php::module { 'php5-mcrypt': }
php::module { 'php5-xdebug': }

php::pecl::module { 'xdebug':
    use_package => "no",
}

# node default {
#     include params
# }
# include params

class{'apache':
    default_vhost   => false,
    mpm_module      => 'prefork'
}
class { 'apache::mod::php': }
class { 'apache::mod::rewrite': }

# apache::mod { 'php5': }

apache::vhost { 'localhost.vm':
    vhost_name      => '*',
    port            => '80',
    virtual_docroot => '/var/www/%-2+/web',
    docroot         => '/var/www',
    serveraliases   => ['*.vm'],
    setenv          => ['APP_ENV dev'],
    priority        => '100',
    directories => [ { path => '/var/www', allow_override => ['All'] } ]
}

apache::vhost { 'aqarmap.localhost.vm':
    vhost_name      => '*',
    port            => '80',
    docroot         => '/var/www/aqarmap.localhost/app/webroot',
    setenv          => ['APP_ENV dev'],
    priority        => '0',
    directories => [ { path => '/var/www/aqarmap.localhost/app/webroot', allow_override => ['All'] } ]
}


class { '::mysql::server':
    override_options    => {
        'mysqld'        => { 'max_connections' => '1024' }
    },
    root_password       => '123456'
}

class { '::mysql::server::backup':
    backupuser          => 'backup',
    backuppassword      => '123456',
    backupdir           => '/vagrant/backups',
    backupcompress      => true,
    file_per_database   => true,
    backuprotate        => 7,
    time                => ['20', '0']
}

class { 'phpmyadmin': }
phpmyadmin::vhost { 'phpmyadmin.localhost.vm':
    vhost_enabled => true,
    priority      => '1',
    docroot       => $phpmyadmin::params::doc_path,
    ssl           => false,
}

class { 'composer': }

# Dependencies
$dependencies = [
    'build-essential',
    'curl',
    'git-core'
]
package { $dependencies:
    ensure  => 'installed',
    require => Exec['apt-update'],
}
