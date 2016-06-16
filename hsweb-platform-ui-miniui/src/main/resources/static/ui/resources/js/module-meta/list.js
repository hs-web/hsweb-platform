/**
 * Created by zhouhao on 16-5-7.
 */
mini.parse();
var grid = mini.get('grid');
grid.load();
bindDefaultAction(grid);
function edit(id) {
    openWindow(Request.BASH_PATH + "admin/system-dev/save.html?id=" + id + "&module_id=" + nowSelectedModuleId, "编辑模块", "80%", "80%", function (e) {
        grid.reload();
    });
}

function create() {
    openWindow(Request.BASH_PATH + "admin/system-dev/save.html?module_id=" + nowSelectedModuleId, "新建模块", "80%", "80%", function (e) {
        grid.reload();
    });
}

function deleteMeta(id) {
    mini.confirm("确定删除此设置，删除相关功能将无法访问!", "确认?", function (action) {
        if (action == 'ok') {
            Request['delete']("module-meta/" + id, {}, function (e) {
                grid.reload();
                if (e.success)showTips("删除成功");
                else showTips("删除失败:" + e.message);
            });
        }
    });
}

function copy(id) {
    Request.get("module-meta/" + id, {}, function (e) {
        if (e.success) {
            delete  e.data.id;
            Request.post("module-meta", e.data, function (e) {
                if (e.success) {
                    edit(e.data);
                } else {
                    mini.alert(e.message);
                }
            });
        } else {
            mini.alert(e.message);
        }
    });
}

function rendererAction(e) {
    var grid = e.sender;
    var record = e.record;
    var uid = record.id;
    var actionList = [];
    if (accessUpdate) {
        var editHtml = '<span class="fa fa-edit action-edit action" onclick="edit(\'' + uid + '\')">编辑</span>';
        actionList.push(editHtml);
    }
    if (accessUpdate) {
        var editHtml = '<span class="fa fa-copy action-edit action" onclick="copy(\'' + uid + '\')">复制</span>';
        actionList.push(editHtml);
    }
    if (accessDelete) {
        var editHtml = '<span class="fa fa-close action-remove action" onclick="deleteMeta(\'' + uid + '\')">删除</span>';
        actionList.push(editHtml);
    }
    var html = "";
    $(actionList).each(function (i, e) {
        if (i != 0) {
            html += "&nbsp;&nbsp;";
        }
        html += e;
    });
    return html;
}