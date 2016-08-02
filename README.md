Alt-H2 Simple Spring Boot REST application ( with spring-boot-starter-web & spring-boot-starter-data-jpa) .
#### H4 This Features:
 * With Jetty 9+ ( not default Tomcat)
 * with hsql for jpa persistence
 * Lombok, guava,
 * Spock testing with fest assertions
 * pock-reports - WIP
 * TODO : swagger, spring-boot-devtools


To use env variables, add to environment.groovy json. Slurp the json in build.gradle & explicitly inject to system property as :
** systemProperty "foo", "barValurFromGradle2"

Then in test use
** System.getProperty("foo")



Also use a trait. As used in ListTest Specification.

git push -u origin master

Baeldung :
https://github.com/eugenp
https://www.youtube.com/watch?v=5upNjkPvXLs&feature=youtu.be&__s=eqp5kaymrqs5nykfbjed
https://github.com/eugenp/REST-With-Spring/tree/0d8e0dd2ad034e8cf89535a3778e815b6f897fba/common/src/main/java/org/baeldung/common/web
https://github.com/eugenp/REST-With-Spring/blob/0d8e0dd2ad034e8cf89535a3778e815b6f897fba/common/src/main/java/org/baeldung/common/security/SpringSecurityUtil.java



 * TODO : https://www.jayway.com/2014/07/04/integration-testing-a-spring-boot-application/
 * https://spring.io/blog/2016/04/15/testing-improvements-in-spring-boot-1-4


https://leanpub.com/spockframeworknotebook/read

https://github.com/dfrommi/blog-samples

spock with  environment variavles.
http://www.frommknecht.net/spring-spock-docker-integration/
https://github.com/dfrommi/blog-samples/blob/master/spring-spock-docker-integration/


https://dzone.com/articles/spock-and-testing-restful-api

http://stackoverflow.com/questions/35783877/how-can-intellij-run-gradle-task-as-test

//https://kamwo.me/java-load-file-from-classpath-in-spring-boot/