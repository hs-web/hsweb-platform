package org.hsweb.platform.core;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created by zhouhao on 16-4-13.
 */
public interface ApplicationProcess {
    boolean isStop();

    void stop();

    ValueWrapper getVar(String name);

    <T> T var(String var, T value);

    void step(String key, Object value);

    ValueWrapper getParameter(String name);

    ValueWrapper getParameters();

    <T> T getConfig(String prefix, String configName);

    Object done();

    void error(String message);

    void error(Throwable e);

    void error(String message, Throwable e);

    ApplicationContainer getContainer();

    default void logger(String message, Object... more) {
    }
}
