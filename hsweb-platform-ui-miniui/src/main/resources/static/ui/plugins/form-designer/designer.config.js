/**
 * Created by zhouhao on 16-4-18.
 */
var Designer = {};
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
            editable: false
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
            if (!cf)return false;
            return cf['editable'] || false;
        },
        getPropertiesTemplate: function () {
            var template = {
                name: {
                    describe: "表单名称"
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
    textbox: {
        html: function (id) {
            return "<input class='mini-textbox' field-id='" + id + "' />";
        },
        propertiesEditable: function (name) {
            var cf = Designer.fields.textbox.getPropertiesTemplate()[name];
            if (!cf)return false;
            return cf['editable'] || false;
        },
        getPropertiesTemplate: function () {
            return Designer.getPropertiesTemplate();
        },
        getDefaultProperties: function () {
            var list = [];
            var tmp = Designer.fields.textbox.getPropertiesTemplate();
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
    }
    , combobox: {
        html: function (id) {
            return "<input class='mini-combobox' field-id='" + id + "' />";
        },
        propertiesEditable: function (name) {
            var cf = Designer.fields.combobox.getPropertiesTemplate()[name];
            if (!cf)return false;
            return cf['editable'] || false;
        },
        getPropertiesTemplate: function () {
            var template = Designer.getPropertiesTemplate();
            template.data = {
                describe: "data"
            };
            template.url = {
                describe: "url"
            };
            template.domProperty = {
                describe: "其他控件配置",
                value: "[]",
            };
            return template;
        },
        getDefaultProperties: function () {
            var list = [];
            var tmp = Designer.fields.combobox.getPropertiesTemplate();
            tmp._meta.value = "combobox";
            for (var f in tmp) {
                list.push({key: f, value: tmp[f].value, describe: tmp[f].describe});
            }
            return list;
        },
        //属性编辑器，当双击行时，如果编辑器存在，则使用对于的编辑器进行编辑。
        getPropertiesEditor: function () {
            var editors = Designer.getPropertiesEditors();
            editors.domPropertyProxy=editors.domProperty;
            editors.domProperty = function (value, callback) {
                editors.domPropertyProxy(value,callback);
                var data = mini.decode(value['domProperty']);
                if (data.length == 0) {
                    data = [
                        {key: "value", value: "", describe: "默认值"}
                        //, {key: "valueField", value: "id", describe: "值字段"}
                        //, {key: "textField", value: "text", describe: "文本显示字段"}
                        //, {key: "pinyinField", value: "", describe: "拼音字段"}
                        //, {key: "dataField", value: "", describe: "数据列表字段"}
                        //, {key: "multiSelect", value: "false", describe: "多选"}
                        //, {key: "showNullItem", value: "false", describe: "显示空项"}
                        //, {key: "nullItemText", value: "", describe: "空项文本"}
                        //, {key: "valueFromSelect", value: "", describe: "必须从选择项录入"}
                        //, {key: "clearOnLoad", value: "true", describe: "自动清空未在列表中的value"}
                    ]
                    mini.get("tmp_table").setData(data);
                }
            };
            return editors;
        }
    }

}