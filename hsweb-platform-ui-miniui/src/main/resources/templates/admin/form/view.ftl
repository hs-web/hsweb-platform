<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui "bootstrap"/>
<@global.importPlugin "ueditor/themes/default/dialogbase.css"/>
    <style type="text/css">
        #preview {
            width: 100%;
            height: 100%;
            padding: 0;
            margin: 0;
        }
    </style>
</head>
<body>
<div id="preview"></div>
</body>
</html>
<@global.importPlugin  "ueditor/ueditor.parse.js"/>
<@global.importRequest />
<@global.importPlugin  "form-designer/form.parser.js"/>
<script type="text/javascript">
    window.UEDITOR_HOME_URL = location.protocol + '//' + document.domain + (location.port ? (":" + location.port) : "") + "/ui/plugins/ueditor/";
    var id = "${param.id!''}";
    var name = "${param.name!''}";
    var formParser = new FormParser({name: name, id: id, target: "#preview"});
    formParser.onload=function(){
        uParse('#preview', {
            rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
            chartContainerHeight: 5000
        });
    }
    function init() {
        formParser.load();
    }
    init();
</script>