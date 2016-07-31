package com.rdas;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

/**
 * Created by rdas on 29/07/2016.
 */
//@EnableSwagger2 //TODO: enabling this, test fails.
@Slf4j
@SpringBootApplication
public class WebJsSpringBootApplication {
    public static void main(String[] args) throws Exception {
        SpringApplication.run(WebJsSpringBootApplication.class, args);
    }
}
