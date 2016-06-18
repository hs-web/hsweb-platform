package org.hsweb.platform.ui.service;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.hsweb.commons.StringUtils;
import org.hsweb.web.bean.po.form.Form;
import org.hsweb.web.bean.po.module.Module;
import org.hsweb.web.bean.po.module.ModuleMeta;
import org.hsweb.web.core.exception.NotFoundException;
import org.hsweb.web.service.form.FormService;
import org.hsweb.web.service.module.ModuleMetaService;
import org.hsweb.web.service.module.ModuleService;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.parser.Parser;
import org.jsoup.select.Elements;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.*;

/**
 * Created by zhouhao on 16-5-11.
 */
@Service
@Transactional(rollbackFor = Throwable.class)
public class ModuleMetaParserService {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());
    @Resource
    private FormService formService;
    @Resource
    private ModuleService moduleService;
    @Resource
    private ModuleMetaService moduleMetaService;

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
        Map<String, Node> cache = new HashMap<>();
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
                logger.warn("解析自定义属性json失败", e);
                customAttrMap = new HashMap<>();
            }
            if (title == null) title = "";
            title = title + ":";
            if (!StringUtils.isNullOrEmpty(customHtml)) {
                Element custom = Parser.parse(customHtml, target.baseUri()).body().children().first();
                custom.val("");
                customAttrMap.forEach((attr, value) -> custom.attr(attr, String.valueOf(value)));
                custom.attr("id", id).attr("field", field).attr("name", id);
                data.put("html", custom.toString());
            } else {
                Node cached = cache.get(field);
                if (cached != null) {
                    cached.attr("id", id).attr("field", field).attr("name", id);
                    data.put("html", cached.toString());
                } else {
                    Elements elements = document.select("#" + field);
                    if (!elements.isEmpty()) {
                        Element first = elements.first();
                        first.val("");
                        customAttrMap.forEach((attr, value) -> first.attr(attr, String.valueOf(value)));
                        Node tmp = first
                                .attr("id", id).attr("field", field).attr("name", id).removeAttr("field-id");
                        data.put("html", tmp.toString());
                        cache.put(field, tmp);
                    }
                }
            }
            object.add(data);
        });
        return JSON.toJSONString(object);
    }

    public String autoCreateModule(String formId) throws Exception {
        Form form = formService.selectByPk(formId);
        if (form == null) throw new NotFoundException("表单不存在");
        String moduleName = StringUtils.isNullOrEmpty(form.getRemark()) ? "新建模块(" + form.getName() + ")" : form.getRemark();
        Module module = moduleService.selectByPk(form.getName());
        if (module == null) {
            module = new Module();
            module.setId(form.getName());
            module.setStatus(1);
            module.setOptional("[{\"id\":\"M\",\"text\":\"菜单可见\",\"checked\":true},{\"id\":\"import\",\"text\":\"导入excel\",\"checked\":true},{\"id\":\"export\",\"text\":\"导出excel\",\"checked\":true},{\"id\":\"R\",\"text\":\"查询\",\"checked\":true},{\"id\":\"C\",\"text\":\"新增\",\"checked\":true},{\"id\":\"U\",\"text\":\"修改\",\"checked\":true},{\"id\":\"D\",\"text\":\"删除\",\"checked\":false}]");
            module.setName(moduleName);
            module.setParentId("default");
            module.setUri("module-view/" + form.getName() + "/list.html");
            moduleService.insert(module);
        }
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("table_api", "dyn-form/" + form.getName());
        jsonObject.put("create_page", "module-view/{metaId}/save.html");
        jsonObject.put("save_page", "module-view/{metaId}/save.html?id={id}");
        jsonObject.put("info_page", "module-view/{metaId}/info.html?id={id}");
        jsonObject.put("queryPlanConfig", new JSONArray());
        jsonObject.put("queryTableConfig", new JSONArray());
        jsonObject.put("dynForm", form.getName());
        ModuleMeta moduleMeta = new ModuleMeta();
        moduleMeta.setStatus(1);
        moduleMeta.setKey(module.getId());
        moduleMeta.setModuleId(module.getId());
        moduleMeta.setMeta(jsonObject.toJSONString());
        return moduleMetaService.insert(moduleMeta);
    }
}
