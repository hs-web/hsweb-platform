package org.hsweb.platform.run;


import org.hsweb.web.core.authorize.annotation.Authorize;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.IOException;

@Configuration
@EnableAutoConfiguration
@ComponentScan(basePackages = {"org.hsweb.platform"})
@EnableTransactionManagement(proxyTargetClass = true)
@EnableCaching
@Controller
//@EnableRedisHttpSession(maxInactiveIntervalInSeconds = 3600)
public class Run {
    public static void main(String[] args) throws IOException {
        SpringApplication.run(Run.class, args);
    }

    @RequestMapping(value = {"/", "/index.html"})
    @Authorize
    public String index() {
        return "admin/index";
    }

}

