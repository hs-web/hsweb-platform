<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importUeditorParser/>
</head>
<body>
<div id="formContent">
${html!''}
</div>
<div style="margin: 30px auto auto;width: 150px">
    <a class="mini-button" iconCls="icon-save" plain="true" onclick="save()">保存</a>
    &nbsp;&nbsp;
    <a class="mini-button" iconCls="icon-undo" plain="true" onclick="window.closeWindow(id)">返回</a>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var formName = "${name}";
    var id = "${id!''}";
    uParse('#formContent', {
        rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
        chartContainerHeight: 500
    });
    mini.parse();
    load();
    function load() {
        if (id != "") {
            var api = "dyn-form/" + formName + "/" + id;
            Request.get(api, {}, function (e) {
                if (e.success) {
                    var form = new mini.Form("#formContent");
                    form.setData(e.data);
                } else {
                    mini.alert(e.message);
                }
            });
        }
        $(".mini-radiobuttonlist td").css("border", "0px");
        $(".mini-checkboxlist td").css("border", "0px");
        $(".mini-radiobuttonlist").css("display ", "inline");
    }

    function save() {
        var api = "dyn-form/" + formName + "/" + id;
        var func = id == "" ? Request.post : Request.put;
        var form = new mini.Form("#formContent");
        form.validate();
        if (form.isValid() == false) return;
        //提交数据
        var data = form.getData();
        var box = mini.loading("提交中...", "");
        func(api, data, function (e) {
            mini.hideMessageBox(box);
            if (e.success) {
                if (id == "") {
                    id = e.data;
                    if (window.history.pushState)
                    window.history.pushState(0, "", "?id=" + id);
                }
                showTips("保存成功!");
            } else if (e.code == 400) {
                try {
                    var validMessage = mini.decode(e.message);
                    $(validMessage).each(function(i,e){
                        mini.get(e.field).setIsValid(false);
                        mini.get(e.field).setErrorText(e.message);
                    });
                    mini.get(validMessage[0].field).focus();
                    showTips("保存失败:" + validMessage[0].message + "....", "danger")
                } catch (e) {
                    mini.alert("保存失败,请联系管理员!");
                }
            } else {
                showTips("保存失败!", "danger")
            }
        });
    }
</script>