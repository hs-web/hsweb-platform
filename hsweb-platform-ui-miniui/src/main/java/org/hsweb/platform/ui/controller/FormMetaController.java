package org.hsweb.platform.ui.controller;

import org.hsweb.ezorm.rdb.RDBTable;
import org.hsweb.ezorm.rdb.meta.RDBTableMetaData;
import org.hsweb.web.bean.common.QueryParam;
import org.hsweb.web.bean.po.form.Form;
import org.hsweb.web.core.authorize.annotation.Authorize;
import org.hsweb.web.core.exception.NotFoundException;
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
    public ResponseMessage fieldList(@PathVariable("name") String name) {
        RDBTable table = null;
        try {
            table = dynamicFormService.getDefaultDatabase().getTable(name);
        } catch (NullPointerException e) {
        }
        RDBTableMetaData metaData;
        if (table == null) {
            Form form = formService.selectSingle(new QueryParam().where("name", name));
            if (form == null) {
                throw new NotFoundException("表单不存在");
            } else {
                metaData = dynamicFormService.parseMeta(form);
            }
        } else {
            metaData = table.getMeta();
        }
        List<Map<String, Object>> fieldMeta = metaData.getColumns()
                .stream().sorted().map(fieldMetaData -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("id", fieldMetaData.getAlias());
                    data.put("text", fieldMetaData.getAlias() + "(" + fieldMetaData.getComment() + ")");
                    data.put("comment", fieldMetaData.getComment());
                    data.put("properties", fieldMetaData.getProperties());
                    return data;
                }).collect(Collectors.toList());
        //关联表
        metaData.getCorrelations().forEach(correlation -> {
            RDBTableMetaData metaData1 = metaData.getDatabaseMetaData().getTableMetaData(correlation.getTargetTable());
            if (metaData1 == null) return;
            metaData1.getColumns().stream().sorted().forEach(m -> {
                Map<String, Object> data = new HashMap<>();
                data.put("id", correlation.getAlias() + "." + m.getAlias());
                data.put("text", correlation.getAlias() + "." + m.getAlias() + "(" + m.getComment() + ")");
                String comment = correlation.getComment();
                if (comment == null) comment = metaData1.getComment();
                data.put("comment", comment + ":" + m.getComment());
                data.put("properties", m.getProperties());
                fieldMeta.add(data);
            });
        });
        return ResponseMessage.ok(fieldMeta);
    }
}
