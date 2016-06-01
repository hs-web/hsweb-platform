<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importUeditorParser/>
    <style type="text/css">
        .form-table{
            border: 0px;
        }
    </style>
</head>
<body>
<div id="formContent">
</div>
<div style="margin: 30px auto auto;width: 150px">
    <a class="mini-button" iconCls="icon-save" plain="true" onclick="save()">保存</a>
    &nbsp;&nbsp;
    <a class="mini-button" iconCls="icon-undo" plain="true" onclick="window.closeWindow(id)">返回</a>
</div>
</body>
</html>
<@global.importRequest/>
<@global.importPlugin  "form-designer/form.parser.js"/>
<script type="text/javascript">
    var formName = "${name}";
    var id = "${id!''}";
    var formParser = new FormParser({name: formName, target: "#formContent"});
    formParser.onload = function () {
        mini.parse();
        uParse('#formContent', {
            rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
            chartContainerHeight: 5000
        });
        $(".mini-radiobuttonlist td").css("border", "0px");
        $(".mini-checkboxlist td").css("border", "0px");
        $(".mini-radiobuttonlist").css("display ", "inline");
    };
    load();
    function load() {
        if (id != "") {
            var api = "dyn-form/" + formName + "/" + id;
            Request.get(api, {}, function (e) {
                if (e.success) {
                    formParser.load(e.data);
                } else {
                    mini.alert(e.message);
                }
            });
        } else {
            formParser.load();
        }
    }

    function save() {
        var api = "dyn-form/" + formName + "/" + id;
        var func = id == "" ? Request.post : Request.put;
        //提交数据
        var data = formParser.getData();
        if (!data)return;
        for (var f in data) {
            if (typeof (data[f]) == 'object') {
                data[f] = mini.getbyName(f).getFormValue();
            }
        }
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
                    $(validMessage).each(function (i, e) {
                        mini.getbyName(e.field).setIsValid(false);
                        mini.getbyName(e.field).setErrorText(e.message);
                    });
                    var field = mini.getbyName(validMessage[0].field);
                    if (field)
                        field.focus();
                    showTips("保存失败:" + validMessage[0].message + "....", "danger")
                } catch (e) {
                    if (window.console) {
                        console.log(e);
                    }
                    mini.alert("保存失败,请联系管理员!");
                }
            } else {
                showTips("保存失败!", "danger")
            }
        });
    }
</script>