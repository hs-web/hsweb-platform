package org.hsweb.platform.core;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-14.
 */
public interface ValueWrapper {
    Object getValue();

    String toString();

    int toInt();

    double toDouble();

    boolean toBoolean();

    int toInt(int defaultValue);

    double toDouble(double defaultValue);

    boolean toBoolean(boolean defaultValue);

    Date toDate();

    Date toDate(String format);

    default Map<String, Object> toMap() {
        Object value = getValue();
        if (value instanceof Map)
            return ((Map) getValue());
        return toBean(Map.class);
    }

    default List<Map> toList() {
        return toBeanList(Map.class);
    }

    <T> T toBean(Class<T> type);

    <T> List<T> toBeanList(Class<T> type);

    boolean valueTypeOf(Class<?> type);
}
