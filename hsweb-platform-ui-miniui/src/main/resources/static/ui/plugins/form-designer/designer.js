var fieldData = {};
mini.parse();
var ue = UE.getEditor('container');
var propertiesTable = mini.get('properties-table');
var nowEditorTarget = "main";
ue.ready(function () {
    if (id != "") {
        Request.get("form/" + id, {}, function (e) {
            if (e.success) {
                mini.get('classifiedId').setValue(e.data.classifiedId);
                fieldData = mini.decode(e.data.meta);
                ue.setContent(e.data.html);
                initProperties();
            } else {
                logger.error("加载失败!" + e.data);
            }
        });
    } else {
        fieldData.main = Designer.fields.main.getDefaultProperties();
        initProperties();
    }
    initShortcut();
    setShortcut("ControlLeft+KeyS", save);
});

ue.addListener('focus', function () {
    propertiesTable.commitEdit();
});
ue.addListener('selectionchange', function () {
    var focusNode = ue.selection.getStart();
    var id = $(focusNode).attr("field-id");
    var tag = $(focusNode).prop("tagName");
    var tagIsInput = tag == "input" || tag == "INPUT";
    var tagIsSelect = tag == "select" || tag == "SELECT";
    var tagIsTextArea = tag == "textarea" || tag == "TEXTAREA";
    var tagIsDate=$(focusNode).attr("onclick")=="WdatePicker()"
        ||$(focusNode).parent().prev().text().indexOf("日期")!=-1
        ||$(focusNode).parent().prev().text().indexOf("时间")!=-1;
    var autocreate = tagIsInput || tagIsSelect || tagIsTextArea||tagIsDate;
    if (id) {
        nowEditorTarget = id;
    } else {
        if (autocreate) {
            var name = $(focusNode).attr("name");
            if(!name){
                nowEditorTarget="main";
                initProperties();
                return;
            };
            if (name.indexOf(".") != -1)
                name = name.split(".")[1];
            name = name.replace(/([A-Z])/g, "_$1").toLowerCase();
            var text = $(focusNode).parent().prev().text().replace("*", "").replace(":", "").replace("：", "");
            $(focusNode).remove();
            if (tagIsTextArea) {
                insert("textarea");
                var property = [];
                property.push({key: "style", value: "width:90%"});
                fieldData[nowEditorTarget][fieldData[nowEditorTarget].length - 1].value = mini.encode(property);
            } else if (tagIsDate) {
                insert("datepicker");
                var property = [];
                property.push({key: "style", value: "width:200px"});
                fieldData[nowEditorTarget][2].value = "date";
                fieldData[nowEditorTarget][3].value = "date";
                fieldData[nowEditorTarget][fieldData[nowEditorTarget].length - 1].value = mini.encode(property);
            } else if (tagIsInput) {
                insert("textbox");
                var property = [];
                property.push({key: "style", value: "width:200px"});
                fieldData[nowEditorTarget][fieldData[nowEditorTarget].length - 1].value = mini.encode(property);
            } else if (tagIsSelect) {
                insert("combobox");
                var childs = $($(focusNode).children()).select('option');
                var data = [];
                $(childs).each(function (i, e) {
                    if ($(e).val()) {
                        data.push({id: $(e).val(), text: $.trim($(e).text())});
                    }
                });
                var dataJson = mini.encode(data).replace(/"([^"]*)"/g, "'$1'");
                var conf = Designer.fields["combobox"];
                var property = conf.defaultData;
                $(property).each(function (i, e) {
                    if (e.key == "data")e.value = dataJson;
                });
                property.push({key: "style", value: "width:200px"});
                fieldData[nowEditorTarget][fieldData[nowEditorTarget].length - 1].value = mini.encode(property);
            }
            if (name) {
                fieldData[nowEditorTarget][0].value = name;
                fieldData[nowEditorTarget][1].value = text;
            }
        } else {
            nowEditorTarget = "main";
        }
    }
    initProperties();
});
function showEditor(e) {
    var row = e.record;
    var data = list2Map(propertiesTable.getData());
    var conf = Designer.fields[data._meta];
    if (conf) {
        var editor = conf.getPropertiesEditor()[row.key];
        if (editor) {
            editor(data, function (e) {
                $(fieldData[nowEditorTarget]).each(function (index, d) {
                    if (d.key == row.key) {
                        d.value = e;
                    }
                });
                initProperties();
            });
            e.cancel = true;
        }
    }
}
function deploy() {
    logger.warn("发布表单后，表单将即刻生效，请确定表单已编辑完成!");
    mini.confirm("确定发布此表单?", "确定？",
        function (action) {
            if (action == "ok") {
                save(function () {
                    Request.put("form/" + id + "/deploy", {}, function (e) {
                        if (e.success)logger.info("发布成功!");
                        else logger.error(e.message);
                    })
                });
            }
        }
    );
}
function list2Map(list) {
    var map = {};
    $(list).each(function (index, o) {
        map[o.key] = o.value;
    });
    return map;
}
function cellbeginedit(e) {
    var row = e.record;
    var map = list2Map(propertiesTable.getData());
    var conf = Designer.fields[map._meta];
    if (conf) {
        e.cancel = !conf.propertiesEditable(row.key);
    }
    showEditor(e);
}
function submitProperties(e) {
    var now = list2Map(propertiesTable.getData());
    for (var fid in fieldData) {
        if (fid == "main" || fid == nowEditorTarget)continue;
        var field = list2Map(fieldData[fid]);
        if (now.name == field.name) {
            logger.error("存在相同的字段:" + field.name);
        }
    }
    fieldData[nowEditorTarget] = getCleanData(propertiesTable);
}
function initProperties() {
    var data = fieldData[nowEditorTarget];
    var newData = [];
    if (!data) {
        data = Designer.fields["textbox"].getDefaultProperties();
    }
    var map = list2Map(data);
    var meta = map["_meta"];
    var conf = Designer.fields[meta];
    if (!conf) {
        return;
    }
    $(conf.getDefaultProperties()).each(function (i, e) {
        if (map[e.key]) {
            e.value = map[e.key];
            newData.push(e);
        } else {
            newData.push(e);
        }
    });
    fieldData[nowEditorTarget] = newData;
    propertiesTable.setData(newData);
}
function insert(id) {
    var conf = Designer.fields[id];
    var f_id = randomChar();
    if (conf) {
        ue.execCommand('insertHtml', conf.html(f_id))
        nowEditorTarget = f_id;
        fieldData[nowEditorTarget] = conf.getDefaultProperties();
        initProperties();
    }
}

function nodedblclick(e) {
    var node = e.node;
    insert(node.id);
}

function randomChar(len) {
    len = len || 32;
    var $chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz';
    var maxPos = $chars.length;
    var pwd = '';
    for (var i = 0; i < len; i++) {
        pwd += $chars.charAt(Math.floor(Math.random() * maxPos));
    }
    return pwd;
}
function getFormData() {
    var form = {};
    var otherAttr = {};
    var defAttr = ["name", "remark"];
    $(fieldData.main).each(function (i, e) {
        if (e.key == 'comment')form.remark = e.value;
        if (defAttr.indexOf(e.key) != -1) {
            form[e.key] = e.value;
        } else {
            otherAttr[e.key] = e.value;
        }
    });
    form.classifiedId=mini.get('classifiedId').getValue();
    form.config = mini.encode(otherAttr);
    form.html = ue.getContent();
    return form;
}
function downloadForm() {
    var form = getFormData();
    var tmp = $(form.html);
    for (var e in fieldData) {
        if (e == "main")continue;
        var field = tmp.find("[field-id='" + e + "']");
        if (field.length == 0) {
            delete  fieldData[e];
        }
    }
    form.meta = mini.encode(fieldData);
    downloadText(mini.encode(form), form.name + ".json");
}

function importForm() {
    openFileUploader("json", "上传表单", function (e) {
        if (e.length > 0) {
            var file = e[0];
            Request.get("file/download/" + file.id, function (e) {
                if (e && e.meta) {
                    fieldData = mini.decode(e.meta);
                    ue.setContent(e.html);
                    initProperties();
                } else {
                    showTips("请确定您上传的文件正确!", "danger");
                }
            });
        }
    });
}
function save(callback) {
    var form = getFormData();
    if(form.name==''){
        showTips("未设置表名","danger");
        return;
    }
    var tmp = $(form.html);
    for (var e in fieldData) {
        if (e == "main")continue;
        var field = tmp.find("[field-id='" + e + "']");
        if (field.length == 0) {
            delete  fieldData[e];
        }
    }
    form.meta = mini.encode(fieldData);
    var func;
    var api = "form/" + id;
    if (id == "") {
        func = Request.post;
    } else {
        func = Request.put;
    }
    func(api, form, function (e) {
        if (e.success) {
            logger.info("保存成功!");
            if (id == "") {
                id = e.data;
                if (window.history.pushState)
                    window.history.pushState(0, "", "?id=" + id);
            }
            if (callback)
                callback();
        } else {
            logger.error("保存失败:" + e.message);
        }
    });
}

var logger = {
    append: function (level, msg) {
        $(".logger").append("<br/>$->" + level + ": " + msg);
        $(".logger").scrollTop($(".logger").scrollTop() + 100);//= document.getElementById(id).scrollTop+99999999;
    }
    , info: function (msg) {
        logger.append("INFO", "<span class='info'>" + msg + "</span>");
    }, debug: function (msg) {
        logger.append("DEBUG", "<span class='debug'>" + msg + "</span>");
    }, error: function (msg) {
        logger.append("ERROR", "<span class='error'>" + msg + "</span>");
    }, warn: function (msg) {
        logger.append("WARN", "<span class='warn'>" + msg + "</span>");
    }
};
var nowPress = {};
var lstr = {};
function setShortcut(key, callback) {
    lstr[key] = callback;
}

function doListener() {
    var name = "";
    for (var e in nowPress) {
        name += "+" + e;
    }
    name = name.substr(1);
    // logger.info(name);
    if (lstr[name]) {
        lstr[name]();
        return true;
    }
    return false;
}
function initShortcut() {
    $(window).keydown(function (e) {
        nowPress[e.originalEvent.code] = true;
        return !doListener();
    });

    $(window).keyup(function (e) {
        delete  nowPress[e.originalEvent.code];
    });

    for (var i = 0; i < window.frames.length; i++) {
        var e = window.frames[i];
        $(e.document).keydown(function (e) {
            nowPress[e.originalEvent.code] = true;
            return !doListener();
        });
        $(e.document).keyup(function (e) {
            delete  nowPress[e.originalEvent.code];
        });
    }
}

function autoCreateModule() {
    mini.confirm("创建前请确定已发布此表单?", "确定？",
        function (action) {
            if (action == "ok") {
                if (id != "") {
                    Request.post("module-view/create", id, function (e) {
                        if (e.success) {
                            openWindow(Request.BASH_PATH + "admin/system-dev/save.html?id=" + e.data, "模块配置", "80%", "80%", function (e1) {
                            });
                        } else {
                            showTips("创建失败:" + e.message, "danger");
                        }
                    });
                } else {
                    mini.alert("请先保存此表单!");
                }
            }
        });
}
function removeChooseFieldRow(e) {
    var grid = mini.get('chooseFieldGrid');
    grid.findRow(function (row) {
        if (row && row.name == e) {
            grid.removeRow(row);
            return true;
        }
    });
}
function renderChooseFieldAction(e) {
    return "<a href=\"javascript:removeChooseFieldRow('" + e.record.name + "')\">移除</a>";
}