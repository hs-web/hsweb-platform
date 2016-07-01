<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<#import "../../authorize.ftl" as authorize/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui />
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 100%;
        }

        .CodeMirror {
            border: 1px solid #D2D6D7;
            font-size: 16px;
            width: 99%;
            margin: auto;
            height: 500px;
        }

        .split {
            margin-left: 0.5em;
        }
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div class="header" region="north" height="35" showSplit="false" showHeader="false">
        <div class="mini-toolbar">
            <a class="mini-button" iconCls="icon-add" onclick="newWin()" plain="true">新建SQL窗口</a>
            <a class="mini-button" iconCls="icon-reload" onclick="initData()" plain="true">刷新</a>
        </div>
    </div>
    <div showHeader="false" region="west" width="200" maxWidth="300" minWidth="100">
        <div id="leftTree" style="height: 100%;" class="mini-tree"
             expandOnLoad="0" resultAsTree="true" ajaxOptions="{type:'GET'}"
             iconField="icon" nodedblclick="nodedblclick" showTreeIcon="true"
             idField="name" textField="text" borderStyle="border:0"
             contextMenu="#treeMenu">
        </div>

        <ul id="treeMenu" class="mini-contextmenu" onbeforeopen="onBeforeOpen">
            <li id="createMenu" name="add" iconCls="icon-add" onclick="createTable">新建表</li>
            <li id="editMenu" name="edit" iconCls="icon-edit" onclick="editTable">编辑表</li>
            <li id="findMenu" name="find" iconCls="icon-find" onclick="viewData">浏览数据</li>
        </ul>
    </div>
    <div title="center" region="center">
        <!--默认标签页-->
        <div id="mainTabs" class="mini-tabs" activeIndex="0" style="width:100%;height:100%;">
            <div title="SQL窗口" showCloseButton="true" name="first" url="manager.html" style="text-align: center;width: 100%;margin: auto;">
            </div>
        </div>
    </div>

</div>
<div id="win" title="表结构" class="mini-window" style="width: 800px;height: 600px;">
    <div class="mini-toolbar">
        <input id="tableName"  class="mini-textbox"  enabled="false" />
        <input id="tableComment" class="mini-textbox" emptyText="备注" />
        <a class="mini-button" iconCls="icon-add" onclick="fieldGrid.addRow({properties:{not_null:false}})" plain="true">添加字段</a>
    </div>
    <div id="tableMetaTabs" onactivechanged="initMetaSql" class="mini-tabs" activeIndex="0" style="width:100%;height:90%;">
        <div title="表结构" showCloseButton="false" name="first" style="text-align: center;width: 100%;margin: auto;">
            <div id="datagrid" allowCellEdit="true" allowCellSelect="true" showPager="false" class="mini-datagrid" style="width:100%;height:100%;">
            </div>
        </div>
        <div title="执行变更" name="sql" showCloseButton="false" url="manager.html" style="text-align: center;width: 100%;margin: auto;" onload="loadTableMetaSql">

        </div>
    </div>

</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var nowEditorId = "${param.editId!''}";
    var nowEditorNode;
    var editor;
    mini.parse();
    var tree = mini.get("leftTree");
    var fieldWindow = mini.get('win');
    var tables;
    var tabs = mini.get('mainTabs');
    var fieldGrid = mini.get('datagrid');
    var tableMetaTabsObj = mini.get('tableMetaTabs');
    var tableMetaSqlWindow;
    var editor;
    fieldGrid.set({
        columns: [
            {
                header: "名称", field: "name", align: "center", headerAlign: "center",
                editor: {
                    type: "textbox"
                }
            },
            {
                header: "类型", field: "dataType", align: "center", headerAlign: "center",
                editor: {
                    type: "textbox"
                }
            },
            {
                header: "不能为空",width:50, field: "properties.not_null", renderer: "trueOrFalse", align: "center", headerAlign: "center",
                editor: {
                    type: "combobox", data: [{id: true, text: "是"}, {id: false, text: "否"}]
                }
            },
            {
                header: "注释", field: "comment", align: "center", headerAlign: "center",
                editor: {
                    type: "textbox"
                }
            },
            {
                header: "操作", align: "center", headerAlign: "center",
                renderer: function (e) {
                    return "<a href='javascript:removeRow(fieldGrid," + e.record._id + ")'>删除</a>";
                }
            }
        ]
    });
    var nowMetaMod = "create";
    var oldSelectTable;
    initData();
    function loadTableMetaSql(e) {
        tableMetaSqlWindow = e.iframe.contentWindow;
        setMetaSql();
    }
    function initMetaSql(e) {
        if (e.name == 'sql' && tableMetaSqlWindow) {
            setMetaSql();
        }
    }
    function setMetaSql() {
        var tableMeta = {};
        var tableInfo = tree.getSelectedNode();
        tableMeta.name = tableInfo.name;
        tableMeta.comment =  mini.get("tableComment").getValue();
        var fieldList = getCleanData(fieldGrid);
        var fields = [];
        $(fieldList).each(function () {
            fields.push({
                "name": this.name, "dataType": this.dataType, "comment": this.comment, properties: {
                    "not-null": this.properties['not_null']
                    , "old-name": this.old_name
                }
            });
        });
        tableMeta.fields = fields;
        Request.post("database/sql/" + nowMetaMod, tableMeta, function (e) {
            if (e.success) {
                tableMetaSqlWindow.setSql(e.data);
            }
        });
    }
    function editTable() {
        nowMetaMod = "alter";
        var node = tree.getSelectedNode();
        fieldWindow.show();
        $(node.fields).each(function () {
            this.old_name = this.name;
        })
        mini.get("tableName").setValue(node.name);
        mini.get("tableComment").setValue(node.comment);

        fieldGrid.setData(node.fields);
        tableMetaTabsObj.activeTab(0);
    }
    function newWin() {
        var tab = {title: "新建SQL窗口", url: "manager.html", showCloseButton: true};
        tabs.addTab(tab);
        tabs.activeTab(tab);
    }
    function initData() {
        var old = tree.getSelectedNode();
        var isExpandedNode = old && tree.isExpandedNode(old);
        Request.get("database/tables", function (e) {
            if (e) {
                tables = e;
                var data = mini.clone(tables);
                $(data).each(function () {
                    this.icon = "icon-application-view-columns";
                    this.text = this.name + ( this.comment ? "(" + this.comment + ")" : "");
                    $(this.fields).each(function () {
                        this.icon = "icon-table-column";
                        this.text = this.name + ( this.comment ? "(" + this.comment + ")" : "");
                        this.properties['not_null'] = this.properties['not-null']
                    });
                    this.children = this.fields;
                });
                tree.setData([{icon: "icon-folder-database", text: "默认数据库", children: data}]);
                if (old) {
                    var newNode = tree.findNodes(function (node) {
                        if (node.name == old.name) return true;
                    });
                    tree.selectNode(newNode[0]);
                    if (isExpandedNode) {
                        tree.expandNode(newNode[0]);
                    }
                }
                // tree.setShowCheckBox(true);
                // tree.setShowFolderCheckBox(false);
            }
        });
    }
    function nodedblclick(e) {
        var node = e.node;

    }

    function viewData() {
        var node = tree.getSelectedNode();
        var tab = {
            title: node.text, url: "view-data.html", showCloseButton: true, onload: function (e) {
                var win = e.iframe.contentWindow;
                $(e.iframe).on("load", function () {
                    win.initData(node);
                });
                win.initData(node);
            }
        };
        tabs.addTab(tab);
        tabs.activeTab(tab);
    }

    function onBeforeOpen(e) {
        var menu = e.sender;
        var node = tree.getSelectedNode();
        $("#createMenu").hide();
        $("#editMenu").hide();
        $("#findMenu").hide();
        if (!node || !node.children) {
            e.cancel = true;
            return;
        }
        if (node._pid == -1) {
            $("#createMenu").show();
        } else {
            $("#editMenu").show();
            $("#findMenu").show();
        }
    }

    function trueOrFalse(e) {
        return (e.value + "") == 'true' ? "<span class='red'>是</span>" : "否";
    }

</script>