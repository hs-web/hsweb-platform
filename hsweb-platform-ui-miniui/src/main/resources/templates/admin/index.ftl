<#import "../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
    <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
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
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div class="header" region="north" height="60" showSplit="false" showHeader="false">
        <h1>hsweb-platform</h1>
    </div>
    <div title="south" region="south" showSplit="false" showHeader="false" height="30">
        <div style="line-height:28px;text-align:center;cursor:default">github/hs-web</div>
    </div>
    <div showHeader="false" region="west" width="180" maxWidth="250" minWidth="100">
        <div id="leftTree" class="mini-outlookmenu" url="<@global.api "/userModule" />" onitemselect="onItemSelect" idField="u_id" parentField="p_id" textField="name" borderStyle="border:0">
        </div>
    </div>
    <div title="center" region="center" bodyStyle="overflow:hidden;">
        <iframe id="mainframe" src="form/designer.html" frameborder="0" name="main" style="width:100%;height:100%;" border="0"></iframe>
    </div>
</div>
</body>
</html>
<script>
    mini.parse();
</script>