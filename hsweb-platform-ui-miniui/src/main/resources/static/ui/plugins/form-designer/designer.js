var fieldData = {};
mini.parse();
var ue = UE.getEditor('container');
var propertiesTable = mini.get('properties-table');
var nowEditorTarget = "main";
ue.ready(function () {
    if (id != "") {
        Request.get("form/" + id, {}, function (e) {
            if (e.success) {
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
    if (id) {
        nowEditorTarget = id;
    } else {
        nowEditorTarget = "main";
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
    fieldData[nowEditorTarget] = propertiesTable.getData();
}
function initProperties() {
    propertiesTable.setData(fieldData[nowEditorTarget]);
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

function save(callback) {
    var form = {};
    var otherAttr = {};
    var defAttr = ["name", "remark"];
    $(fieldData.main).each(function (i, e) {
        if(e.key=='comment')form.remark= e.value;
        if (defAttr.indexOf(e.key) != -1) {
            form[e.key] = e.value;
        } else {
            otherAttr[e.key] = e.value;
        }
    });
    form.config = mini.encode(otherAttr);

    form.html = ue.getContent();
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