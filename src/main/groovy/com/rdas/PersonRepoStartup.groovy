package com.rdas

import com.rdas.domain.Address
import com.rdas.domain.Person
import com.rdas.repo.PersonRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Component

import javax.annotation.PostConstruct

/**
 * This is a setup data
 * Created by rdas on 30/07/2016.
 */
@Component
class PersonRepoStartup {

    @Autowired
    private PersonRepository repository;

    @Autowired
    private PasswordEncoder passwordEncoder

    @PostConstruct
    void init() {
        repository.deleteAll();


        Person arthur = new Person(id: 1, firstName: 'Arthur', lastName: 'Dent', username: 'adent', password: 'adent', address: new Address(planet: 'Earth'))
        Person trillian = new Person(id: 2, firstName: 'Trillian', lastName: 'McMillan', username: 'tmcmillan', password: 'tmcmillan', address: new Address(planet: 'Earth'))
        Person ford = new Person(id: 3, firstName: 'Ford', lastName: 'Prefect', username: 'fprefect', password: 'fprefect', address: new Address(planet: 'Betelgeuse 5'))
        repository.save(arthur)
        repository.save(trillian)
        repository.save(ford)
        /*
        Person arthur = new Person(id: 1, firstName: 'Arthur', lastName: 'Dent', username: 'adent', password: passwordEncoder.encode('adent'), address: new Address(planet: 'Earth'))
        Person trillian = new Person(id: 2, firstName: 'Trillian', lastName: 'McMillan', username: 'tmcmillan', password: passwordEncoder.encode('tmcmillan'), address: new Address(planet: 'Earth'))
        Person ford = new Person(id: 3, firstName: 'Ford', lastName: 'Prefect', username: 'fprefect', password: passwordEncoder.encode('fprefect'), address: new Address(planet: 'Betelgeuse 5'))
         */
    }
}
