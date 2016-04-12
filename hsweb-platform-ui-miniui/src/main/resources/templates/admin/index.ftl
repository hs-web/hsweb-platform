<#import "../resources.ftl" as resources />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
    <@resources.miniui/>
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
        <h1 style="margin:0;padding:15px;cursor:default;font-family:'Trebuchet MS',Arial,sans-serif;">hsweb</h1>
    </div>
    <div title="south" region="south" showSplit="false" showHeader="false" height="30">
        <div style="line-height:28px;text-align:center;cursor:default">github/hs-web</div>
    </div>
    <div showHeader="false" region="west" width="180" maxWidth="250" minWidth="100">
        <!--OutlookMenu-->
        <div id="leftTree" class="mini-outlookmenu" url="" onitemselect="onItemSelect" idField="id" parentField="pid" textField="text" borderStyle="border:0" >
        </div>

    </div>
    <div title="center" region="center" bodyStyle="overflow:hidden;">
        <iframe id="mainframe" frameborder="0" name="main" style="width:100%;height:100%;" border="0"></iframe>
    </div>
</body>
</html>
<script>
    mini.parse();
</script>