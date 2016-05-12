package org.hsweb.platform.ui.service;

import com.alibaba.fastjson.JSON;
import org.hsweb.web.bean.po.form.Form;
import org.hsweb.web.service.form.FormService;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.parser.Parser;
import org.jsoup.select.Elements;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.webbuilder.utils.common.StringUtils;

import javax.annotation.Resource;
import java.util.*;

/**
 * Created by zhouhao on 16-5-11.
 */
@Service
public class ModuleMetaParserService {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());
    @Resource
    private FormService formService;

    public String getQueryFormHtml(String formName, List<Map<String, Object>> config) throws Exception {
        String html;
        try {
            html = formService.createDeployHtml(formName);
        } catch (Exception e) {
            html = "";
        }
        List<Map<String, Object>> object = new LinkedList<>();

        Document document = Jsoup.parse(html);
        Document target = Jsoup.parse("");
        config.forEach(map -> {
            Map<String, Object> data = new LinkedHashMap<>();
            map.forEach((k, v) -> {
                if (!k.startsWith("_")) data.put(k, v);
            });
            data.remove("customHtml");
            String field = (String) map.get("field");
            String title = (String) map.get("title");
            String id = (String) map.get("id");
            String customHtml = (String) map.get("customHtml");
            String customAttr = (String) map.getOrDefault("customAttr", "{}");
            Map<String, Object> customAttrMap;
            try {
                customAttrMap = JSON.parseObject(customAttr);
            } catch (Exception e) {
                logger.warn("解析自定义属性json失败",e);
                customAttrMap = new HashMap<>();
            }
            if (title == null) title = "";
            title = title + ":";
            if (!StringUtils.isNullOrEmpty(customHtml)) {
                Element custom = Parser.parse(customHtml, target.baseUri()).body().children().first();
                custom.val("");
                customAttrMap.forEach((attr, value) -> custom.attr(attr,String.valueOf(value)));
                custom.attr("id", id).attr("field", field).attr("name", id);
                data.put("html", custom.toString());
            } else {
                Elements elements = document.select("#" + field);
                if (!elements.isEmpty()) {
                    Element first = elements.first();
                    first.val("");
                    customAttrMap.forEach((attr, value) -> first.attr(attr,String.valueOf(value)));
                    String tmp = first
                            .attr("id", id).attr("field", field).attr("name", id).removeAttr("field-id").toString();
                    data.put("html", tmp);
                }
            }
            object.add(data);
        });
        return JSON.toJSONString(object);
    }
}
