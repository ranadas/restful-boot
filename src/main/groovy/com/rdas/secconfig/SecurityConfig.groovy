package com.rdas.secconfig

import com.rdas.service.PersonDetailService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder

/**
 * Created by rdas on 31/07/2016.
 * http://www.concretepage.com/spring/spring-security/spring-mvc-security-jdbc-authentication-example-with-custom-userdetailsservice-and-database-tables-using-java-configuration
 */
@Configuration
@EnableGlobalMethodSecurity(prePostEnabled = true)
@EnableWebSecurity
class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private PersonDetailService personDetailService

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests().anyRequest().fullyAuthenticated();
        http.httpBasic();
        http.csrf().disable();
        /*
        http.authorizeRequests().antMatchers("/admin/**")
		.access("hasRole('ROLE_ADMIN')").and().formLogin()
		.loginPage("/login").failureUrl("/login?error")
		.usernameParameter("username")
		.passwordParameter("password")
		.and().logout().logoutSuccessUrl("/login?logout")
		.and().csrf()
		.and().exceptionHandling().accessDeniedPage("/403");
         */
    }

    //curl admin:pwd@localhost:8080/persons
    @Autowired
    public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(personDetailService)
                //TODO passwordEncoder(passwordEncoder())



//        auth.inMemoryAuthentication()
//                .withUser("user").password("password").roles("USER").and()
//                .withUser("admin").password("pwd").roles("ADMIN", "USER")
    }

    //http://www.baeldung.com/spring-security-registration-password-encoding-bcrypt
    //https://www.javacodegeeks.com/2016/05/spring-boot-database-initialization.html
    //http://shout.setfive.com/2015/11/02/spring-boot-authentication-with-custom-http-header/
    @Bean
    public PasswordEncoder passwordEncoder(){
        //ShaPasswordEncoder encoder = new ShaPasswordEncoder();
        PasswordEncoder encoder = new BCryptPasswordEncoder();
        return encoder;
    }
}
