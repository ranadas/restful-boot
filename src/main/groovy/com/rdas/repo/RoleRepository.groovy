package com.rdas.repo

import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.stereotype.Component

/**
 * Created by rdas on 01/08/2016.
 */
@Component
public class RoleRepository {

    def getGrantedAuthority(String username) {
        // TODO : create a map of roles e.g. from database.
        //        GrantedAuthority authority = new SimpleGrantedAuthority(userInfo.getRole());
        //List<GrantedAuthority> grantedAuths = new ArrayList<>()
        def grantedAuths = []
        grantedAuths.add(new SimpleGrantedAuthority("ROLE_USER"))
        grantedAuths.add(new SimpleGrantedAuthority("ROLE_ADMIN"))
        return grantedAuths
    }
}
