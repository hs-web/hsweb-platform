package org.hsweb.platform.run;


import org.hsweb.platform.workflow.modeler.ActivityModelerAutoConfigure;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.test.ImportAutoConfiguration;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Created by zhouhao on 16-4-12.
 */
@Configuration
@EnableAutoConfiguration
@ComponentScan(
        basePackages = {"org.hsweb.web", "org.hsweb.platform"}
)
@MapperScan(basePackages = {"org.hsweb.web.dao"})
@EnableTransactionManagement(proxyTargetClass = true)
@EnableCaching
@ImportAutoConfiguration(ActivityModelerAutoConfigure.class)
public class Run {
    public static void main(String[] args) {
        SpringApplication.run(Run.class, args);
    }

}
