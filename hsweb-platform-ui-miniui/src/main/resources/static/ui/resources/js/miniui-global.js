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

function openWindow(url, title, width, height, ondestroy) {
    mini.open({
        url: url,
        showMaxButton: true,
        title: title,
        width: width,
        height: height,
        maskOnLoad: false,
        ondestroy: ondestroy
    });
}
function openFileUploader(accept, title, onupload) {
    if (!accept)accept = "";
    openWindow(Request.BASH_PATH + "admin/utils/fileUpload.html?accept=" + accept, title, "600", "500", function (e) {
        if (e != 'close' && e != 'cancel') {
            onupload(e);
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
        if (e.editor.type == "buttonedit") {
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
    grid.un("loaderror", function (e) {
    });
    grid.on("loaderror", function (e) {
        var res = mini.decode(e.xhr.responseText);
        if (res.code == 401) {
            doLogin(function () {
                grid.reload()
            });
        }
        if (res.code == 403) {
            showTips("权限不够", "danger");
        }
        if (res.code == 500) {
            showTips("数据加载失败:系统错误", "danger");
            if (window.console) {
                window.console.log(res.message);
            }
        }
    });
}

function doLogin(cbk) {
    openWindow(Request.BASH_PATH + "admin/login.html?uri=ajax", "登录超时,请重新登录!", "600", "400", function (e1) {
        if ("success" == e1)
            cbk();
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