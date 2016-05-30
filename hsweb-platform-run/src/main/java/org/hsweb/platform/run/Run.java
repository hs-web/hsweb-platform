package org.hsweb.platform.run;


import org.hsweb.web.controller.login.AuthorizeController;
import org.hsweb.web.core.authorize.AopAuthorizeValidator;
import org.hsweb.web.core.session.siample.UserLoginOutListener;
import org.hsweb.web.socket.cmd.support.SystemMonitorProcessor;
import org.hsweb.web.socket.message.WebSocketMessageManager;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
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
//@EnableRedisHttpSession(maxInactiveIntervalInSeconds = 3600)
public class Run {
    public static void main(String[] args) {
        SpringApplication.run(Run.class, args);
    }
}
