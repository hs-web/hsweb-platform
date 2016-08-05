/**
 * Created by zhouhao on 16-5-6.
 */

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

function bindDefaultAction(grid) {
    grid.setSortFieldField("sorts[0].field");
    grid.setSortOrderField("sorts[0].dir");

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
            showTips("数据加载失败:系统错误", "danger");
            if (window.console) {
                window.console.log(res.message);
            }
        } else {
            showTips("数据加载失败:" + res.message, "danger");
        }
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

function downloadText(text, fileName) {
    try {
        var aLink = document.createElement('a');
        var blob = new Blob(["\ufeff" + text]);
        var evt = document.createEvent("HTMLEvents");
        evt.initEvent("click", false, false);
        aLink.download = fileName;
        aLink.href = URL.createObjectURL(blob);
        aLink.dispatchEvent(evt);
    } catch (e) {
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
}

function downloadZip(data, fileName) {
    var form = $("<form style='display: none'></form>");
    form.attr({
        action: Request.BASH_PATH + "file/download-zip/" + fileName,
        target: "_blank",
        method: "POST"
    });
    form.append($("<input name='data' />").val(data));
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
}
