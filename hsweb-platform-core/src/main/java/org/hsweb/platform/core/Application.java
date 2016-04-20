package org.hsweb.platform.core;

/**
 * 平台应用，系统的每个功能都看做是一个应用
 * Created by zhouhao on 16-4-13.
 */
public interface Application {
    String getId();

    Object execute(ApplicationProcess process);

    String getVersion();
}
