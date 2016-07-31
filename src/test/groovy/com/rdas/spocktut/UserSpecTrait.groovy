package com.rdas.spocktut

import com.rdas.spring.model.User
import org.junit.After
import org.junit.Before

/**
 * https://github.com/spockframework/spock/tree/master/spock-specs/src/test2.4/groovy/org/spockframework/smoke/traits
 * Created by rdas on 30/07/2016.
 */
trait UserSpecTrait {
    User user

    @Before
    def setupUserSpec() {
        user = new User(id: 100, password: "pwd")
        println "\n->Setting up in Trait."
    }

    @After
    def cleanupUserSpec() {
        println "Cleaning up in Trait."
    }

    void setUser(User user) {
        this.user = user
    }

    User getUser() {
        return this.user
    }
}