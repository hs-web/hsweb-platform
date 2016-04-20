package org.hsweb.platform.core;

import org.hsweb.platform.core.exception.ApplicationException;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-14.
 */
public interface DefaultApplicationProcess extends ApplicationProcess {

    Map<String, Object> var = new HashMap<>();

    @Override
    default <T> T var(String var, T value) {
        return (T) this.var.put(var, value);
    }

    default ValueWrapper getVar(String var) {
        return new SimpleValueWrapper(this.var.get(var));
    }

    @Override
    default void error(String message) {
        throw new ApplicationException(message);
    }

    @Override
    default void error(String message, Throwable e) {
        throw new ApplicationException(message, e);
    }

    @Override
    default void error(Throwable e) {
        throw new ApplicationException(e);
    }

}
