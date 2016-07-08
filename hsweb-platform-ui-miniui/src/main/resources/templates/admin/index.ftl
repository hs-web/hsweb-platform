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
        }

        .font-2x {
            font-size: 16px;;
        }
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div class="header" region="north" height="60" showSplit="false" showHeader="false">
        <h1 style="margin:0;padding:15px;cursor:default;font-family:微软雅黑,黑体,宋体;color: black;">
            <a href="http://github.com/hs-web">http://github.com/hs-web</a>
        </h1>

        <div style="position:absolute;top:10px;right:10px;">
            <a class="mini-button" iconCls="icon-cross" onclick="exit()" plain="true">退出</a>
        </div>
    </div>
    <div title="south" region="south" showSplit="false" showHeader="false" height="30">
        <div style="line-height:28px;text-align:center;cursor:default;">
            你好,&nbsp;${(user.name)!'游客'}&nbsp;${.now?string("yyyy年MM月dd日 E")} 当前在线人数:<span class="online-total">-</span>人
        </div>
    </div>
    <div showHeader="true" title="导航" region="west" width="180" height="100%" maxWidth="250" minWidth="100">
        <div id="leftTree" class="mini-tree" url="<@global.api "userModule" />"
             expandOnLoad="true" resultAsTree="false" ajaxOptions="{type:'GET'}" showTreeIcon="true" iconField="icon"
             onnodeclick="nodeselect" idField="id" parentField="parentId" textField="name" borderStyle="border:0">
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
<@global.importRequest/>
<@global.importWebsocket/>
<@global.importPlugin "socket/Socket.js"/>
</html>
<script>
    mini.parse();
    var tabs = mini.get('mainTabs');
    var tree = mini.get("leftTree");

    if (window.location.hash) {
        var node = tree.getNodesByValue(window.location.hash.substring(1));
        if (node) {
            tree.selectNode(node[0]);
            showTab(node[0]);
        }
    }
    function nodeselect(e) {
        if (e.node && e.node.id != "-1" && $.trim(e.node.uri) != "") {
            if (window.history.pushState)
                window.history.pushState(0, 0, "#" + e.node.id);
            showTab(e.node);
            return;
        }
    }
    function drawnode(e) {
        e.nodeHtml = "<i class='" + (e.node.icon) + " font-2x'>&nbsp;" + e.node.name + "</i> &nbsp;";
    }
    function showTab(node) {
        var id = "tab$" + node.id;
        var tab = tabs.getTab(id);
        if (!tab) {
            tab = {};
            tab.name = id;
            tab.title = node.name;
            tab.showCloseButton = true;
            tab.url = Request.BASH_PATH + node.uri;
            tabs.addTab(tab);
        }
        if (!mini.get("layout1").isExpandRegion("west"))
            mini.get("layout1").collapseRegion("west");
        tabs.activeTab(tab);
    }
    function exit() {
        mini.confirm("确定退出系统?", "确定？",
                function (action) {
                    if (action == "ok") {
                        Request.post("exit", {}, function (e) {
                            window.location.href = "/admin/index.html";
                        });
                    }
                }
        );
    }
    Request.get("online/total", {}, function (e) {
        if (e.success) {
            $(".online-total").text(e.data);
        }
    });
    Socket.open(function (socket) {
        if (socket) {
            //订阅在线人数推送
            socket.sub("online", {type: "total"}, "onlineUserTotal");
            socket.on("onlineUserTotal", function (e) {
                $(".online-total").text(e);
            });
        } else {
            showTips("你的浏览器不支持websocket,部分功能可能无法正常使用!", "danger");
        }
    });
</script>