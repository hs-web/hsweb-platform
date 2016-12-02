var readOnly = false;
var formParser = new FormParser({name: formName, version: version, target: "#formContent"});
var grid;
var win;
var needAudit = true;
var eventTmp = {};
var loaded = false;
window.onInit = function (data, formData, scriptText) {
    if (scriptText) {
        var script = "(function(){return function(data,formData){" + scriptText + "}})()";
        eval(script)(data, formData);
    }
}

formParser.on = function (type, func) {
    eventTmp[type] = func;
    if (type == "load" && loaded)func();
}
formParser.onload = function () {
    mini.parse();
    grid = mini.get("grid");
    win = mini.get("window");
    loadDraft();
    var meta = formParser.data.meta.main;
    var conf = list2Map(meta);
    //数据需要审核
    needAudit = conf.needAudit;
    uParse('#formContent', {
        rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
        chartContainerHeight: 5000
    });
    $(".mini-radiobuttonlist td").css("border", "0px");
    $(".mini-checkboxlist td").css("border", "0px");
    $(".mini-radiobuttonlist").css("display ", "inline");
    Mousetrap.bind('ctrl+s', function (e) {
        saveDraft();
        return false;
    });
    Mousetrap.bind('ctrl+q', function (e) {
        win.show();
        return false;
    });
    loaded = true;
    if (eventTmp["load"])
        eventTmp["load"]();
    if (readOnly)formParser.setReadonly();
    if (window.resizeWindow) {
        window.resizeWindow(document.body.scrollHeight + 50);
    }
};
load();

window.setReadOnly = function () {
    readOnly = true;
}
window.set = function (property, value, text) {
    if (!mini.getbyName(property))return;
    mini.getbyName(property).setValue(value);
    if (text)
        mini.getbyName(property).setText(text);
}
window.setData = function (d, formData) {
    formParser.on("load", function () {
        formParser.setData(d);
    });
}
window.getData = function () {
    return formParser.getData();
}
window.init = function () {
    $('.tools').hide();
}
window.validate = function () {
    return formParser.validate();
}
function list2Map(list) {
    var map = {};
    $(list).each(function (index, o) {
        map[o.key] = o.value;
    });
    return map;
}

function rendererAction(e) {
    return createActionButton("选择草稿", "chooseDraft(" + e.record._id + ")", "icon-tick") + createActionButton("删除草稿", "removeDraft('" + e.record.id + "')", "icon-remove");
}
function removeDraft(id) {
    mini.confirm("确定删除此草稿？", "确定？",
        function (action) {
            if (action == "ok") {
                Request['delete']("draft/" + formName + "/" + id, {}, function (e) {
                    if (e.success) {
                        showTips("删除成功");
                        loadDraft();
                    } else {
                        mini.alert("删除失败:" + e.message);
                    }
                });
            }
        }
    );
}

function chooseDraft(rowId) {
    var row;
    if (rowId)
        row = getRow(grid, rowId);
    else {
        row = grid.getSelected();
    }
    if (row.value) {
        formParser.setData(row.value);
    }
    win.hide();
}
function load() {
    if (id != "") {
        var api = "dyn-form/" + formName + "/" + id;
        Request.get(api, {}, function (e) {
            if (e.success) {
                formParser.load(e.data);
            } else {
                mini.alert(e.message);
            }
        });
    } else {
        formParser.load();
    }
}
function loadDraft() {
    $("#draftLi").hide();
    Request.get("draft/" + formName, {}, function (e) {
        if (e.success) {
            grid.setData(e.data);
            if (e.data.length > 0) {
                $(".draftSize").text(e.data.length);
                $("#draftLi").show();
            }
        }
    });
}
function saveDraft() {
    var data = formParser.getData(false);
    if (!data)return;
    for (var f in data) {
        if (typeof (data[f]) == 'object') {
            if (mini.getbyName(f))
                data[f] = mini.getbyName(f).getFormValue();
        }
    }
    mini.prompt("请输入草稿名称：", "请输入",
        function (action, value) {
            if (action == "ok") {
                Request.post("draft/" + formName, {value: data, name: value}, function (e) {
                    if (e.success) {
                        showTips("草稿已保存.", "danger");
                    }
                    loadDraft();
                });
            }
        }
    );
}

function doSave(func, api, data) {
    var box = mini.loading("提交中...", "");
    func(api, data, function (e) {
        mini.hideMessageBox(box);
        if (e.success) {
            if (id == "") {
                id = e.data;
                formParser.setData(data);
                showTips("保存成功");
                if (window.history.pushState)
                    window.history.pushState(0, "", "?id=" + id);
            } else {
                if (e.data == 1)
                    showTips("保存成功!");
                if (e.data == 2)
                    showTips("保存成功,部分数据需要审核通过后才能生效!");
                if (e.data == -1)
                    showTips("保存成功,部分数据由于上次提交还未审核,所以无法修改!");
            }
        } else if (e.code == 400) {
            try {
                var validMessage = mini.decode(e.message);
                $(validMessage).each(function (i, e) {
                    var el = mini.getbyName(e.field);
                    if (el) {
                        mini.getbyName(e.field).setIsValid(false);
                        mini.getbyName(e.field).setErrorText(e.message);
                    } else {
                        var helper = formParser.helper;
                        for (var name in helper) {
                            var h = helper[name];
                            function validFrame(win) {
                                if (win && win.mini) {
                                    el = win.mini.getbyName(e.field);
                                    if (el) {
                                        el.setIsValid(false);
                                        el.setErrorText(e.message);
                                    }
                                }
                            }

                            if (h.window.helper) {
                                for(var tmp in h.window.helper){
                                    validFrame(h.window.helper[tmp].window);
                                }
                            } else {
                                validFrame(h.window);
                            }

                        }
                    }
                });
                showTips("保存失败:" + validMessage[0].message + "....", "danger")
            } catch (e) {
                if (window.console) {
                    console.log(e);
                }
                mini.alert("保存失败,请联系管理员!");
            }
        } else {
            showTips("保存失败!", "danger")
        }
    });
}
function save() {
    var api = "dyn-form/" + formName + "/" + id;
    var func = id == "" ? Request.post : Request.put;
    //提交数据
    var data = formParser.getData(true);
    if (!data)return;
    for (var f in data) {
        if (typeof (data[f]) == 'object') {
            if (mini.getbyName(f))
                data[f] = mini.getbyName(f).getFormValue();
        }
    }
    doSave(func, api, data)
}