/**
 * Created by zhouhao on 16-5-7.
 */
mini.parse();
var grid = mini.get('grid');
grid.load();
bindDefaultAction(grid);
function edit(id){
    openWindow(Request.BASH_PATH+"admin/role/save.html?id="+id,"编辑角色","80%","80%",function(e){
        grid.reload();
    });
}

function create(){
    openWindow(Request.BASH_PATH+"admin/role/save.html","新建角色","80%","80%",function(e){
        grid.reload();
    });
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
    var html = "";
    $(actionList).each(function (i, e) {
        if (i != 0) {
            html += "&nbsp;&nbsp;";
        }
        html += e;
    });
    return html;
}