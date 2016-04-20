package org.hsweb.platform.app.demo;

import org.hsweb.platform.app.demo.step.SayHello;
import org.hsweb.platform.core.ApplicationProcess;
import org.hsweb.platform.core.web.WebApplication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Created by zhouhao on 16-4-14.
 */
@Service
public class HelloWorldApp extends WebApplication {

    public HelloWorldApp() {
        addStep("hello", new SayHello());
    }

    @Override
    @Transactional(rollbackFor = Throwable.class)
    public Object execute(ApplicationProcess process) {
        return super.execute(process);
    }

    @Override
    public String getVersion() {
        return "latest";
    }

    @Override
    public String getId() {
        return "helloWorld";
    }

}
