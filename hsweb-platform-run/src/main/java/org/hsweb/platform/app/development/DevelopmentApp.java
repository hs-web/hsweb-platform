package org.hsweb.platform.app.development;

import org.hsweb.platform.app.development.step.DispatcherStep;
import org.hsweb.platform.core.web.WebApplication;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;

/**
 * 系统开发app
 * Created by zhouhao on 16-4-14.
 */
@Service
public class DevelopmentApp extends WebApplication {

    private String id = "development";
    private String version = "1.0-SNAPSHOT";

    @Autowired
    private DispatcherStep dispatcherStep;

    @Override
    public String getId() {
        return id;
    }

    @Override
    public String getVersion() {
        return version;
    }

    @PostConstruct
    public void init() {
        addStep("dispatcher", dispatcherStep);
    }
}
