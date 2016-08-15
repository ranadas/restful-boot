package com.rdas.spring.repository;

import com.rdas.domain.Person;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import javax.annotation.PostConstruct;
import java.util.Optional;

/**
 * Created by rdas on 15/08/2016.
 */
@Repository
public class SqlRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final String sql = "SELECT * FROM Person WHERE username = ?";

    @PostConstruct
    public void init() {
        assert jdbcTemplate != null;
    }

    public Optional<Person> getPersonForUSername(String username) {
        Person person = jdbcTemplate.queryForObject(sql,
                (rs, rowNum) -> {
                    Person user = new Person();
                    user.setFirstName(rs.getString("first_name"));
                    user.setLastName(rs.getString("last_name"));

                    return user;
                },
                username);

        return Optional.of(person);
    }

}
