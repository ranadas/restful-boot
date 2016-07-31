package com.rdas.spocktut

import com.rdas.spring.model.User
import org.apache.commons.lang3.StringUtils
import spock.lang.IgnoreIf
import spock.lang.Narrative
import spock.lang.Specification
import spock.lang.Title
import spock.lang.Unroll

/**
 * Created by rdas on 29/07/2016.
 */
@Title('This test will test documenting features of Spock Framework')
@Narrative('''
As a Developer using Spock Framework for testing,
''')
class ListTest extends Specification implements UserSpecTrait {

    private static boolean isOsWindows() {
        def osName = System.properties['os.name']
        println " checking if osName is windows [$osName]"
        return StringUtils.containsIgnoreCase(osName, "wind")
    }

// this is called after junit setup ( setup from trait)
    def setup() {
        println "\t------------>>> Specification SETUP"
    }

    def "should not be empty after adding element"() {
        given:
        def list = []

        when:
        list.add(42)

        then:
        // Asserts are implicit and not need to be stated.
        // Change "==" to "!=" and see what's happening!
        list.size() == 1
        list == [42]
    }

    @Unroll
    def 'should select max of two numbers ( #a and #b )'() {
        expect:
        Math.max(a, b) == c

        where:
        a | b | c // these are vars will be available above in test,
        5 | 1 | 5 // initialized to these values!
        9 | 9 | 9
    }

    @IgnoreIf({ ListTest.isOsWindows() })
    def "run only if run on non-windows operating system"() {
        expect:
        true
        println "running test in non win os"
    }

    @IgnoreIf({ javaVersion < 1.7 })
    def "run spec if run in Java 1.7 or higher"() {
        expect:
        true
        println "running test when javaVersion is GT 1.7 with user from trait $user"
    }

    @IgnoreIf({ javaVersion != 1.7 })
    def "run spec if run in Java 1.7"() {
        expect:
        true
        println "running test "
    }
}
