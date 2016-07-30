package com.rdas.spring.controller;

import com.rdas.WebJsSpringBootApplication;
import com.rdas.spring.model.User;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.runners.MockitoJUnitRunner;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.IntegrationTest;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

import java.util.List;

import static org.fest.assertions.api.Assertions.assertThat;

/**
 * Created by rdas on 23/07/2016.
 *
 */
//@RunWith(MockitoJUnitRunner.class)
//@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@DirtiesContext
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = WebJsSpringBootApplication.class)   // 2
@WebAppConfiguration   // 3
@IntegrationTest("server.port:0")   // 4
public class UserRestControllerTest {

    @Autowired
    private UserRestController  userRestController;

    @Before
    public void setup() {
    }

    @Test
    public void assertThatControllerIsInjected() {
        assertThat(userRestController).isNotNull();
    }

    @Test
    public void assertThatUserListIsNotNull() {
        List<User> users = userRestController.listUsers();
        assertThat(users).isNotNull();
    }
}
