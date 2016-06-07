package org.hsweb.platform.ui.listener;


import com.alibaba.fastjson.JSON;
import org.hsweb.ezorm.meta.Correlation;
import org.hsweb.ezorm.meta.TableMetaData;
import org.hsweb.ezorm.param.Term;
import org.hsweb.ezorm.param.TermType;
import org.hsweb.platform.ui.converter.ConfigOptionConverter;
import org.hsweb.platform.ui.converter.MapOptionConverter;
import org.hsweb.web.service.config.ConfigService;
import org.hsweb.web.service.form.FormParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.webbuilder.utils.common.StringUtils;

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
    public void afterParse(TableMetaData tableMetaData) {
        List<Map> list = tableMetaData.getProperty("correlation").toList();
        if (list != null) {
            list.forEach(correlationConfig -> {
                String target = (String) correlationConfig.get("targetTable");
                String term = (String) correlationConfig.get("term");
                String joinStr = (String) correlationConfig.get("join");
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
                String alias = (String) correlationConfig.get("alias");
                if (StringUtils.isNullOrEmpty(alias)) alias = target;
                Correlation correlation = new Correlation();
                correlation.setTargetTable(target);
                correlation.setAlias(alias);
                Term term1 = new Term();
                term1.setField(term);
                term1.setValue(term);
                correlation.setJoin(join);
                term1.setTermType(TermType.func);
                correlation.addTerm(term1);
                tableMetaData.addCorrelation(correlation);
            });
        }
        tableMetaData.getFields().forEach(fieldMetaData -> {
            List<Map> config = fieldMetaData.getProperty("domProperty").toList();
            if (config == null) return;
            Map<String, String> cfgMap = list2map(config, "key", "value");
            String data = cfgMap.get("data");
            String url = cfgMap.get("url");
            String valueField = cfgMap.getOrDefault("valueField", "id");
            String textField = cfgMap.getOrDefault("textField", "text");
            String fieldName = fieldMetaData.getAlias() + suffix;
            if (!StringUtils.isNullOrEmpty(data)) {
                Map<String, String> map = list2map(JSON.parseArray(String.valueOf(data), Map.class), valueField, textField);
                fieldMetaData.setOptionConverter(new MapOptionConverter(fieldName, (Map) map));
            } else if (!StringUtils.isNullOrEmpty(url)) {
                if (url.startsWith("/")) url = url.substring(1);
                String[] tmp = url.split("[?]");
                String realUrl = tmp[0];
                String param = tmp.length > 1 ? tmp[1] : null;
                Map<String, String> map = null;
                if (realUrl.startsWith("config")) {
                    String[] arr = realUrl.split("[/]");
                    fieldMetaData.setOptionConverter(new ConfigOptionConverter(fieldName, arr, configService));
                }
            }
        });
    }


    public static Map<String, String> list2map(List<Map> list, String keyField, String valueField) {
        Map<String, String> map = new HashMap<>();
        list.stream().forEach((tmp) -> map.put(String.valueOf(tmp.get(keyField)), String.valueOf(tmp.get(valueField))));
        return map;
    }
}
