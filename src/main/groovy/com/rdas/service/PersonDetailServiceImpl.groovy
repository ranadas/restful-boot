package com.rdas.service

import com.google.common.base.Preconditions
import com.rdas.domain.Person
import com.rdas.repo.PersonRepository
import com.rdas.repo.RoleRepository
import groovy.util.logging.Slf4j
import org.apache.commons.lang3.StringUtils
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Component

/**
 * Created by rdas on 31/07/2016.
 */
@Slf4j
@Component
public final class PersonDetailServiceImpl implements PersonDetailService {
    @Autowired
    private PersonRepository personRepository

    @Autowired
    private RoleRepository roleRepository


    @Override
    UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Preconditions.checkNotNull(username, "User Name cann't be null")
        Preconditions.checkArgument(StringUtils.isNoneBlank(username), "User Name cann't be blank")

        Optional<Person> optionalPerson = personRepository.findByUsername(username)

        if (!optionalPerson.isPresent()) {
            throw new UsernameNotFoundException("User $username not found. ")
        }

        Person person = optionalPerson.get()
        def grantedAuthorities = roleRepository.getGrantedAuthority(username)

        UserDetails userDetails = (UserDetails) new User(person.getUsername(), person.getPassword(), grantedAuthorities);
        return userDetails
    }
}
