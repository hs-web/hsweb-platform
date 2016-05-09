package org.hsweb.platform.controller;

import org.hsweb.platform.app.WebApplicationProcess;
import org.hsweb.platform.core.Application;
import org.hsweb.platform.core.ApplicationContainer;
import org.hsweb.platform.core.web.WebApplication;
import org.hsweb.web.core.exception.BusinessException;
import org.hsweb.web.service.config.ConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;

/**
 * Created by zhouhao on 16-4-14.
 */
@RestController
public class AppController   {

    @Autowired
    private ApplicationContainer container;

    @Autowired
    private ConfigService configService;

    @RequestMapping(value = "/app/{id:.*}")
    public Object execute(@PathVariable("id") String id, HttpServletRequest request) {
        Application application = container.getApp(id);
        if (application instanceof WebApplication) {
            WebApplicationProcess process = new WebApplicationProcess();
            process.setContainer(container);
            process.setRequest(request);
            process.setConfigService(configService);
            process.var("request", request);
            return application.execute(process);
        }
        throw new BusinessException("未找到此应用");
    }
}
