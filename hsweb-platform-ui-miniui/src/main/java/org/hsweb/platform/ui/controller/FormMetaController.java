package org.hsweb.platform.ui.controller;

import org.hsweb.ezorm.meta.TableMetaData;
import org.hsweb.ezorm.run.Table;
import org.hsweb.web.bean.common.QueryParam;
import org.hsweb.web.bean.po.form.Form;
import org.hsweb.web.core.authorize.annotation.Authorize;
import org.hsweb.web.core.message.ResponseMessage;
import org.hsweb.web.service.form.DynamicFormService;
import org.hsweb.web.service.form.FormService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Created by zhouhao on 16-5-11.
 */
@RestController
@RequestMapping("/form-meta")
public class FormMetaController {

    @Autowired
    private FormService formService;

    @Autowired
    private DynamicFormService dynamicFormService;

    @RequestMapping(value = "/{name}", method = RequestMethod.GET)
    @Authorize(module = "form")
    public ResponseMessage fieldList(@PathVariable("name") String name) throws Exception {
        Table table = dynamicFormService.getDefaultDatabase().getTable(name);
        TableMetaData metaData;
        if (table == null) {
            Form form = formService.selectSingle(new QueryParam().where("name", name));
            if (form == null) {
                return ResponseMessage.error("表单不存在");
            } else {
                metaData = dynamicFormService.parseMeta(form);
            }
        } else {
            metaData = table.getMeta();
        }
        List<Map<String, String>> fieldMeta = metaData.getFields()
                .stream().map(fieldMetaData -> {
                    Map<String, String> data = new HashMap<>();
                    data.put("id", fieldMetaData.getAlias());
                    data.put("text", fieldMetaData.getAlias() + "(" + fieldMetaData.getComment() + ")");
                    data.put("comment", fieldMetaData.getComment());
                    return data;
                }).collect(Collectors.toList());
        //关联表
        metaData.getCorrelations().forEach(correlation -> {
            TableMetaData metaData1 = metaData.getDatabaseMetaData().getTable(correlation.getTargetTable());
            if (metaData1 == null) return;
            metaData1.getFields().forEach(m -> {
                Map<String, String> data = new HashMap<>();
                data.put("id", correlation.getAlias() + "." + m.getAlias());
                data.put("text", correlation.getAlias() + "." + m.getAlias() + "(" + m.getComment() + ")");
                data.put("comment", m.getComment());
                fieldMeta.add(data);
            });
        });
        return ResponseMessage.ok(fieldMeta);
    }
}
