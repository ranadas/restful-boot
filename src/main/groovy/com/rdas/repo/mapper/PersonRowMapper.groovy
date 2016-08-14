package com.rdas.repo.mapper

import com.rdas.domain.Person
import org.springframework.jdbc.core.RowMapper

import java.sql.ResultSet
import java.sql.SQLException


/**
 * Created by rdas on 14/08/2016.
 */
public class PersonRowMapper implements RowMapper<Person> {

    @Override
    Person mapRow(ResultSet rs, int rowNum) throws SQLException {
        Person person = new Person();
        person.setFirstName(rs.getString("first_name"))
        person.setLastName(rs.getString("last_name"))
        return person;
    }
}
