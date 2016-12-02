<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
    </style>
</head>
<body>
<div class="mini-toolbar">
    已保存方案:<input name="draft" onvaluechanged="changePlan" showClose="true" oncloseclick="removeDraft" showNullItem="true" textField="name" class="mini-combobox" style="width: 200px" allowInput="true"/>
    <a class="mini-button" iconCls="icon-save" onclick="savePlan()" plain="true">保存</a>
    <a class="mini-button" iconCls="icon-upload" onclick="exportData" plain="true" style="color: red;">导出</a>
    <a class="mini-button" iconCls="icon-undo" onclick="closeWindow()" plain="true">关闭</a>
</div>
<div class="mini-fit">
    <div id="field-list" idField="name" class="mini-datagrid" style="width:100%;height:100%;"
         allowCellEdit="true" multiSelect="true" allowCellSelect="true" showPager="false">
        <div property="columns">
            <div type="checkcolumn" width="10"></div>
            <div name="text" field="text" width="100" align="center" headerAlign="center">表头
                <input property="editor" class="mini-textbox"/>
            </div>
            <div name="action" renderer="renderAction" width="50" align="center" headerAlign="center">操作</div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var forName = "${param.name!''}";
    var repeatMode = [
        {id: "SKIP", text: "跳过"},
        {id: "REPLACE", text: "覆盖"},
        {id: "THROWABLE", text: "报错"}
    ];
    mini.parse();
    var field_list = mini.get('field-list');
    var defaultData = [];
    initField();
    var queryParam;
    function renderAction(e) {
        var gridId = "field_list";
        var id = e.record._id;
        var html = createActionButton("向下移动", "moveDown(" + gridId + ",'" + id + "')", "icon-download");
        html += createActionButton("向上移动", "moveUp(" + gridId + ",'" + id + "')", "icon-upload");
        html += createActionButton("删除", "removeRow(" + gridId + ",'" + id + "')", "icon-remove");
        return html;
    }
    window.setParam = function (param) {
        queryParam = param;
    }
    loadDraft();
    function loadDraft() {
        Request.get("draft/export-" + forName, function (e) {
            if (e.success) {
                mini.getbyName("draft").setData(e.data);
            }
        });
    }
    function changePlan(e) {
        if (e.selected && e.selected.value) {
            field_list.setData(e.selected.value);
        } else {
            field_list.setData(defaultData);
        }
        field_list.selectAll();
    }
    function savePlan() {
        var data = field_list.getData();
        mini.prompt("请输入方案名称：", "请输入",
                function (action, value) {
                    if (action == "ok") {
                        Request.post("draft/export-" + forName, {value: data, name: value}, function (e) {
                            loadDraft();
                            if (e.success) {
                                mini.getbyName("draft").setValue(e.data);
                                showTips("方案已保存.");
                            }
                        });
                    }
                }
        );
    }
    function removeDraft() {
        var id = mini.getbyName("draft").getValue();
        if (id) {
            mini.confirm("确认删除此方案?", "请确认", function (action) {
                if (action == 'ok') {
                    Request['delete']("draft/export-" + forName + "/" + id, function (e) {
                        if (e.success) {
                            showTips("方案已删除.");
                        }
                        loadDraft();
                    });
                }
            });
        }
    }
    function exportData() {
        //  downloadExcel()
        var headerData = field_list.getSelecteds();
        var headers = [];
        $(headerData).each(function () {
            headers.push({title: this.text, field: this.name, sort: this._id});
        });
        queryParam["headers"] = mini.encode(headers);
        submitForm(Request.BASH_PATH + "dyn-form/export/" + forName, "POST", queryParam)
    }
    function initField() {
        Request.get("dyn-form/excel/exports/" + forName, function (e) {
            if (e.success) {
                field_list.setData(e.data);
                field_list.selectAll();
                defaultData = mini.clone(e.data);
            }
        });
    }

</script>
