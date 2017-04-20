package org.hsweb.platform.ui.listener;


import com.alibaba.fastjson.JSON;
import org.hsweb.commons.StringUtils;
import org.hsweb.ezorm.core.OptionConverter;
import org.hsweb.ezorm.core.param.SqlTerm;
import org.hsweb.ezorm.core.param.Term;
import org.hsweb.ezorm.core.param.TermType;
import org.hsweb.ezorm.rdb.meta.Correlation;
import org.hsweb.ezorm.rdb.meta.RDBColumnMetaData;
import org.hsweb.ezorm.rdb.meta.RDBTableMetaData;
import org.hsweb.platform.ui.converter.ConfigOptionConverter;
import org.hsweb.platform.ui.converter.MapOptionConverter;
import org.hsweb.web.service.config.ConfigService;
import org.hsweb.web.service.form.FormParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by zhouhao on 16-6-6.
 */
@Component
public class FormInitListener implements FormParser.Listener {

    private String suffix = "_text";

    @Autowired
    private ConfigService configService;

    @Override
    public void afterParse(RDBTableMetaData tableMetaData) {
        List<Map<String, String>> list = (List) tableMetaData.getProperty("correlation").toList();
        if (list != null) {
            list.forEach(correlationConfig -> {
                String target = correlationConfig.get("targetTable");
                String term = correlationConfig.get("term");
                String joinStr = correlationConfig.get("join");
                String comment = correlationConfig.get("comment");
                if (StringUtils.isNullOrEmpty(joinStr)) {
                    joinStr = "LEFT";
                }
                Correlation.JOIN join;
                try {
                    join = Correlation.JOIN.valueOf(joinStr.toUpperCase());
                } catch (Exception e) {
                    join = Correlation.JOIN.LEFT;
                }
                if (StringUtils.isNullOrEmpty(target) || StringUtils.isNullOrEmpty(term)) return;
                String alias = correlationConfig.get("alias");
                if (StringUtils.isNullOrEmpty(alias)) alias = target;
                Correlation correlation = new Correlation();
                correlation.setTargetTable(target);
                correlation.setAlias(alias);
                correlation.setComment(comment);
                correlationConfig.forEach((k, v) -> correlation.setProperty(k, v));
                correlation.setJoin(join);
                correlation.addTerm(new SqlTerm(term));
                tableMetaData.addCorrelation(correlation);
            });
        }
        tableMetaData.getColumns().forEach(fieldMetaData -> {
            List<Map> config = fieldMetaData.getProperty("domProperty").toList();
            if (config == null) return;
            Map<String, String> cfgMap = list2map(config, "key", "value");
            String data = cfgMap.get("data");
            String url = cfgMap.get("url");
            String valueField = cfgMap.getOrDefault("valueField", "id");
            if (StringUtils.isNullOrEmpty(valueField))
                valueField = "id";
            String textField = cfgMap.getOrDefault("textField", "text");
            if (StringUtils.isNullOrEmpty(textField))
                textField = "text";
            String fieldName = fieldMetaData.getAlias() + suffix;
            if (!StringUtils.isNullOrEmpty(data)) {
                Map<String, String> map = list2map(JSON.parseArray(data, Map.class), valueField, textField);
                fieldMetaData.setOptionConverter(new MapOptionConverter(fieldName, (Map) map));
            } else if (!StringUtils.isNullOrEmpty(url)) {
                if (url.startsWith("/")) url = url.substring(1);
                String[] tmp = url.split("[?]");
                String realUrl = tmp[0];
                if (realUrl.startsWith("config")) {
                    String[] arr = realUrl.split("[/]");
                    fieldMetaData.setOptionConverter(new ConfigOptionConverter(fieldName, arr, configService));
                } else {
                    fieldMetaData.setOptionConverter(getOptionConverterByUrl(fieldName, fieldMetaData, realUrl, cfgMap));
                }
            }
        });
    }

    protected OptionConverter getOptionConverterByUrl(String fieldName, RDBColumnMetaData metaData, String url, Map<String, String> cfgMap) {
        return null;
    }


    public static Map<String, String> list2map(List<Map> list, String keyField, String valueField) {
        Map<String, String> map = new HashMap<>();
        list.stream().forEach((tmp) -> map.put(String.valueOf(tmp.get(keyField)), String.valueOf(tmp.get(valueField))));
        return map;
    }
}
