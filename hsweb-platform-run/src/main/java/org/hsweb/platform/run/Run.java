package org.hsweb.platform.run;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.webbuilder.sql.TableMetaData;
import org.webbuilder.utils.storage.counter.support.redis.RedisCounter;
import org.webbuilder.utils.storage.instance.LocalCacheStorage;

/**
 * Created by zhouhao on 16-4-12.
 */
@Configuration
@EnableAutoConfiguration
@ComponentScan(basePackages = {"org.hsweb.web", "org.hsweb.platform"})
@MapperScan(basePackages = {"org.hsweb.web.dao"})
@EnableTransactionManagement(proxyTargetClass = true)
public class Run {
    public static void main(String[] args) {
        SpringApplication.run(Run.class, args);
    }
}
