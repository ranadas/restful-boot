package com.rdas.repo

import com.rdas.WebJsSpringBootApplication
import com.rdas.domain.Person
import com.rdas.spring.repository.SqlRepository
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.SpringApplicationConfiguration
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner

import static org.fest.assertions.api.Assertions.assertThat

/**
 * Created by rdas on 30/07/2016.
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = WebJsSpringBootApplication.class)
public class PersonRepositoryTest {

    @Autowired
    private PersonRepository personRepository

    @Autowired
    private GenericSqlDomainRepository sqlDomainRepository

    @Autowired
    private SqlRepository sqlRepository;

    @Before
    public void setup() {
        println "\n-->> sys prop foo set to [" + System.getProperty("foo") + "]-"
        println "\n-->> sys prop host set to [" + System.getProperty("host") + "]-"
    }

    @Test
    public void testNonNullRepo() {
        assertThat(personRepository).isNotNull()
    }

    @Test
    public void assertThreePersonsByFindAll() {
        assertThat(personRepository.count()).isEqualTo(3)
        personRepository.findAll().each { it ->
            println it
        }
    }

    @Test
    public void findArthurByFirstName() {
        Person arthur = personRepository.findByFirstName("Arthur")
        assertThat(arthur).isNotNull()
    }

    @Test
    public void findArthurByLastName() {
        def personList = personRepository.findByLastName("Prefect")
        assertThat(personList.size()).isEqualTo(1)
    }

    @Test
    public void findPersonByAddress() {
        def person = personRepository.findByAddressPlanet("Earth")
        assertThat(person).isNotNull()
        println person
    }


    @Test
    public void findPersonByUsername() {
        def person = personRepository.findByUsername("adent")
        assertThat(person.isPresent()).isTrue()
        println person
    }

    @Test
    public void findPersonBySql() {
        //adent
        def persons = sqlDomainRepository.getAdvancedPersons("adent")
        assertThat(persons).isNotNull()
    }

    @Test
    public void findPersonUsername() {
        //adent
        def persons = sqlRepository.getPersonForUSername("adent")
        assertThat(persons).isNotNull()
    }
}