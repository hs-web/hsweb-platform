package org.hsweb.platform.app;

import org.hsweb.platform.core.Application;
import org.hsweb.platform.core.CommonApplicationContainer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-14.
 */
@Component
@Transactional
public class SpringApplicationContainer extends CommonApplicationContainer {

    @Autowired
    private ApplicationContext applicationContext;


    @PostConstruct
    public void init() {
        Map<String, Application> applicationMap = applicationContext.getBeansOfType(Application.class);
        applicationMap.forEach((name, app) -> registerApp(app));
    }
}
