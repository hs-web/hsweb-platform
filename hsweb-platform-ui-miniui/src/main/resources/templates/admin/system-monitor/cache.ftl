<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="cn">
<head>
    <meta charset="UTF-8">
    <title></title>
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
<div class="mini-splitter" style="width:100%;height:100%;">
    <div size="40%" style="padding:2px;min-width: 150px;">
    <#--<div id="leftTree" style="height: 100%;" class="mini-tree" url="<@global.api "monitor/caches" />"-->
    <#--expandOnLoad="true" resultAsTree="true" ajaxOptions="{type:'GET'}"-->
    <#--ondrawnode="drawnode"-->
    <#--onnodeselect="nodeselect" idField="id" nodesField="caches" textField="name" borderStyle="border:0">-->
    <#--</div>-->
        <div id="leftTree" class="mini-treegrid" style="height: 100%;" class="mini-tree" url="<@global.api "monitor/caches" />"
             expandOnLoad="true" resultAsTree="true" ajaxOptions="{type:'GET'}" treeColumn="name"
             onnodeselect="nodeselect" idField="id" nodesField="caches" textField="name">
            <div property="columns">
                <div type="indexcolumn"></div>
                <div name="name" field="name" width="150">缓存名称</div>
                <div field="size" width="50">数量</div>
                <div field="totalTimes" width="50" align="left">调用次数</div>
                <div field="hitTimes" width="50">命中次数</div>
                <div field="putTimes" width="50">更新次数</div>
            </div>
        </div>
    </div>
    <div size="80%" style="padding:2px;">
        <div id="datagrid" class="mini-datagrid" style="width:100%;height:100%;" ajaxOptions="{type:'GET',dataType:'json'}" idField="id"
             showPager="false">
            <div property="columns">
                <div type="indexcolumn"></div>
                <div field="name" width="120" align="center" headerAlign="center">name</div>
                <div name="action" width="50" renderer="rendererAction" align="center" headerAlign="center">操作</div>
            </div>
        </div>
    </div>
</div>
<div id="win1" class="mini-window" title="缓存值" style="width:800px;height:600px;"
     showMaxButton="true" showShadow="true"
     showToolbar="true" showFooter="true" showModal="false" allowResize="true" allowDrag="true">
    <textarea id="valueArea" style="width: 99%;height: 98%;border: 0px"></textarea>
</div>
</body>
</html>
<@global.importRequest/>
<@global.resources "js/json-formater.js"/>
<script type="text/javascript">
    mini.parse();
    var grid = mini.get('datagrid');
    var selectNode, selectParentNode;
    var valueWindow = mini.get("win1");
    function drawnode(e) {
        var node = e.node;
        var html = node.name;
        if (typeof(node.size) != "undefined") {
            html += "(<span title='缓存数量'>" + node.size + "</span>," + node.totalTimes + "," + node.putTimes + "," + node.hitTimes + ")";
        }
        e.nodeHtml = html;
    }
    function rendererAction(e) {
        var html = "";
        html += createActionButton("查看", "showValue('" + (e.record.name) + "')", "icon-find");
        html += createActionButton("删除", "remove('" + (e.record.name) + "')", "icon-remove");
        return html;
    }
    function showValue(cacheName) {
        Request.get("monitor/cache/" + selectParentNode.name + "/" + selectNode.name + "/" + cacheName + "/", function (e) {
            if (e.success) {
                if(typeof(e.data)=="object"){
                    e.data=JSONFormat(mini.encode(e.data));
                }
                $("#valueArea").val(e.data);
                valueWindow.showAtPos("center", "middle");
            } else {
                showTips(e.message, "danger");
            }
        });
    }
    function remove(cacheName) {
        Request['delete']("monitor/cache/" + selectParentNode.name + "/" + selectNode.name + "/" + cacheName + "/", function (e) {
            if (e.success) {
                loadGrid();
            } else {
                showTips(e.message, "danger");
            }
        });
    }
    function loadGrid() {
        Request.get("monitor/cache/" + selectParentNode.name + "/" + selectNode.name + "/", function (response) {
            if (response.success) {
                var data = response.data;
                var list = [];
                $(data).each(function () {
                    list.push({name: this})
                });
                grid.setData(list);
            }
        });
    }
    function nodeselect(e) {
        if (e.isLeaf) {
            selectNode = e.node;
            selectParentNode = e.sender.getParentNode(e.node);
            loadGrid();
        }
    }
</script>