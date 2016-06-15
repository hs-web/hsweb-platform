<#import "../../global.ftl" as global />
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
        .asLabel .mini-textboxlist-border
        {
            border:0;background:none;cursor:default;
        }
        .asLabel .mini-buttonedit-button,
        .asLabel .mini-textboxlist-close
        {
            display:none;
        }
        .asLabel .mini-textboxlist-item
        {
            padding-right:8px;
        }
    </style>
</head>
<body>
<div id="formContent">
</div>
<div style="margin: 30px auto auto;width: 100px">
    <a class="mini-button" iconCls="icon-undo" plain="true" onclick="window.closeWindow(id)">返回</a>
</div>
</body>
</html>
<@global.importRequest/>
<@global.importPlugin  "form-designer/form.parser.js"/>
<script type="text/javascript">
    var formName = "${name!''}";
    var version="#{version!'0'}";
    var id = "${id!''}";
    var formParser = new FormParser({name: formName, target: "#formContent",version:version,readOnly:true});
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
        }else{
            formParser.load();
        }
    }

</script>