function trace(count, skip) {
    var caller = arguments.callee.caller;
    var i = 0;
    count = count || 10;
    skip = skip || 0;
    if (window.console) {
        while (caller && i < count) {
            if (i >= skip) {
                console.log(caller.toString());
            }
            caller = caller.caller;
            i++;
        }
    }
}
mini_debugger = false;
function showTips(msg, state) {
    mini.showTips({
        content: msg,
        state: state || 'success',
        x: 'center',
        y: 'top',
        timeout: 3000
    });
}

function openWindow(url, title, width, height, ondestroy, onload) {
    if (url.indexOf("http") != 0) {
        if (url.indexOf("/") == 0)url = url.substr(1);
        url = Request.BASH_PATH + url;
    }
    mini.open({
        url: url,
        showMaxButton: true,
        title: title,
        width: width,
        height: height,
        maskOnLoad: false,
        showModal: false,
        onload: onload,
        ondestroy: ondestroy
    });
}
function openFileUploader(accept, title, onupload, defaultData) {
    if (!accept)accept = "";
    openWindow(Request.BASH_PATH + "admin/utils/fileUpload.html?accept=" + accept, title, "600", "500", function (e) {
        if (e != 'close' && e != 'cancel') {
            onupload(e);
        }
    }, function () {
        var iframe = this.getIFrameEl();
        var win = iframe.contentWindow;

        function init() {
            if (win.grid) {
                if (defaultData) {
                    defaultData = mini.clone(defaultData);
                    $(defaultData).each(function (i, e) {
                        e.status = "已上传";
                        e.resourceId = e.id;
                    });
                    iframe.contentWindow.grid.setData(defaultData);
                }
            }
        }

        $(iframe).on("load", init);
        init();
    });
}
function renderWarningInfo(e) {
    var row = e.record;
    if (!row.warning || !row.warning.u_id) {
        return "/";
    } else {
        e.rowStyle = "background:#FDCECE";
        return row.warning.reason;
    }
}
function createWarning(type, key, pk, cbk) {
    openWindow(Request.BASH_PATH + "admin/warning/save.html", "添加预警信息", "850", "500", cbk, function () {
        var iframe = this.getIFrameEl();
        var win = iframe.contentWindow;

        function init() {
            if (win && win.init) {
                win.init(type, key, pk);
            }
        }

        $(iframe).on("load", init);
        init();
    });
}
function handleWarning(type, pk, cbk) {
    openWindow(Request.BASH_PATH + "admin/warning/handle.html", "处理预警信息", "850", "500", cbk, function () {
        var iframe = this.getIFrameEl();
        var win = iframe.contentWindow;
        function init() {
            if (win && win.init) {
                win.init(key, pk);
            }
        }
        $(iframe).on("load", init);
        init();
    });
}

function openScriptEditor(mode, script, ondestroy) {
    mini.open({
        url: Request.BASH_PATH + "admin/utils/scriptEditor.html",
        showMaxButton: true,
        title: "脚本编辑器",
        width: "80%",
        height: "80%",
        maskOnLoad: false,
        onload: function () {
            var iframe = this.getIFrameEl();
            $(iframe).on("load", function () {
                iframe.contentWindow.init(mode, script);
            });
            iframe.contentWindow.init(mode, script);
        },
        ondestroy: function (e) {
            if (e == "close" || e == "cancel")return;
            ondestroy(e);
        }
    });
}
function closeWindow(action) {
    if (window.CloseOwnerWindow) return window.CloseOwnerWindow(action);
    else window.close();
}
function bindCellBeginButtonEdit(grid) {
    grid.on("cellbeginedit", function (e) {
        if (e.editor && e.editor.type == "buttonedit") {
            e.editor.setValue(e.value);
            e.editor.setText(e.value);
        }
    });
}

function renderIcon(e) {
    return '<i style="width: 16px; height: 16px; display: inline-block; background-position: 50% 50%;line-height: 16px;" ' +
        'class="mini-iconfont ' + e.value + '" style=""></i>';
}
//绑定表格默认属性
function bindDefaultAction(grid) {
    grid.setSortFieldField("sorts[0].name");
    grid.setSortOrderField("sorts[0].dir");
    grid.setAjaxOptions({type: "GET", dataType: "json"});
    grid.un("loaderror", function (e) {
    });
    grid.on("loaderror", function (e) {
        var res = mini.decode(e.xhr.responseText);
        if (res.code == 401) {
            doLogin(function () {
                grid.reload()
            });
        }
        else if (res.code == 403) {
            showTips("权限不够", "danger");
        }
        else if (res.code == 500) {
            showTips("数据加载失败:" + res.message, "danger");
            if (window.console) {
                window.console.log(res.message);
            }
        } else {
            showTips("数据加载失败:" + res.message, "danger");
        }
    });
    var tip = new mini.ToolTip();
    tip.set({
        target: document,
        selector: '.action-span'
    });
}

function doLogin(cbk) {
    openWindow(Request.BASH_PATH + "admin/login.html?uri=ajax", "登录超时,请重新登录!", "600", "400", function (e1) {
        if ("success" == e1)
            cbk();
    });
}

function downloadFile(fileList) {
    $(fileList).each(function (i, file) {
        var iframe = $("<iframe style='display: none'></iframe>");
        iframe.attr("src", Request.BASH_PATH + "file/download/" + file.id + (file.name ? "/" + file.name : ""));
        window.setTimeout(function () {
            $(document.body).append(iframe);
        }, (i + 1) * 600);
    });
}

function getRow(grid, _id) {
    return grid.findRow(function (e) {
        if (e._id == _id)return true;
    });
}

function removeRow(grid, _id) {
    var row = grid.findRow(function (e) {
        if (e._id == _id)return true;
    });
    grid.removeRow(row, true);
}

function moveUp(grid, _id) {
    var arr = grid.findRows(function (row) {
        if (row._id == _id)return true;
    });
    grid.moveUp(arr);
}

function moveDown(grid, _id) {
    var arr = grid.findRows(function (row) {
        if (row._id == _id)return true;
    });
    grid.moveDown(arr);
}

function getCleanData(grid) {
    var data = mini.clone(grid.getData());
    $(data).each(function (i, e) {
        delete e["_id"];
        delete e["_uid"];
        delete e["_state"];
    });
    return data;
}
var User = function () {
    var tmp = this;
    this.getModuleData = function () {
        return tmp.info['modulesData'];
    };
    this.getAccessOrgIds = function () {
        if (tmp.info.accessOrgIds) {
            return mini.clone(tmp.info.accessOrgIds);
        }
        return [];
    };
    this.getAccessAreaIds = function () {
        if (tmp.info.accessAreaList) {
            return mini.clone(tmp.info.accessAreaList);
        }
        return [];
    };
    this.isRootOrgUser = function () {
        return tmp.info.rootOrgUser;
    };
    this.getMaxAreaLevel = function () {
        return tmp.info.maxAreaLevel;
    };
    this.getModuleMapData = function () {
        return tmp.info['moduleMapData'];
    };
    this.getModulesMenuData = function () {
        return tmp.info['modulesMenuData'];
    };
    this.load = function (func) {
        var e = Request.get("userModule/loginUser");
        if (e) {
            tmp.info = e;
            tmp.info.modulesMenuData = [];
            tmp.info.moduleMapData = {};
            var mData = tmp.info['modulesData'];
            for (var i = 0; i < mData.length; i++) {
                tmp.info.moduleMapData[mData[i].id] = mData[i];
                //持有M权限
                if (tmp.hasAccessModule(mData[i].id, "M")) {
                    tmp.info.modulesMenuData.push(mData[i]);
                }
            }
            if (tmp.onload) {
                tmp.onload();
            }
            var expands = e.properties && e.properties.user_expands ? e.properties.user_expands : {};
            tmp.info.accessOrgIds = expands.accessOrgIds;
            tmp.info.accessAreaList = expands.accessAreaList;
            tmp.info.rootOrgUser = expands.rootOrgUser;
            tmp.info.maxAreaLevel = expands.maxAreaLevel;
            if (func)func();
        }
    };
    this.hasAccessModule = function () {
        var args = arguments;
        var module = tmp.info.modules[args[0]];
        var mData = tmp.info.moduleMapData[args[0]];
        if (module && mData) {
            if (args.length == 1)return true;
            if (args.length > 1) {
                for (var i = 1; i < args.length; i++) {
                    if (module.indexOf(args[i]) != -1 && mData.optionalMap[args[i]])return true;
                }
            }
        }
        return false;
    };
    this.hasAccessRole = function () {
        var args = arguments;
        var roles = tmp.info['roles'];
        if (roles) {
            for (var i = 0; i < roles.length; i++) {
                for (var j = 0; j < args.length; j++) {
                    if (args[j] == roles[i].roleId)return true;
                }
            }
        }
        return false;
    };
    return this;
};

function getUser(func) {
    if (!window.top.user) {
        window.top.user = new User();
        if (func)
            window.top.user.load(func);
        else
            window.top.user.load(function () {
            });
    }
    if (func) {
        window.setTimeout(func, 10);
    }
    return window.top.user;
}

function downloadText(text, fileName) {
    var form = $("<form style='display: none'></form>");
    form.attr({
        action: Request.BASH_PATH + "file/download-text/" + fileName,
        target: "_blank",
        method: "POST"
    });
    form.append($("<input name='text' />").val(text));
    form.appendTo(document.body);
    form.submit();
}

function downloadZip(data, fileName) {
    var form = $("<form style='display: none'></form>");
    form.attr({
        action: Request.BASH_PATH + "file/download-zip/" + fileName,
        target: "_blank",
        method: "POST"
    });
    form.append($("<input name='data' />").val(mini.encode(data)));
    form.appendTo(document.body);
    form.submit();
}

function submitForm(url, method, param) {
    var form = $("<form style='display: none'></form>");
    form.attr({
        action: url,
        target: "_blank",
        method: method
    });
    for (var i in param) {
        form.append($("<input name='" + i + "' />").val(param[i]));
    }
    form.appendTo(document.body);
    form.submit();

}
function createActionButton(text, action, icon) {
    return '<span class="action-span" title="' + text + '" onclick="' + action + '">' +
        '<span class="action-icon ' + icon + '"></span>' + "" //text
        + '</span>';
}
String.prototype.endWith = function (str) {
    var reg = new RegExp(str + "$");
    return reg.test(this);
};

function downloadExcel(headerJson, dataJson, fileName) {
    var form = $("<form style='display: none'></form>");
    form.attr({
        action: Request.BASH_PATH + "file/download/" + fileName + ".xlsx",
        target: "_blank",
        method: "POST"
    });
    form.append($("<input name='header' />").val(headerJson));
    form.append($("<input name='data' />").val(dataJson));
    form.appendTo(document.body);
    form.submit();
}


function downloadGridExcel(grid, fileName) {
    var columns = grid.getColumns();
    var header = [{title: "序号", field: "__index"}];
    var renderer = {};
    $(columns).each(function () {
        if (this.visible && this.displayField && this.field) {
            renderer[this.displayField ? this.displayField : this.field] = this.renderer;
            header.push({title: this.header, field: this.displayField ? this.displayField : this.field});
        }
    });
    var datas = mini.clone(grid.getData());

    $(datas).each(function (i, e) {
        e.__index = i + 1;
        for (var f in e) {
            if (renderer[f]) {
                window.tmp_row = {record: e, value: e[f]};
                e[f] = eval("(function(){return " + renderer[f] + "(window.tmp_row);})()");
            }
        }
    });
    downloadExcel(mini.encode(header), mini.encode(datas), fileName);
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

function openCronEditor(cbk, cron) {
    openWindow(Request.BASH_PATH + "ui/plugins/crontool/index.html", "Cron选择器", "840", "530", function (cron) {
        if (cron != "close" && cron != "cancel") {
            cbk(cron);
        }
    }, function () {
        var iframe = this.getIFrameEl();
        var win = iframe.contentWindow;

        function init() {
            if (win.setCron) {
                win.setCron(cron);
            }
        }

        init();
        $(iframe).on("load", init);
    });
}

function compareDateWithMs(date3) {
    var days = Math.floor(date3 / (24 * 3600 * 1000));
    var leave1 = date3 % (24 * 3600 * 1000);
    var hours = Math.floor(leave1 / (3600 * 1000));
    var leave2 = leave1 % (3600 * 1000);
    var minutes = Math.floor(leave2 / (60 * 1000));
    var leave3 = leave2 % (60 * 1000);
    var seconds = Math.round(leave3 / 1000);
    var leave4 = leave3 % (1000);
    var mseconds = Math.round(leave4);
    var string = "";
    if (days > 0) {
        string += days + "天";
    }
    if (hours > 0) {
        string += hours + "小时";
    }
    if (minutes > 0) {
        string += minutes + "分钟";
    }
    if (seconds > 0) {
        string += seconds + "秒";
    }
    if (seconds == 0 && minutes == 0 && hours == 0 && days == 0) {
        string += mseconds + "毫秒";
    }
    return string;
}

function compareDate(d1, d2) {
    return compareDateWithMs(Math.abs(d2.getTime() - d1.getTime()));
}

function openTextWindow(text) {
    var win = window.open("about:blank");
    win.document.write("<textarea style=\"border: 0px;width: 100%;height: " + ($(document).height()) + "px\">" + text + "</textarea>");
    $(win.document.body).css({
        padding: 0,
        border: 0,
        margin: 0
    });
}