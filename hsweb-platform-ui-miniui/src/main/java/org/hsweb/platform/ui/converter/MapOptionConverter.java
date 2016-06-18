package org.hsweb.platform.ui.converter;

import org.hsweb.commons.StringUtils;
import org.hsweb.ezorm.meta.expand.OptionConverter;

import java.util.Arrays;
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
        Object obj = mapping.get(String.valueOf(value));
        if (obj != null) return value;
        for (Map.Entry<String, Object> entry : mapping.entrySet()) {
            if (entry.getValue().equals(value)) {
                obj = entry.getKey();
                continue;
            }
        }
        if (obj == null) {
            String strValue = String.valueOf(value);
            if (strValue.contains(",")) {
                String[] arrayValue = strValue.split("[,]");
                obj = Arrays.asList(arrayValue).stream()
                        .map(str -> {
                            Object v = converterData(str.trim());
                            if (v == null) v = str;
                            return v;
                        }).reduce((s1, s2) -> s1 + "," + s2).get();
            }
        }
        return obj;
    }

    @Override
    public Object converterValue(Object data) {
        String stringData = String.valueOf(data);
        Object value = mapping.get(String.valueOf(data));
        if (value == null) {
            //转换多个值
            if (stringData.contains(",")) {
                String[] arrayData = stringData.split("[,]");
                value = Arrays.asList(arrayData).stream()
                        .map(str -> {
                            Object v = mapping.get(str.trim());
                            if (StringUtils.isNullOrEmpty(v)) {
                                v = str.trim();
                            }
                            return v;
                        }).reduce((s1, s2) -> s1 + "," + s2).get();
            }
        }
        if (value == null) value = data;
        return value;
    }

}
