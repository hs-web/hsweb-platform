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
import java.util.HashMap;
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
            Map<String, String> cfgMap = list2map(config, "key", "value");
            Object data = cfgMap.get("data");
            Object url = cfgMap.get("url");
            String valueField = cfgMap.getOrDefault("valueField", "id");
            String textField = cfgMap.getOrDefault("textField", "text");
            if (!StringUtils.isNullOrEmpty(data)) {
                Object val = parseOptionFromData(valueField, textField, value, data);
                super.putValue(instance, attr.concat(suffix), val);
            } else if (!StringUtils.isNullOrEmpty(url)) {
                Object val = parseOptionFromUrl(valueField, textField, value, String.valueOf(url));
                super.putValue(instance, attr.concat(suffix), val);
            }
        }
    }

    public Map<String, String> list2map(List<Map> list, String keyField, String valueField) {
        Map<String, String> map = new HashMap<>();
        list.stream().forEach((tmp) -> map.put(String.valueOf(tmp.get(keyField)), String.valueOf(tmp.get(valueField))));
        return map;
    }

    public Object parseOptionFromUrl(String valueField, String textField, Object value, String url) {
        if (url.startsWith("/")) url = url.substring(1);
        String[] tmp = url.split("[?]");
        String realUrl = tmp[0];
        String param = tmp.length > 1 ? tmp[1] : null;
        Map<String, String> map = null;
        if (realUrl.startsWith("config")) {
            String[] arr = realUrl.split("[/]");
            try {
                if (arr.length == 2) {
                    String configName = arr[1];
                    String config = configService.getContent(configName.split("[.]")[0]);
                    if (config != null)
                        map = list2map(JSON.parseArray(config, Map.class), valueField, textField);
                } else if (arr.length == 3) {
                    String conf = configService.get(arr[1], arr[2]);
                    if (conf != null) {
                        if (conf.trim().startsWith("{")) {
                            map = JSON.parseObject(conf, Map.class);
                        } else {
                            map = list2map(JSON.parseArray(conf, Map.class), valueField, textField);
                        }
                    }
                }
            } catch (Exception e) {
            }
        }
        if (map != null) {
            return map.get(String.valueOf(value));
        }
        return null;
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
}
