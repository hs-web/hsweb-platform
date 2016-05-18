/**
 * Created by zhouhao on 16-5-7.
 */
mini.parse();
var grid = mini.get('grid');
bindDefaultAction(grid);
search();
function create() {
    openWindow(Request.BASH_PATH+"admin/user/save.html", "新建用户", 700, 500, function (e) {
        grid.reload();
    });
}
function edit(id) {
    openWindow(Request.BASH_PATH+"admin/user/save.html?id=" + id, "编辑用户", 700, 500, function (e) {
        grid.reload();
    });
}

function renderStatus(e) {
    if (e.value == -1)return "<span style='color: red'>已禁用</span>";
    else return "<span style='color: green'>正常</span>";
}

function enable(id) {
    grid.loading("启用中...");
    Request.put("user/" + id + "/enable", {}, function (e) {
        if (e.success) {
            grid.reload();
            showTips("启用成功!");
        } else {
            showTips(e.message, 'danger');
        }
    });
}
function disable(id) {
    mini.confirm("确定注销此用户？注销后用户不能再登录系统!", "确定？",
        function (action) {
            if (action == "ok") {
                grid.loading("注销中...");
                Request.put("user/" + id + "/disable", {}, function (e) {
                    if (e.success) {
                        grid.reload();
                        showTips("注销成功!");
                    } else {
                        showTips(e.message, 'danger');
                    }
                });
            }
        }
    );
}

function search() {
    var data = new mini.Form("#searchForm").getData();
    var queryParam = Request.encodeParam(data);
    grid.load(queryParam);
}

function rendererAction(e) {
    var grid = e.sender;
    var record = e.record;
    var uid = record.id;
    var actionList = [];
    if (accessUpdate) {
        var editHtml = '<span class="fa fa-edit action-edit" onclick="edit(\'' + uid + '\')">编辑</span>';
        actionList.push(editHtml);
    }
    if (accessDelete) {
        var removeHtml = "";
        if (record.status == -1)
            removeHtml = '<span  class="fa fa-level-up action-enable" onclick="enable(\'' + uid + '\')">启用</span>';
        else
            removeHtml = '<span  class="fa fa-times action-remove" onclick="disable(\'' + uid + '\')">注销</span>';
        actionList.push(removeHtml);
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