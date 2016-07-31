//gradle clean test -Penv=feature
//gradle clean test -Penv=dev
environments {
    dev {
        host = '192.168.33.15'
        port = 8080
        user = 'admin'
        password = 'admin'
    }

    feature {
        host = '10.16.116.71'
        port = 8081
        user = 'mmpriv'
        password = 'MMDefaultpass'
    }
}