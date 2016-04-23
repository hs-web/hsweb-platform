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
        #preview{
            width:100%;
            height:100%;
            padding:0;
            margin:0;
        }
    </style>
</head>
<body>
<div id="preview"></div>
</body>
</html>
<@global.importPlugin  "ueditor/ueditor.parse.js"/>
<@global.importRequest />
<script type="text/javascript">
    window.UEDITOR_HOME_URL = location.protocol + '//' + document.domain + (location.port ? (":" + location.port) : "") + "/ui/plugins/ueditor/";
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
                $('#preview').html(data.data);
                uParse('#preview',{
                    rootPath : '/ui/plugins/ueditor',
                    chartContainerHeight:5000
                })
                mini.parse();
            }
        });
    }
    init();
</script>