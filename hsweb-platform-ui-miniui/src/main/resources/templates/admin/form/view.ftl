<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui "bootstrap"/>
<@global.importPlugin "ueditor/themes/default/css/ueditor.min.css"/>
    <script type="text/javascript" charset="utf-8">
        window.UEDITOR_HOME_URL = location.protocol + '//' + document.domain + (location.port ? (":" + location.port) : "") + "/ui/plugins/ueditor/";
    </script>
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
</body>
</html>
<@global.importPlugin  "ueditor/ueditor.parse.js"/>
<@global.importRequest />
<script type="text/javascript">
    var id = "${param.id!''}";
    var name="${param.name!''}";
    function init(){
        var type="view",val=id;
       if(id==""){
           val=name;
           type="html";
       }
        Request.get("form/"+val+"/"+type,{},function(data){
            if(data.success){
                $(document.body).html(data.data);
                uParse('#preview',{
                    rootPath : '/ui/plugins/ueditor',
                    chartContainerHeight:500
                })
                mini.parse();
            }
        });
    }
    init();
</script>