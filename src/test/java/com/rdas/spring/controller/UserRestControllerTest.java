package com.rdas.spring.controller;

import com.rdas.WebJsSpringBootApplication;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.runners.MockitoJUnitRunner;
import org.springframework.boot.test.IntegrationTest;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

import static org.fest.assertions.api.Assertions.assertThat;

/**
 * Created by rdas on 23/07/2016.
 *
 * TODO : https://www.jayway.com/2014/07/04/integration-testing-a-spring-boot-application/
 * https://spring.io/blog/2016/04/15/testing-improvements-in-spring-boot-1-4
 */
//@RunWith(MockitoJUnitRunner.class)
//@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@DirtiesContext
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = WebJsSpringBootApplication.class)   // 2
@WebAppConfiguration   // 3
@IntegrationTest("server.port:0")   // 4
public class UserRestControllerTest {

    @Before
    public void setup() {
    }

    @Test
    public void testBasicControllerCall() {
        //assertThat(" ").isNotNull();
        assert 1 == 1;
    }

    
}
