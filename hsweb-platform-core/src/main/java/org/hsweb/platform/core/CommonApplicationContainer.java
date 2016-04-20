package org.hsweb.platform.core;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-13.
 */
public class CommonApplicationContainer implements ApplicationContainer {
    private Map<String, Application> applicationBase = new HashMap<>();

    @Override
    public Application getApp(String id) {
        return applicationBase.get(id);
    }

    public Application registerApp(Application application) {
        return applicationBase.put(application.getId(), application);
    }

    @Override
    public <T extends Application> List<T> getApp(Class<T> type) {
        return null;
    }
}
