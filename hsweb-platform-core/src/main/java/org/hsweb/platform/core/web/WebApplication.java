package org.hsweb.platform.core.web;

import org.hsweb.platform.core.Application;
import org.hsweb.platform.core.ApplicationProcess;
import org.hsweb.platform.core.Step;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by zhouhao on 16-4-13.
 */
public abstract class WebApplication implements Application {

    private String version;

    private Map<String, Step> stepMap = new ConcurrentHashMap<>();

    @Override
    public Object execute(ApplicationProcess process) {
        stepMap.forEach((key, step) -> {
            if (!process.isStop())
                process.step(key, step.execute(process));
        });
        return process.done();
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public void addStep(String key, Step step) {
        this.stepMap.put(key, step);
    }

    public void removeStep(String key) {
        this.stepMap.remove(key);
    }

    @Override
    public String toString() {
        return getId().concat(":").concat(getVersion());
    }
}
