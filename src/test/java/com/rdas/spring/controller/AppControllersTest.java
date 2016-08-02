package com.rdas.spring.controller;

import com.rdas.WebJsSpringBootApplication;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.IntegrationTest;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import static org.fest.assertions.api.Assertions.assertThat;
import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Created by rdas on 01/08/2016.
 * https://github.com/royclarkson/spring-rest-service-oauth/blob/master/src/test/java/hello/GreetingControllerTest.java
 */
@DirtiesContext
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = WebJsSpringBootApplication.class)   // 2
@WebAppConfiguration   // 3
@IntegrationTest("server.port:0")   // 4
public class AppControllersTest {

    @Autowired
    WebApplicationContext wac;

    private MockMvc mockMvc;

    @Before
    public void setup() {

        MockitoAnnotations.initMocks(this);

        mockMvc = MockMvcBuilders
                .webAppContextSetup(wac)
                .apply(springSecurity())
                .build();
        //http://www.disasterarea.co.uk/blog/testing-with-mock-users-in-spring-spring-mvc/
        SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken("adent", "adent"));
    }

    @Test
    public void getAllPersonaAndAssertUserNameFromResponse() throws Exception {
        MvcResult result = this.mockMvc
                .perform(get("/persons"))
                .andDo(print())
                .andExpect(status().isOk())
//                .andExpect(content().contentTypeCompatibleWith(MediaType.TEXT_HTML))
                .andReturn();
        String content = result.getResponse().getContentAsString();
        assertThat(content).isNotNull();
        assertThat(content.contains("Arthur")).isTrue();
        assertThat(content.contains("Dent")).isTrue();
    }
}
