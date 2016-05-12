/**
 * Created by zhouhao on 16-5-7.
 */
mini.parse();
var grid = mini.get('grid');
grid.load();

function edit(id){
    openWindow(Request.BASH_PATH+"admin/system-dev/save.html?id="+id+"&module_id="+nowSelectedModuleId,"编辑模块","80%","80%",function(e){
        grid.reload();
    });
}

function create(){
    openWindow(Request.BASH_PATH+"admin/system-dev/save.html?module_id="+nowSelectedModuleId,"新建模块","80%","80%",function(e){
        grid.reload();
    });
}

function rendererAction(e) {
    var grid = e.sender;
    var record = e.record;
    var uid = record.u_id;
    var actionList = [];
    if (accessUpdate) {
        var editHtml = '<span class="fa fa-edit action-edit" onclick="edit(\'' + uid + '\')">编辑</span>';
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