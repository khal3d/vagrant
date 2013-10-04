class params {
    # Hostname of the virtualbox (make sure this URL points to 127.0.0.1 on your local dev system!)
    $host = 'localhost.vm'

    # Original port (don't change)
    $port = '80'

    # Database config
    $db_name = ''
    $db_user = ''
    $db_pass = ''

    include params::mysql
}


class params::mysql {
    mysqldb { "myapp":
        user		=> "myappuser",
        password	=> "5uper5secret",
    }
}