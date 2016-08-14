package com.rdas.domain

import groovy.transform.ToString
import lombok.AllArgsConstructor
import lombok.Getter
import lombok.NoArgsConstructor
import lombok.Setter

import javax.persistence.Embedded
import javax.persistence.Entity
import javax.persistence.Id

/**
 * Created by rdas on 30/07/2016.
 * TODO : excludes is not working yet!!
 */
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString(includeNames = true, excludes = "username,password")
class Person {
    @Id
    String id

    String firstName
    String lastName
    String username
    String password

    @Embedded
    Address address
}
