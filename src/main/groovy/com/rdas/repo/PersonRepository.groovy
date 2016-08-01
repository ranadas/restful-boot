package com.rdas.repo

import com.rdas.domain.Person
import org.springframework.data.jpa.repository.JpaRepository

/**
 * Created by rdas on 30/07/2016.
 */
public interface PersonRepository extends JpaRepository<Person, String> {
    Person findByFirstName(String firstName)

    List<Person> findByLastName(String lastName)

    List<Person> findByAddressPlanet(String planet)

    Optional<Person> findByUsername(String username)
}
