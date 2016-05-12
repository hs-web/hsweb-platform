package org.hsweb.platform.ui.controller;

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
import org.webbuilder.sql.DataBase;
import org.webbuilder.sql.FieldMetaData;
import org.webbuilder.sql.Table;
import org.webbuilder.sql.TableMetaData;

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
    private DataBase dataBase;

    @Autowired
    private FormService formService;

    @Autowired
    private DynamicFormService dynamicFormService;

    @RequestMapping(value = "/{name}", method = RequestMethod.GET)
    @Authorize(module = "form")
    public ResponseMessage fieldList(@PathVariable("name") String name) throws Exception {
        Table table = dataBase.getTable(name);
        TableMetaData metaData;
        if (table == null) {
            Form form = formService.selectSingle(new QueryParam().where("name", name));
            if (form == null) {
                return ResponseMessage.error("表单不存在");
            } else {
                metaData = ((TableMetaData) dynamicFormService.parseMeta(form));
            }
        } else {
            metaData = table.getMetaData();
        }
        List<Map<String, Object>> fieldMeta = metaData.getFields()
                .stream().map(fieldMetaData -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("id", fieldMetaData.getName());
                    data.put("text", fieldMetaData.getName() + "(" + fieldMetaData.getComment() + ")");
                    data.put("comment", fieldMetaData.getComment());
                    return data;
                }).collect(Collectors.toList());
        return ResponseMessage.ok(fieldMeta);
    }
}
