package org.hsweb.platform.core;

import java.util.List;

/**
 * Created by zhouhao on 16-4-13.
 */
public interface ApplicationContainer {

    <T extends Application> List<T> getApp(Class<T> type);

    Application getApp(String id);

    Application registerApp(Application application);
}
