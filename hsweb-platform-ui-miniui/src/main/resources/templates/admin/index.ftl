<#import "../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
    <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon"/>
<@global.importMiniui/>
<@global.importFontIcon/>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }.font-2x {
             font-size: 16px;;
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
    <div showHeader="false" region="west" width="180" height="100%" maxWidth="250" minWidth="100">
        <div id="leftTree" class="mini-tree" url="<@global.api "userModule" />"
             expandOnLoad="true" resultAsTree="false" ajaxOptions="{type:'GET'}" ondrawnode="drawnode" showTreeIcon="false"
             onnodeclick="nodeselect" idField="u_id" parentField="p_id" textField="name" borderStyle="border:0">
        </div>
    </div>
    <div title="center" region="center" bodyStyle="overflow:hidden;">
        <!--默认标签页-->
        <div id="mainTabs" closeclick="oncloseclick" class="mini-tabs" activeIndex="0" style="width:100%;height:100%;">
            <div title="首页" name="first" style="text-align: center;width: 100%;margin: auto;">

            </div>
        </div>
    </div>
</div>
</body>
</html>
<script>
    mini.parse();
    var tabs = mini.get('mainTabs');
    function nodeselect(e) {
        if (e.node&& e.node.p_id!="-1") {
            window.history.pushState(0, 0, "#m=" + e.node.u_id);
            showTab(e.node);
            return;
        }
    }
    function drawnode(e) {
        e.nodeHtml = "<i class='" + (e.node.icon) + " font-2x'>&nbsp;" + e.node.name + "</i> &nbsp;";
    }
    function showTab(node) {
        var id = "tab$" + node.u_id;
        var tab = tabs.getTab(id);
        if (!tab) {
            tab = {};
            tab.name = id;
            tab.title = node.name;
            tab.showCloseButton = true;
            tab.url = '../' + node.uri;
            tabs.addTab(tab);
        }
        tabs.activeTab(tab);
    }
</script>