<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importUeditorParser/>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 100%;
        }
    </style>
</head>
<body>
<div id="data-form" style="margin-top:20px">
    <!--表单内容-->
    <table data-sort="sortDisabled" style="width:90%;margin: auto;">
        <tbody>
        <tr class="firstRow">
            <th style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4">
				<span style="font-size: 24px;">
					数据源管理
				</span>
            </th>
        </tr>
        <tr>
            <td valign="middle" style="border-color: rgb(221, 221, 221); word-break: break-all;"
                width="180" align="right">
                ID
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221);" width="371">
                <input class="mini-textbox" required="true" name="id" style="width:100%">
            </td>
            <td valign="middle" style="border-color: rgb(221, 221, 221); word-break: break-all;"
                width="180" align="right">
                名称
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221); word-break: break-all;"
                width="500">
                <input class="mini-textbox" required="true" name="name" style="width:100%">
            </td>
        </tr>
        <tr>
            <td valign="middle" style="border-color: rgb(221, 221, 221); word-break: break-all;"
                width="89" align="right">
                url
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="3">
                <input class="mini-textbox" required="true" name="url" style="width:100%">
            </td>
        </tr>
        <tr>
            <td valign="middle" style="border-color: rgb(221, 221, 221); word-break: break-all;"
                width="89" align="right">
                username
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221);" width="372">
                <input class="mini-textbox" required="true" name="username" style="width:100%">
            </td>
            <td valign="middle" style="border-color: rgb(221, 221, 221); word-break: break-all;"
                width="155" align="right">
                password
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221);" width="821">
                <input class="mini-textbox" name="password" style="width:100%">
            </td>
        </tr>
        <tr>
            <td valign="middle" style="border-color: rgb(221, 221, 221); word-break: break-all;"
                width="89" align="right">
                test-sql
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221);" rowspan="1"
                colspan="3">
                <input class="mini-textbox" required="true" name="testSql" style="width:100%">
            </td>
        </tr>
        <tr>
            <td valign="middle" colspan="1" rowspan="1" style="border-left-color: rgb(221, 221, 221); border-top-color: rgb(221, 221, 221); word-break: break-all;"
                align="right">
                备注
            </td>
            <td valign="top" colspan="3" rowspan="1" style="border-left-color: rgb(221, 221, 221); border-top-color: rgb(221, 221, 221); word-break: break-all;">
                <input class="mini-textarea" name="remark" style="width:100%">
            </td>
        </tr>
        </tbody>
    </table>
</div>
<div >

</div>
<div style="width: 100%;height: 20px;text-align: center">
    <a class="mini-button" iconCls="icon-save" plain="true" onclick="save()">保存</a>
    <a class="mini-button" iconCls="icon-undo" plain="true" onclick="closeWindow('close')">返回</a>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var id = "${param.id!''}";
    mini.parse();
    uParse('#data-form', {
        rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
        chartContainerHeight: 500
    });
    loadData();
    function loadData() {
        if (id != "") {
            Request.get("datasource/" + id, {}, function (e) {
                mini.getbyName("id").setEnabled(false);
                if (e.success) {
                    new mini.Form('#data-form').setData(e.data);
                } else {
                    showTips(e.message, "danger");
                }
            });
        }
    }

    function save() {
        var api = "datasource/" + id;
        var func = id == "" ? Request.post : Request.put;
        var form = new mini.Form("#data-form");
        form.validate();
        if (form.isValid() == false) return;
        //提交数据
        var data = form.getData();
        var box = mini.loading("提交中...", "");
        func(api, data, function (e) {
            mini.hideMessageBox(box);
            if (e.success) {
                if (id == '') {
                    //新增
                    if (window.history.pushState)
                        window.history.pushState(0, "", '?id=' + e.data);
                    id = e.data;
                    showTips("创建成功!");
                } else {
                    //update
                    showTips("修改成功!");
                }
            } else {
                showTips(e.message, "danger");
            }
        });
    }
</script>