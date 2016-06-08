package org.hsweb.platform.ui.converter;

import com.alibaba.fastjson.JSON;
import org.hsweb.ezorm.meta.expand.OptionConverter;
import org.hsweb.platform.ui.listener.FormInitListener;
import org.hsweb.web.service.config.ConfigService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Supplier;

/**
 * Created by zhouhao on 16-6-6.
 */
public class ConfigOptionConverter implements OptionConverter {
    protected String filedName;
    private String[] configId;
    private ConfigService configService;
    private Logger logger = LoggerFactory.getLogger(this.getClass());

    public ConfigOptionConverter(String filedName, String[] configId, ConfigService configService) {
        this.filedName = filedName;
        this.configService = configService;
        this.configId = configId;
    }

    @Override
    public String getFieldName() {
        return filedName;
    }

    @Override
    public Object converterData(Object value) {
        return new MapOptionConverter(filedName, getMapping()).converterData(value);
    }

    private Map<String, Object> getMapping() {
        try {
            Map<String, Object> map = null;
            if (configId.length == 2) {
                String configName = configId[1];
                map = (Map) configService.get(configName.split("[.]")[0]);
            } else if (configId.length == 3) {
                String conf = configService.get(configId[1], configId[2]);
                if (conf != null) {
                    if (conf.trim().startsWith("{")) {
                        map = JSON.parseObject(conf, Map.class);
                    } else {
                        map = (Map) FormInitListener.list2map(JSON.parseArray(conf, Map.class), "id", "text");
                    }
                }
            }
            return map;
        } catch (Exception e) {
            logger.error("转换data为value时出错", e);
        }
        return new HashMap<>();
    }

    @Override
    public Object converterValue(Object data) {
        return new MapOptionConverter(filedName, getMapping()).converterValue(data);
    }
}
