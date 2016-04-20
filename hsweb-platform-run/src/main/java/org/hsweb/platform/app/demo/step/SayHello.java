package org.hsweb.platform.app.demo.step;

import org.hsweb.platform.core.ApplicationProcess;
import org.hsweb.platform.core.Step;

/**
 * Created by zhouhao on 16-4-14.
 */
public class SayHello implements Step {
    @Override
    public Object execute(ApplicationProcess process) {
        process.getConfig("upload","test");
        return  process.getParameter("test").toMap();
    }
}
