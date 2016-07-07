package org.hsweb.platform.generator.utils;

import org.hsweb.commons.StringUtils;

public class GeneratorUtils {
    public String getGetter(String name, String javaType) {
        if ("boolean".equals(javaType.toLowerCase())) {
            return "is" + StringUtils.toUpperCaseFirstOne(name);
        }
        return "get" + StringUtils.toUpperCaseFirstOne(name);
    }

    public String getSetter(String name) {
        return "set" + StringUtils.toUpperCaseFirstOne(name);
    }

}
