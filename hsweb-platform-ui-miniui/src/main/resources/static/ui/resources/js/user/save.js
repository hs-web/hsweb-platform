/**
 * Created by zhouhao on 16-5-6.
 */
mini.parse();
uParse('#data-form', {
    rootPath: Request.BASH_PATH+'ui/plugins/ueditor',
    chartContainerHeight: 500
});
var roleGrid = mini.get('roleGrid');

roleGrid.load();
roleGrid.on("load",function(e){
    loadData();
});
function loadData() {
    if (id != "") {
        Request.get("user/" + id, {}, function (e) {
            if (e.success) {
                e.data.password = "$default";
                var userRoles = e.data.userRoles;
                new mini.Form('#data-form').setData(e.data);
                $(userRoles).each(function(i,e){
                    var rows=[];
                    roleGrid.findRow(function(row){
                        if(row.u_id== e.role_id)rows.push(row);
                    });
                    roleGrid.selects(rows);
                });
            }
        });
    }
}

function save() {
    var api = "user/" + id;
    var func = id == "" ? Request.post : Request.put;
    var form = new mini.Form("#data-form");
    form.validate();
    if (form.isValid() == false) return;
    //提交数据
    var data = form.getData();
    var userRoles=[];
    var selected=roleGrid.getSelecteds();
    $(selected).each(function(i,e){
        userRoles.push({role_id: e.u_id});
    });
    data.userRoles=userRoles;
    func(api, data, function (e) {
        if (e.success) {
            if (id == '') {
                //新增
                window.history.pushState(0, "", '?id=' + e.data);
                id = e.data;
                showTips("创建成功!");
                $('#title').html("编辑用户");
            } else {
                //update
                showTips("修改成功!");
            }
        }else{
            showTips(e.message,"danger");
        }
    });
}
