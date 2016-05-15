/**
 * Created by zhouhao on 16-5-7.
 */
mini.parse();
var grid = mini.get('grid');
var employee_grid = mini.get("employee_grid");
var detailGrid_Form = document.getElementById("detailGrid_Form");
bindDefaultAction(employee_grid);
bindDefaultAction(grid);
search();
function create() {
    openWindow(Request.BASH_PATH + "admin/form/designer.html", "新建表单", "100%", "100%", function (e) {
        grid.reload();
    });
}
function edit(id) {
    openWindow(Request.BASH_PATH + "admin/form/designer.html?id=" + id, "编辑表单", "100%", "100%", function (e) {
        grid.reload();
    });
}

function deploy(id) {
    mini.confirm("确定发布此表单?", "确定？",
        function (action) {
            if (action == "ok") {
                Request.put("form/" + id + "/deploy", {}, function (e) {
                    if (e.success)showTips("发布成功!");
                    else showTips(e.message,'danger');
                    grid.reload();
                });
            }
        }
    );
}
function undeploy(id) {
    mini.confirm("确定取消发布此表单?", "确定？",
        function (action) {
            if (action == "ok") {
                Request.put("form/" + id + "/unDeploy", {}, function (e) {
                    if (e.success)showTips("取消发布成功!");
                    else showTips(e.message,'danger');
                    grid.reload();
                });
            }
        }
    );
}
function onShowRowDetail(e) {
    var grid = e.sender;
    var row = e.record;
    var td = grid.getRowDetailCellEl(row);
    td.appendChild(detailGrid_Form);
    detailGrid_Form.style.display = "block";
    var param=Request.encodeParam({name:row.name,'id$NOT':row.id});
    param.paging=false;
    param.excludes = "config,meta,html";
    param.sortFiled="version";
    param.sortOrder="desc";
    employee_grid.load(param);
}

function newVersion(id){
    mini.confirm("确定创建新版本?", "确定？",
        function (action) {
            if (action == "ok") {
                grid.loading("创建中...");
                Request.post("form/" + id + "/new-version", {}, function (e) {
                    if (e.success) {
                        edit(e.data);
                    } else {
                        showTips(e.message, 'danger');
                    }
                    grid.reload();
                });
            }
        }
    );
}

function renderStatus(e) {
    if (e.value)return "<span style='color: red'>已发布</span>";
    else return "<span style='color: green'>未发布</span>";
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
    queryParam.excludes = "config,meta,html";
    grid.load(queryParam);
}
function createActionButton(text, action, icon) {
    return '<span class="action-span" title="' + text + '" onclick="' + action + '">' +
        '<i class="action-icon ' + icon + '"></i>' + "" //text
        + '</span>&nbsp;&nbsp;';
}
function rendererAction(e) {
    var grid = e.sender;
    var record = e.record;
    var uid = record.id;
    var actionList = [];
    if (accessCreate) {
        var removeHtml = createActionButton("创建新版本", 'newVersion(\'' + uid + '\')', "icon-add");
        actionList.push(removeHtml);
    }
    if (accessUpdate) {
        var editHtml = createActionButton("编辑", 'edit(\'' + uid + '\')', "icon-edit");
        actionList.push(editHtml);
    }
    if (accessDelete) {
        var removeHtml = "";
        if (!record.using)
            removeHtml = createActionButton("删除", 'removeForm(\'' + uid + '\')', "icon-remove");
        ;//'<span class="action-span"><span class="action-icon icon-remove" onclick="removeForm(\'' + uid + '\')"></span>删除';
        actionList.push(removeHtml);
    }
    if (accessDeploy) {
        var removeHtml = "";
        if (!record.using)
            removeHtml = createActionButton("发布", 'deploy(\'' + uid + '\')', "icon-goto");
        else
            removeHtml = createActionButton("取消发布", 'undeploy(\'' + uid + '\')', "icon-cross");
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