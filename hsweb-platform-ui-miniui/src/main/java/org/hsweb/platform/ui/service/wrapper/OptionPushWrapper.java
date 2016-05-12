package org.hsweb.platform.ui.service.wrapper;

import com.alibaba.fastjson.JSON;
import org.hsweb.web.service.config.ConfigService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StreamUtils;
import org.webbuilder.sql.*;
import org.webbuilder.sql.support.executor.HashMapWrapper;
import org.webbuilder.utils.common.StringUtils;

import java.nio.charset.Charset;
import java.sql.Clob;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Created by zhouhao on 16-5-12.
 */
public class OptionPushWrapper extends HashMapWrapper {
    private Logger logger = LoggerFactory.getLogger(this.getClass());
    private String suffix;

    protected ConfigService configService;

    protected Table table;

    @Override
    public void wrapper(Map<String, Object> instance, int index, String attr, Object value) {
        if (value instanceof Clob) {
            try {
                value = StreamUtils.copyToString(((Clob) value).getAsciiStream(), Charset.defaultCharset());
            } catch (Exception e) {
                logger.error("clob2string error", e);
            }
        }
        super.wrapper(instance, index, attr, value);
    }

    @Override
    public void putValue(Map<String, Object> instance, String attr, Object value) {
        super.putValue(instance, attr, value);
        tryPushOption(instance, attr, value);
    }

    public void tryPushOption(Map<String, Object> instance, String attr, Object value) {
        TableMetaData metaData = table.getMetaData();
        FieldMetaData filed = metaData.getField(attr);
        if (filed != null) {
            List<Map> config = filed.attrWrapper("domProperty").toList();
            if (config == null) return;
            config.stream().forEach(map -> {
                String key = String.valueOf(map.get("key"));
                String valueField = (String) map.getOrDefault("valueField", "id");
                String textField = (String) map.getOrDefault("textField", "text");
                if ("data".equals(key)) {
                    Object val = parseOptionFromData(valueField, textField, value, map.get("value"));
                    super.putValue(instance, attr.concat(suffix), val);
                } else if ("url".equals(key)) {

                }
            });
        }
    }

    public Object parseOptionFromData(String valueField, String textField, Object value, Object data) {
        List<Map> optionList = new SimpleValueWrapper(data).toList();
        return optionList.stream()
                .map(map -> {
                    String stringValue = String.valueOf(map.get(valueField));
                    String targetStringValue = String.valueOf(value);
                    if (stringValue.equals(targetStringValue)) return map.get(textField);
                    if (targetStringValue.contains(",")) {
                        if (Arrays.asList(targetStringValue.split("[,]")).contains(stringValue))
                            return map.get(textField);
                    }
                    return "";
                }).reduce((s1, s2) -> {
                    if (StringUtils.isNullOrEmpty(s1)) return s2;
                    if (StringUtils.isNullOrEmpty(s2)) return s1;
                    return s1 + "," + s2;
                }).get();
    }

    @Override
    public void done(Map<String, Object> instance) {

    }

    public void setConfigService(ConfigService configService) {
        this.configService = configService;
    }

    public void setSuffix(String suffix) {
        this.suffix = suffix;
    }

    @Override
    public void init(DataBase dataBase, Table table) {
        this.table = table;
        super.init(dataBase, table);
    }

    public static void main(String[] args) {
        System.out.println(JSON.parse("[{'id':'0',text:'男'},{'id':'1',text:'女'}]"));
    }
}
