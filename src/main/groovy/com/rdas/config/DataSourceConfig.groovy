package com.rdas.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseBuilder
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseType

import javax.sql.DataSource

/**
 * Created by rdas on 01/08/2016.
 */
@Configuration
public class DataSourceConfig {
    @Bean(name = "mainDataSource")
    public DataSource createMainDataSource() {

        return new EmbeddedDatabaseBuilder()
                .setType(EmbeddedDatabaseType.HSQL)
                .setName("restweb")
//                .addScript("classpath:schema.sql")
//                .addScript("classpath:test-data.sql")
                .build();
    }

}
