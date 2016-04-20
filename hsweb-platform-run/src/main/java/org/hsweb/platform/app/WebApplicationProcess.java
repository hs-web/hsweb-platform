package org.hsweb.platform.app;

import org.hsweb.platform.core.ApplicationContainer;
import org.hsweb.platform.core.DefaultApplicationProcess;
import org.hsweb.platform.core.SimpleValueWrapper;
import org.hsweb.platform.core.ValueWrapper;
import org.hsweb.platform.core.exception.ApplicationException;
import org.hsweb.web.service.config.ConfigService;

import javax.servlet.http.HttpServletRequest;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-14.
 */
public class WebApplicationProcess implements DefaultApplicationProcess {
    protected boolean stop = false;

    protected HttpServletRequest request;

    private ApplicationContainer container;

    private ConfigService configService;

    private Object lastStepResult;

    @Override
    public boolean isStop() {
        return stop;
    }

    @Override
    public void stop() {
        stop = true;
    }

    @Override
    public void step(String key, Object value) {
        var("step." + key, lastStepResult = value);
    }

    @Override
    public ValueWrapper getParameter(String name) {
        return new SimpleValueWrapper(request.getParameter(name));
    }

    @Override
    public ValueWrapper getParameters() {
        Map<String, Object> map = new HashMap<>();

        request.getParameterMap().forEach((key, value) -> {
            Object v;
            if (value.length > 1) {
                v = Arrays.asList(value);
            } else v = value[0];
            map.put(key, v);
        });
        return new SimpleValueWrapper(map);
    }

    @Override
    public <T> T getConfig(String prefix, String configName) {
        if (configService != null) {
            try {
                return (T) configService.get(prefix, configName);
            } catch (Exception e) {
                throw new ApplicationException(e);
            }
        }
        return null;
    }

    @Override
    public Object done() {
        return lastStepResult;
    }

    @Override
    public ApplicationContainer getContainer() {
        return container;
    }

    public void setConfigService(ConfigService configService) {
        this.configService = configService;
    }

    public void setContainer(ApplicationContainer container) {
        this.container = container;
    }

    public void setRequest(HttpServletRequest request) {
        this.request = request;
    }
}
