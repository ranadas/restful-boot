package com.rdas.spocktut

import com.rdas.spring.model.User
import org.junit.After
import org.junit.Before

/**
 * Created by rdas on 30/07/2016.
 */
trait UserSpecTrait {
    User user

    @Before
    def setupUserSpec() {
        println "\n->Setting up in Trait."
        user = new User(id: 100, password: "pwd")
    }

    @After
    def cleanupUserSpec() {
        println "Cleaning up in Trait."
    }
}