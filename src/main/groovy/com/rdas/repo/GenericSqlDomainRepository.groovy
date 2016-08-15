package com.rdas.repo

import com.rdas.domain.Person
import com.rdas.repo.mapper.PersonRowMapper
import groovy.util.logging.Slf4j
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.stereotype.Repository

import javax.annotation.PostConstruct

/**
 * Created by rdas on 14/08/2016.
 */
@Slf4j
@Repository
public class GenericSqlDomainRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate

    private static final String sql = "SELECT * FROM Person WHERE username = ?"
    @PostConstruct
    public void init() {
        assert jdbcTemplate != null
    }

    def getAdvancedPersons(username) {
        Person person = (Person) jdbcTemplate.queryForObject(sql, new PersonRowMapper(), username)

        // Method 2 very easy
        //  Employee employee = (Employee) jdbcTemplate.queryForObject(sql, new Object[] { id }, new BeanPropertyRowMapper(Employee.class));
        return person
    }
}
