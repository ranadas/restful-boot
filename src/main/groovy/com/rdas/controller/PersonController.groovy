package com.rdas.controller

import com.rdas.domain.Person
import com.rdas.repo.PersonRepository
import groovy.util.logging.Slf4j
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*

/**
 * Created by rdas on 30/07/2016.
 */
@RestController
@Slf4j
//@PreAuthorize("hasRole('ROLE_ADMIN')")
@RequestMapping("/persons")
class PersonController {

    @Autowired
    private PersonRepository repository

    //@PreAuthorize("hasRole('ROLE_USER')")
    @RequestMapping(value = "/{id}", method = RequestMethod.GET)
    Person getPersonById(@PathVariable String id) {
        log.info("getPersonById with parameter $id")
        repository.findOne(id)
    }

    /**
     * curl localhost:8080/persons
     */
    @PreAuthorize("hasRole('ROLE_USER')")
    @RequestMapping(method = RequestMethod.GET)
    List<Person> getAllPersons() {
        log.debug("geting all Persons()")
        repository.findAll()
    }

    @RequestMapping(method = RequestMethod.POST)
    Person createPerson(@RequestBody Person newPerson) {
        log.info("createPerson with parameter $newPerson")
        newPerson.id = null
        repository.save(newPerson)
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.PUT)
    Person updatePerson(@PathVariable String id, @RequestBody Person updatedPerson) {
        log.info("updatePerson with parameter $id and $updatedPerson")
        updatedPerson.id = id
        repository.save(updatedPerson)
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.DELETE)
    Person removePerson(@PathVariable String id) {
        log.info("removePerson with parameter $id")
        repository.delete(id)
    }

    //@PreAuthorize("hasRole('ROLE_USER')")
    @RequestMapping(value = "/search/byFirstName/{firstName}", method = RequestMethod.GET)
    Person getPersonByFirstName(@PathVariable String firstName) {
        log.info("getPersonByFirstName with parameter $firstName")
        repository.findByFirstName(firstName)
    }
}
