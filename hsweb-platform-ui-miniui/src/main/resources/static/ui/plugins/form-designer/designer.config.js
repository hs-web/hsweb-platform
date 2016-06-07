/**
 * Created by zhouhao on 16-4-18.
 */
var Designer = {};
Designer.createDefault = function (type, clazz, html, defaultData) {
    return {
        defaultData: defaultData,
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
        },alias: {
            describe: "别名"
        }, comment: {
            describe: "字段描述"
        }, javaType: {
            describe: "java类型",
            value: "string"
        }, dataType: {
            describe: "数据库类型",
            value: "varchar2(128)"
        }, _meta: {
            describe: "控件类型",
            value: "textbox",
        }, "class": {
            describe: "class",
            value: "mini-textbox",
        }, "can-query": {
            describe: "查询条件",
            value: true
        },
        "export-excel": {
            describe: "可导出为excel",
            value: true
        },
        "import-excel": {
            describe: "可从excel导入",
            value: true
        }
        , "validator-list": {
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
        "repeat-validator": function (value, callback) {
            //value->行的值
            //callback->编辑回调
            var data = mini.decode(value['repeat-validator']);
            var columns = [
                {
                    field: "key", width: 50, headerAlign: "center", allowSort: false, header: "验证方式",
                    editor: {type: "combobox", data: [{id: "fields", text: "fields"}, {id: "script", text: "script"}]}
                },
                {
                    field: "value", width: 120, headerAlign: "center", allowSort: false, header: "配置",
                    editor: {type: "buttonedit", onbuttonclick: "Designer.repeatValidatorButtonEdit"}
                }
            ];
            Designer.repeatValidatorButtonEdit = function (e) {
                var row = mini.get("tmp_table").getSelected();
                if (row.key == "fields") {
                    openChooseFieldWindow(mini.decode(e.sender.value));
                    Designer.actionTmp = function () {
                        var data = mini.get('chooseFieldGrid').getData();
                        if (data.length > 0)row.value = mini.encode(data);
                        mini.get("tmp_table").updateRow(row);
                        mini.get('chooseFieldWindow').hide();
                    }
                }
                if (row.key == "script") {
                    openScriptEditor("text/x-groovy", e.sender.value, function (script) {
                        if (script == "cancel" || script == "close") {
                            return;
                        }
                        e.sender.setText(script);
                        e.sender.setValue(script);
                        mini.get("tmp_table").updateRow(row);
                    });
                }
            }
            Designer.showTableTemplate(columns, data, "重复数据验证方式", callback);
            mini.get('tmp_table').on("cellbeginedit", function (e) {
                if (e.field == "value") {
                    e.editor.setValue(e.value);
                    e.editor.setText(e.value);
                }
            })
        },
        correlation:function (value, callback) {
            var data = mini.decode(value['correlation']);
            var columns = [
                {
                    field: "targetTable", width: 50, headerAlign: "center", allowSort: false, header: "目标表",
                    editor: {type: "textbox"}
                },{
                    field: "alias", width: 50, headerAlign: "center", allowSort: false, header: "别名",
                    editor: {type: "textbox"}
                },{
                    field: "join", width: 40, headerAlign: "center", allowSort: false, header: "类型",
                    editor: {type: "combobox",data:[{id:"left",text:"left"},{id:"right",text:"right"},{id:"full",text:"full"},{id:"inner",text:"inner"}]}
                },
                {
                    field: "term", width: 100, headerAlign: "center", allowSort: false, header: "条件",
                    editor: {type: "textbox"}
                }
            ];
            Designer.showTableTemplate(columns, data, "表链接", callback);
        },
        "defaultTableData":function (value, callback) {
            var data = mini.decode(value['defaultTableData']);
            var columns = [
                {
                    field: "data", width: 100, headerAlign: "center", allowSort: false, header: "默认数据(JSON)",
                    editor: {type: "buttonedit", onbuttonclick: "Designer.defaultTableDataEdit"}
                }
            ];
            Designer.showTableTemplate(columns, data, "编辑默认数据", callback);
            Designer.defaultTableDataEdit = function (e) {
                var row = mini.get("tmp_table").getSelected();
                var val = e.sender.value;
                if (!val || val == '')val ='{\n"property":"value"\n}';
                openScriptEditor("application/ld+json", val, function (json) {
                    if (json == "cancel" || json == "close") {
                        return;
                    }
                    e.sender.setText(json);
                    e.sender.setValue(json);
                    mini.get("tmp_table").updateRow(row);
                });
            };
            mini.get('tmp_table').on("cellbeginedit", function (e) {
                if (e.field == "data") {
                    e.editor.setValue(e.value);
                    e.editor.setText(e.value);
                }
            });
        },
        tabConfig: function (value, callback) {
            var data = mini.decode(value['tabConfig']);
            var columns = [
                {
                    field: "title", width: 50, headerAlign: "center", allowSort: false, header: "标题",
                    editor: {type: "textbox"}
                },
                {
                    field: "url", width: 100, headerAlign: "center", allowSort: false, header: "路径",
                    editor: {type: "textbox"}
                }
            ];
            Designer.showTableTemplate(columns, data, "配置路径", callback);
        },
        "columns": function (value, callback) {
            var data = mini.decode(value['columns']);
            var columns = [
                {
                    field: "field", width: 50, headerAlign: "center", allowSort: false, header: "字段",
                    editor: {type: "textbox"}
                },
                {
                    field: "header", width: 50, headerAlign: "center", allowSort: false, header: "表头",
                    editor: {type: "textbox"}
                },
                {
                    field: "width", width: 50, headerAlign: "center", allowSort: false, header: "宽度",
                    editor: {type: "textbox"}
                },
                {
                    field: "property", width: 100, headerAlign: "center", allowSort: false, header: "其他自定义属性(JSON)",
                    editor: {type: "buttonedit", onbuttonclick: "Designer.columnsButtonEdit"}
                }
            ];
            Designer.showTableTemplate(columns, data, "配置表格", callback);
            Designer.columnsButtonEdit = function (e) {
                var row = mini.get("tmp_table").getSelected();
                var val = e.sender.value;
                if (!val || val == '')val = mini.encode({key: 'value'});
                openScriptEditor("application/ld+json", val, function (script) {
                    if (script == "cancel" || script == "close") {
                        return;
                    }
                    e.sender.setText(script);
                    e.sender.setValue(script);
                    mini.get("tmp_table").updateRow(row);
                });
            };
            mini.get('tmp_table').on("cellbeginedit", function (e) {
                if (e.field == "property") {
                    e.editor.setValue(e.value);
                    e.editor.setText(e.value);
                }
            });
        },
        "trigger": function (value, callback) {
            //value->行的值
            //callback->编辑回调
            var data = mini.decode(value['trigger']);
            var columns = [
                {
                    field: "key", width: 50, headerAlign: "center", allowSort: false, header: "名称",
                    editor: {
                        type: "combobox", allowInput: true, textField: "id", data: [
                            {id: "select.wrapper.each"},
                            {id: "select.wrapper.done"},
                            {id: "select.before"},
                            {id: "select.done"},
                            {id: "insert.before"},
                            {id: "insert.done"},
                            {id: "update.before"},
                            {id: "update.done"},
                            {id: "delete.before"},
                            {id: "delete.done"},
                            {id: "export.import.before"},
                            {id: "export.import.each"},
                        ]
                    }
                },
                {
                    field: "value", width: 120, headerAlign: "center", allowSort: false, header: "执行脚本",
                    editor: {type: "buttonedit", onbuttonclick: "Designer.triggerButtonEdit"}
                }
            ];
            Designer.triggerButtonEdit = function (e) {
                var row = mini.get("tmp_table").getSelected();
                var val = e.sender.value;
                if (!val || val == "") {
                    val = "//groovy 脚本，内置对象 param,table,database 等\n";
                    val += "import org.hsweb.web.core.utils.WebUtil;\n";
                    val += "import java.utils.*;\n";
                    val += "def user=WebUtil.getLoginUser();\n\n";
                }
                openScriptEditor("text/x-groovy", val, function (script) {
                    if (script == "cancel" || script == "close") {
                        return;
                    }
                    e.sender.setText(script);
                    e.sender.setValue(script);
                    mini.get("tmp_table").updateRow(row);
                });
            }
            Designer.showTableTemplate(columns, data, "触发器配置", callback);
            mini.get('tmp_table').on("cellbeginedit", function (e) {
                if (e.field == "value") {
                    e.editor.setValue(e.value);
                    e.editor.setText(e.value);
                }
            });
        },
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
                        data: [
                            {id: "role", text: "role"},
                            {id: "module", text: "module"},
                            {id: "expression", text: "expression"}]
                    }
                },
                {
                    field: "value", width: 50, headerAlign: "center", allowSort: false, header: "值",
                    editor: {type: "buttonedit", textName: 'value', onbuttonclick: 'Designer.permissionsButtonEdit'}
                },
                {field: "describe", width: 50, headerAlign: "center", allowSort: false, header: "说明", editor: {type: "textbox"}}
            ];
            Designer.permissionsButtonEdit = function (e) {

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
                },alias: {
                    describe: "别名"
                }, comment: {
                    describe: "表单描述"
                }, _meta: {
                    describe: "类型",
                    value: "main",
                    editable: false
                }, correlation: {
                    describe: "表链接",
                    value: "[]"
                }, trigger: {
                    describe: "触发器",
                    value: "[]"
                }, "repeat-validator": {
                    describe: "重复数据验证规则",
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
    password: Designer.createDefault("password", "mini-password", function (id) {
        return "<input field-id='" + id + "' />";
    }),
    hidden: Designer.createDefault("hidden", 'mini-hidden', function (id) {
        return "<input field-id='" + id + "' />";
    }),
    datepicker: Designer.createDefault("datepicker", 'mini-datepicker', function (id) {
        return "<input field-id='" + id + "' />";
    }),
    combobox: Designer.createDefault("combobox", 'mini-combobox',
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
        ]),
    checkboxlist: Designer.createDefault("checkboxlist", 'mini-checkboxlist',
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
        ]),
    radiobuttonlist: Designer.createDefault("radiobuttonlist", 'mini-radiobuttonlist',
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
        ]),
    spinner: Designer.createDefault("spinner", "mini-spinner", function (id) {
        return "<input field-id='" + id + "' />";
    }),
    timespinner: Designer.createDefault("timespinner", "mini-timespinner", function (id) {
        return "<input field-id='" + id + "' />";
    }),
    treeselect: Designer.createDefault("treeselect", 'mini-treeselect',
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
        ]),
    buttonedit: Designer.createDefault("buttonedit", "mini-buttonedit", function (id) {
        return "<input field-id='" + id + "' />";
    }),
    autocomplete: Designer.createDefault("autocomplete", "mini-autocomplete", function (id) {
        return "<input field-id='" + id + "' />";
    }),
    monthpicker: Designer.createDefault("monthpicker", "mini-monthpicker", function (id) {
        return "<input field-id='" + id + "' />";
    }),
    table: {
        html: function (id) {
            return "<input field-id='" + id + "' />";
        },
        propertiesEditable: function (name) {
            var cf = Designer.fields['table'].getPropertiesTemplate()[name];
            if (!cf)return true;
            if (cf['editable'] == false)return false;
            return cf['editable'] || true;
        },
        getPropertiesTemplate: function () {
            var template = {
                name: {
                    describe: "名称"
                },alias: {
                    describe: "别名"
                }, comment: {
                    describe: "字段描述"
                }, javaType: {
                    describe: "java类型",
                    value: "string"
                }, dataType: {
                    describe: "数据库类型",
                    value: "clob"
                }, _meta: {
                    describe: "控件类型",
                    value: "grid",
                }, "class": {
                    describe: "class",
                    value: "data-grid",
                }, "columns": {
                    describe: "列配置",
                    value: "[]"
                }, "defaultTableData": {
                    describe: "默认数据",
                    value: "[]"
                }, "canAddRow": {
                    describe: "允许新增行",
                    value: "true"
                }, "canRemoveRow": {
                    describe: "允许删除行",
                    value: "true"
                }, "customPage": {
                    describe: "表格页",
                    value: "admin/form/table.html"
                }, "domProperty": {
                    describe: "其他控件配置",
                    value: "[]"
                }
            };
            return template;
        },
        getDefaultProperties: function () {
            var list = [];
            var tmp = Designer.fields['table'].getPropertiesTemplate();
            tmp._meta.value = 'table';
            tmp['class'].value = "data-grid";
            for (var f in tmp) {
                list.push({key: f, value: tmp[f].value, describe: tmp[f].describe});
            }
            return list;
        },
        getPropertiesEditor: function () {
            var editors = Designer.getPropertiesEditors();
            editors.domPropertyProxy = editors.domProperty;
            editors.domProperty = function (value, callback) {
                editors.domPropertyProxy(value, callback);
                var data = mini.decode(value['domProperty']);
                if (data.length == 0) {
                    mini.get("tmp_table").setData(data);
                }
            };
            return editors;
        }
    },
    tabs: {
        html: function (id) {
            return "<input field-id='" + id + "' />";
        },
        propertiesEditable: function (name) {
            var cf = Designer.fields['tabs'].getPropertiesTemplate()[name];
            if (!cf)return true;
            if (cf['editable'] == false)return false;
            return cf['editable'] || true;
        },
        getPropertiesTemplate: function () {
            var template = {
                name: {
                    describe: "名称"
                },alias: {
                    describe: "别名"
                }, comment: {
                    describe: "字段描述"
                }, javaType: {
                    describe: "java类型",
                    value: "string"
                }, dataType: {
                    describe: "数据库类型",
                    value: "clob"
                }, _meta: {
                    describe: "控件类型",
                    value: "grid",
                }, "class": {
                    describe: "class",
                    value: "data-grid",
                }, "tabConfig": {
                    describe: "选项卡配置",
                    value: "[]"
                },"domProperty": {
                    describe: "其他控件配置",
                    value: "[]"
                }
            };
            return template;
        },
        getDefaultProperties: function () {
            var list = [];
            var tmp = Designer.fields['tabs'].getPropertiesTemplate();
            tmp._meta.value = 'tabs';
            tmp['class'].value = "data-tabs";
            for (var f in tmp) {
                list.push({key: f, value: tmp[f].value, describe: tmp[f].describe});
            }
            return list;
        },
        getPropertiesEditor: function () {
            var editors = Designer.getPropertiesEditors();
            editors.domPropertyProxy = editors.domProperty;
            editors.domProperty = function (value, callback) {
                editors.domPropertyProxy(value, callback);
                var data = mini.decode(value['domProperty']);
                if (data.length == 0) {
                    mini.get("tmp_table").setData(data);
                }
            };
            return editors;
        }
    },
    button: {
        html: function (id) {
            return "<button field-id='" + id + "' >操作</button>";
        },
        propertiesEditable: function (name) {
            var cf = Designer.fields['button'].getPropertiesTemplate()[name];
            if (!cf)return true;
            if (cf['editable'] == false)return false;
            return cf['editable'] || true;
        },
        getPropertiesTemplate: function () {
            var template = {
                _meta: {
                    describe: "控件类型",
                    value: "textbox",
                }, "class": {
                    describe: "class",
                    value: "mini-textbox",
                },
                "domProperty": {
                    describe: "其他控件配置",
                    value: "[]"
                }
            };
            return template;
        },
        getDefaultProperties: function () {
            var list = [];
            var tmp = Designer.fields['button'].getPropertiesTemplate();
            tmp._meta.value = 'button';
            tmp['class'].value = "mini-button";
            for (var f in tmp) {
                list.push({key: f, value: tmp[f].value, describe: tmp[f].describe});
            }
            return list;
        },
        //属性编辑器，当双击行时，如果编辑器存在，则使用对于的编辑器进行编辑。
        getPropertiesEditor: function () {
            var editors = Designer.getPropertiesEditors();
            editors.domPropertyProxy = editors.domProperty;
            editors.domProperty = function (value, callback) {
                editors.domPropertyProxy(value, callback);
                var data = mini.decode(value['domProperty']);
                if (data.length == 0) {
                    mini.get("tmp_table").setData(data);
                }
            };
            return editors;
        }
    }
};