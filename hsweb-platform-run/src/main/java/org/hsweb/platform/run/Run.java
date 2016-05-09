package org.hsweb.platform.run;


import org.hsweb.web.controller.DefaultErrorController;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.cache.CacheAutoConfiguration;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Created by zhouhao on 16-4-12.
 */
@Configuration
@EnableAutoConfiguration
@ComponentScan(basePackages = {"org.hsweb.platform"})
@EnableTransactionManagement(proxyTargetClass = true)
@EnableCaching
public class Run {
    public static void main(String[] args) {
        SpringApplication.run(Run.class, args);
    }

}
