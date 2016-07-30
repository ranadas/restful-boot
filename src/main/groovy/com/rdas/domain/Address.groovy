package com.rdas.domain

import groovy.transform.ToString
import lombok.AllArgsConstructor
import lombok.Getter
import lombok.NoArgsConstructor
import lombok.Setter

import javax.persistence.Embeddable

/**
 * https://en.wikibooks.org/wiki/Java_Persistence/Embeddables
 * Created by rdas on 30/07/2016.
 */
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@ToString(includeNames = true)
class Address {

    String planet
}
