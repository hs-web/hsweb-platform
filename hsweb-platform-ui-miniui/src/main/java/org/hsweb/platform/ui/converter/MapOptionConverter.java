package org.hsweb.platform.ui.converter;

import org.hsweb.ezorm.meta.expand.OptionConverter;

import java.util.Map;

/**
 * Created by zhouhao on 16-6-6.
 */
public class MapOptionConverter implements OptionConverter {
    protected String filedName;
    private Map<String, Object> mapping;

    public MapOptionConverter(String filedName, Map<String, Object> mapping) {
        this.filedName = filedName;
        this.mapping = mapping;
    }

    @Override
    public String getFieldName() {
        return filedName;
    }

    @Override
    public Object converterData(Object value) {
        Object obj = mapping.get(value);
        if (obj == null) {
            for (Map.Entry<String, Object> entry : mapping.entrySet()) {
                if (entry.getValue().equals(value)) {
                    obj = entry.getValue();
                    continue;
                }
            }
        }
        return obj;
    }

    @Override
    public Object converterValue(Object data) {
        return mapping.get(String.valueOf(data));
    }
}
