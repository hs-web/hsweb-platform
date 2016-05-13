/**
 * Created by zhouhao on 16-4-18.
 */
var Designer = {};
Designer.createDefault = function (type, clazz, html, defaultData) {
    return {
        defaultData:defaultData,
        html: html,
        propertiesEditable: function (name) {
            var cf = Designer.fields[type].getPropertiesTemplate()[name];
            if (!cf)return true;
            if (cf['editable'] == false)return false;
            return cf['editable'] || true;
        },
        getPropertiesTemplate: Designer.getPropertiesTemplate,
        getDefaultProperties: function () {
            var list = [];
            var tmp = Designer.fields[type].getPropertiesTemplate();
            tmp._meta.value = type;
            tmp['class'].value = clazz;
            for (var f in tmp) {
                list.push({key: f, value: tmp[f].value, describe: tmp[f].describe});
            }
            return list;
        },
        //属性编辑器，当双击行时，如果编辑器存在，则使用对于的编辑器进行编辑。
        getPropertiesEditor: function () {
            var editors = Designer.getPropertiesEditors();
            if (!defaultData)return editors;
            editors.domPropertyProxy = editors.domProperty;
            editors.domProperty = function (value, callback) {
                editors.domPropertyProxy(value, callback);
                var data = mini.decode(value['domProperty']);
                if (data.length == 0) {
                    data = defaultData;
                    mini.get("tmp_table").setData(data);
                }
            };
            return editors;
        }
    };
}
Designer.getPropertiesTemplate = function () {
    var template = {
        name: {
            describe: "名称"
        }, comment: {
            describe: "字段描述"
        }, javaType: {
            describe: "java类型",
            value: "string"
        }, dataType: {
            describe: "数据库类型",
            value: "varchar2(32)"
        }, _meta: {
            describe: "控件类型",
            value: "textbox",
        }, class: {
            describe: "class",
            value: "mini-textbox",
        }, "validator-list": {
            describe: "验证器",
            value: "[]"
        }, "domProperty": {
            describe: "其他控件配置",
            value: "[]"
        }
    };
    return template;
}
Designer.showTableTemplate = function (columns, data, title, callback) {
    //value->行的值
    //callback->编辑回调
    Designer.tmp01 = function () {
        mini.get('tmp_table').addRow({});
    };
    Designer.tmp02 = function () {
        var row = mini.get('tmp_table').getSelected();
        if (row)
            mini.get('tmp_table').removeRow(row, true);
    };
    var html = "<a class=\"mini-button\" iconCls='icon-add' plain='true' onclick=\"Designer.tmp01();\" >新增</a>" +
        "&nbsp;&nbsp;<a class=\"mini-button\" iconCls='icon-remove' plain='true' onclick=\"Designer.tmp02();\" >删除</a><br/>" +
        "<div id=\"tmp_table\" class=\"mini-datagrid\" style=\"width:100%;height: 85%;border: 0px\"\n" +
        "                allowCellEdit=\"true\" showPager=\"false\" " +
        "                allowCellSelect=\"true\" allowAlternating=\"true\" editNextOnEnterKey=\"true\"\n" +
        "                editNextRowCell=\"true\" >\n" +
        "        </div>";
    $("#editorWindowFrame").html(html);
    mini.parse();
    mini.get("tmp_table").set({
        columns: columns
    });
    mini.get("tmp_table").setData(data);
    mini.get("editorWindow").setTitle(title);
    mini.get("editorWindow").showAtPos();
    Designer.saveEditor = function () {
        callback(mini.encode(mini.get("tmp_table").getData()));
        mini.get("editorWindow").hide();
    }
}
Designer.getPropertiesEditors = function () {
    var editors = {
        "validator-list": function (value, callback) {
            //value->行的值
            //callback->编辑回调
            var data = mini.decode(value['validator-list']);
            var columns = [
                {field: "validator", width: 50, headerAlign: "center", allowSort: false, header: "验证器注解", editor: {type: "textbox"}},
            ];
            Designer.showTableTemplate(columns, data, "修改数据", callback);
        }
        , "data": function (value, callback) {
            //value->行的值
            //callback->编辑回调
            var data = mini.decode(value['data']);
            var columns = [
                {field: "id", width: 50, headerAlign: "center", allowSort: false, header: "id", editor: {type: "textbox"}},
                {field: "text", width: 50, headerAlign: "center", allowSort: false, header: "text", editor: {type: "textbox"}}
            ];
            Designer.showTableTemplate(columns, data, "修改数据", callback);
        }, "domProperty": function (value, callback) {
            var data = mini.decode(value['domProperty']);
            if (data.length == 0) {
                data = [
                    {key: "value", value: "", describe: "默认值"}
                ]
            }
            var columns = [
                {field: "key", width: 50, headerAlign: "center", allowSort: false, header: "属性", editor: {type: "textbox"}},
                {field: "value", width: 50, headerAlign: "center", allowSort: false, header: "值", editor: {type: "textbox"}},
                {field: "describe", width: 50, headerAlign: "center", allowSort: false, header: "说明", editor: {type: "textbox"}}
            ];
            Designer.showTableTemplate(columns, data, "其他控件配置", callback);
        }, "permissions": function (value, callback) {
            var data = mini.decode(value['permissions']);
            if (data.length == 0) {
                data = [
                    {type: "module", value: "", describe: "模块"}
                ]
            }
            var columns = [
                {
                    field: "type", width: 50, headerAlign: "center", allowSort: false, header: "验证类型",
                    editor: {
                        type: "combobox",
                        data: [{id: "role", text: "角色"}, {id: "module", text: "模块"}, {id: "expression", text: "表达式"}]
                    }
                },
                {field: "value", width: 50, headerAlign: "center", allowSort: false, header: "值", editor: {type: "buttonedit",onbuttonclick:'Designer.permissionsButtonEdit'}},
                {field: "describe", width: 50, headerAlign: "center", allowSort: false, header: "说明", editor: {type: "textbox"}}
            ];
            Designer.permissionsButtonEdit=function(e){
                e.sender.setValue("test");
            }
            Designer.showTableTemplate(columns, data, "权限控制", callback);
        }
    }
    return editors;
}
Designer.fields = {
    main: {
        html: function (id) {
        },
        propertiesEditable: function (name) {
            var cf = Designer.fields.main.getPropertiesTemplate()[name];
            if (!cf)return true;
            if (cf['editable'] == false)return false;
            return cf['editable'] || true;
        },
        getPropertiesTemplate: function () {
            var template = {
                name: {
                    describe: "表名"
                }, comment: {
                    describe: "表单描述"
                }, _meta: {
                    describe: "类型",
                    value: "main",
                    editable: false
                }, trigger: {
                    describe: "触发器",
                    value: "[]"
                }, permissions: {
                    describe: "权限配置",
                    value: "[]"
                }
            };
            return template;
        },
        getDefaultProperties: function () {
            var list = [];
            var tmp = Designer.fields.main.getPropertiesTemplate();
            for (var f in tmp) {
                list.push({key: f, value: tmp[f].value, describe: tmp[f].describe});
            }
            return list;
        },
        //属性编辑器，当双击行时，如果编辑器存在，则使用对于的编辑器进行编辑。
        getPropertiesEditor: function () {
            var editors = Designer.getPropertiesEditors();
            return editors;
        }
    },
    textarea: Designer.createDefault("textarea", "mini-textarea", function (id) {
        return "<input field-id='" + id + "' />";
    }),

    textbox: Designer.createDefault("textbox", "mini-textbox", function (id) {
        return "<input field-id='" + id + "' />";
    }),
    hidden: Designer.createDefault("hidden", 'mini-hidden', function (id) {
        return "<input field-id='" + id + "' />";
    }),
    datepicker: Designer.createDefault("datepicker", 'mini-datepicker', function (id) {
        return "<input field-id='" + id + "' />";
    })
    , combobox: Designer.createDefault("combobox", 'mini-combobox',
        function (id) {
            return "<input field-id='" + id + "' />";
        }, [
            {key: "value", value: "", describe: "默认值"}
            , {key: "data", value: "", describe: "可选数据项"}
            , {key: "url", value: "", describe: "可选数据项来自url"}
            , {key: "valueField", value: "", describe: "值字段(默认id)"}
            , {key: "textField", value: "", describe: "文本显示字段(默认text)"}
            , {key: "pinyinField", value: "", describe: "拼音字段"}
            , {key: "dataField", value: "", describe: "数据列表字段"}
            , {key: "multiSelect", value: "false", describe: "多选"}
            , {key: "showNullItem", value: "false", describe: "显示空项"}
            , {key: "nullItemText", value: "", describe: "空项文本"}
            , {key: "valueFromSelect", value: "", describe: "必须从选择项录入"}
            , {key: "clearOnLoad", value: "true", describe: "自动清空未在列表中的value"}
        ])
    , checkboxlist: Designer.createDefault("checkboxlist", 'mini-checkboxlist',
        function (id) {
            return "<input field-id='" + id + "' />";
        }, [
            {key: "value", value: "", describe: "默认值"}
            , {key: "data", value: "", describe: "可选数据项（js对象，属性以' '包装）"}
            , {key: "url", value: "", describe: "可选数据项来自url"}
            , {key: "valueField", value: "", describe: "值字段(默认id)"}
            , {key: "textField", value: "", describe: "文本显示字段(默认text)"}
            , {key: "repeatItems", value: "5", describe: "自动换行数量"}
            , {key: "repeatLayout", value: "table", describe: "布局方式"}
        ])
    , radiobuttonlist: Designer.createDefault("radiobuttonlist", 'mini-radiobuttonlist',
        function (id) {
            return "<input field-id='" + id + "' />";
        }, [
            {key: "value", value: "", describe: "默认值"}
            , {key: "data", value: "", describe: "可选数据项（js对象，属性以' '包装）"}
            , {key: "url", value: "", describe: "可选数据项来自url"}
            , {key: "valueField", value: "", describe: "值字段(默认id)"}
            , {key: "textField", value: "", describe: "文本显示字段(默认text)"}
            , {key: "repeatItems", value: "5", describe: "自动换行数量"}
            , {key: "repeatLayout", value: "table", describe: "布局方式"}
            , {key: "repeatDirection", value: "vertical", describe: "方向"}
        ])
};