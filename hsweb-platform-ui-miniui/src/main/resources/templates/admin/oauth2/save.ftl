<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importUeditorParser/>
<@global.importFontIcon/>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 90%;
        }
    </style>
</head>
<body>
<div id="data-form" style="margin-top:20px">
    <table data-sort="sortDisabled" style="width:80%;margin:auto;">
        <tbody>
        <tr class="firstRow">
            <th style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4"><span id="title" style="font-size: 24px;">
            ${param.id???string('编辑客户端','新建客户端')}
            </span>
            </th>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">名称</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left" align="left">
                <input style="width:100%" required="true" name="name" id="name" class="mini-textbox">
            </td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">备注</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left" align="left">
                <input style="width:100%" r name="comment" id="comment" class="mini-textarea">
            </td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">绑定用户</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left">
                <div id="userId" class="mini-autocomplete" name="userId" required="true" ajaxType="GET"
                     style="width:100%;" popupWidth="400" textField="username"
                     valueField="id" searchField="terms[0].value"
                     url="<@global.api "user?terms[0].column=username&terms[0].termType=like" />">
                    <div property="columns">
                        <div header="用户名" field="username" width="30"></div>
                        <div header="姓名" field="name"></div>
                    </div>
                </div>
            </td>
        </tr>
        </tbody>
    </table>
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
            Request.get("oauth2/client/" + id, {}, function (e) {
                if (e.success) {
                    if (e.data.userId) {
                        Request.get("user/" + e.data.userId, function (e) {
                            if (e.success) {
                                mini.get("userId").setText(e.data.username);
                            }else{
                                mini.get("userId").setValue(e.data.userId);
                            }
                        });
                    }
                    new mini.Form('#data-form').setData(e.data);
                }
            });
        }
    }

    function save() {
        var api = "oauth2/client/" + id;
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
                    $('#title').html("编辑客户端");
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
