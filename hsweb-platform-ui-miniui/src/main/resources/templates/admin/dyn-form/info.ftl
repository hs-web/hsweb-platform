<#import "../../global.ftl" as global />
<#import "../../authorize.ftl" as authorize />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importUeditorParser/>
    <style>
        .asLabel .mini-textbox-border,
        .asLabel .mini-textbox-input,
        .asLabel .mini-buttonedit-border,
        .asLabel .mini-buttonedit-input,
        .asLabel .mini-textboxlist-border {
            border: 0;
            background: none;
            cursor: default;
        }

        .asLabel .mini-buttonedit-button,
        .asLabel .mini-textboxlist-close {
            display: none;
        }

        .asLabel .mini-textboxlist-item {
            padding-right: 8px;
        }
    </style>
</head>
<body>
<div id="formContent">
</div>
<div style="margin: 30px auto auto;width: 250px;text-align: center">
<#if authorize.module(name!param.name!'',"U")>
<#--<a class="mini-button" iconCls="icon-edit" plain="true" onclick="doEdit()">编辑</a>-->
</#if>
    <a class="mini-button backButton" iconCls="icon-undo" plain="true" onclick="window.closeWindow(id)">返回</a>
</div>
</body>
</html>
<@global.importRequest/>
<@global.importPlugin  "localstore/store.min.js"
,"form-designer/form.parser.fast.js"
,"mousetrap/mousetrap.min.js"/>
<script type="text/javascript">
    var formName = "${name!param.name!''}";
    var id = "${id!param.id!''}";
    var version = "${version!'0'}";
    var readOnly = true;
    var formParser = new FormParser({name: formName, version: version, target: "#formContent", readOnly: readOnly});
    function doEdit() {
        window.location.href = Request.BASH_PATH + "admin/dyn-form/save.html?name=" + formName + "&id=" + id;
    }
    window.onInit = function (data, formData, scriptText) {
        if (scriptText) {
            var script = "(function(){return function(data,formData){" + scriptText + "}})()";
            eval(script)(data, formData);
        }
    }
    var eventTmp = {};
    var loaded = false;
    formParser.on = function (type, func) {
        eventTmp[type] = func;
        if (type == "load" && loaded) func();
    }

    formParser.onload = function () {
        mini.parse();
        uParse('#formContent', {
            rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
            chartContainerHeight: 5000
        });
        $(".mini-radiobuttonlist td").css("border", "0px");
        $(".mini-checkboxlist td").css("border", "0px");
        $(".mini-radiobuttonlist").css("display ", "inline");
        loaded = true;
        if (eventTmp["load"])
            eventTmp["load"]();
        if (window.resizeWindow) {
            window.resizeWindow(document.body.scrollHeight + 50);
        }
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
</script>