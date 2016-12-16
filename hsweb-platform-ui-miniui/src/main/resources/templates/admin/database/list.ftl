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
            数据源: <input id="datasource" class="mini-combobox" onvaluechanged="changeDatasource" textField="name" showNullItem="true"
                        nullItemText="默认数据源" emptyText="默认数据源" url="<@global.api "datasource?paging=false&includes=id,name"/>"/>
            <a class="mini-button" iconCls="icon-add" onclick="newWin()" plain="true">新建SQL窗口</a>
            <a class="mini-button" iconCls="icon-reload" onclick="initData(true)" plain="true">刷新</a>
        </div>
    </div>
    <div showHeader="false" region="west" width="200" maxWidth="300" minWidth="100">
        <div class="mini-toolbar" style="border-top: 0px;border-right: 0px;">
            搜索:<input class="mini-textbox" id="treeFilterKey" onenter="searchTree()"/>
        </div>
        <div class="mini-fit">
            <div id="leftTree" style="height: 100%;" class="mini-tree"
                 expandOnLoad="0" resultAsTree="true" ajaxOptions="{type:'GET'}"
                 iconField="icon" nodedblclick="nodedblclick" showTreeIcon="true"
                 idField="name" textField="text" borderStyle="border:0"
                 contextMenu="#treeMenu">
            </div>
        </div>
        <ul id="treeMenu" class="mini-contextmenu" onbeforeopen="onBeforeOpen">
            <li id="createMenu" name="add" iconCls="icon-add" onclick="createTable">新建表</li>
            <li id="editMenu" name="edit" iconCls="icon-edit" onclick="editTable">编辑表</li>
        <#--<li id="findMenu" name="find" iconCls="icon-find" onclick="viewData">浏览数据</li>-->
        </ul>
    </div>
    <div title="center" region="center">
        <!--默认标签页-->
        <div id="mainTabs" class="mini-tabs" activeIndex="0" style="width:100%;height:100%;">
        </div>
    </div>

</div>
<div id="win" title="表结构" class="mini-window" style="width: 800px;height: 600px;">
    <div class="mini-toolbar">
        <input id="tableName" class="mini-textbox" enabled="false"/>
        <input id="tableComment" class="mini-textbox" emptyText="备注"/>
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
    var datasource = "";
    var tree = mini.get("leftTree");
    var fieldWindow = mini.get('win');
    var tables;
    var tabs = mini.get('mainTabs');
    var fieldGrid = mini.get('datagrid');
    var tableMetaTabsObj = mini.get('tableMetaTabs');
    var tableMetaSqlWindow;
    var editor;
    var sqlWindows = [];

    function searchTree() {
        var key = mini.get("treeFilterKey").getValue();
        if (key == "") {
            tree.clearFilter();
        } else {
            key = key.toLowerCase();
            tree.filter(function (node) {
                if (node.text && node.text.toLowerCase().indexOf(key.toLowerCase()) != -1) {
                    return true;
                }
            });
        }
    }
    function changeDatasource(e) {
        if (e.selected)
            datasource = e.selected.id;
        else datasource = "";
        initData();
        $(sqlWindows).each(function () {
            this.setDataSource(datasource);
        });
    }
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
                header: "不能为空", dataType: "boolean", width: 50, field: "notNull", renderer: "trueOrFalse", align: "center", headerAlign: "center",
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
        tableMeta.name = tableInfo.name ? tableInfo.name : mini.get("tableName").getValue();
        if (!tableMeta.name || tableMeta.name == '') {
            showTips("表名不能为空");
            return;
        }
        tableMeta.comment = mini.get("tableComment").getValue();
        var fieldList = getCleanData(fieldGrid);
        var fields = [];
        $(fieldList).each(function () {
            fields.push({
                "name": this.name, "dataType": this.dataType,
                notNull: this.notNull, primaryKey: this.primaryKey,
                "comment": this.comment,
                properties: {
                    "old-name": this.old_name
                }
            });
        });
        tableMeta.columns = fields;
        Request.post("database/sql/" + nowMetaMod + "/" + datasource, tableMeta, function (e) {
            if (e.success) {
                tableMetaSqlWindow.setSql(e.data);
                tableMetaSqlWindow.setDataSource(datasource);
            }
        });
    }
    function editTable() {
        nowMetaMod = "alter";
        var node = tree.getSelectedNode();
        fieldWindow.show();
        $(node.columns).each(function () {
            this.old_name = this.name;
        });
        mini.get("tableName").setValue(node.name);
        mini.get("tableName").setEnabled(false);
        mini.get("tableComment").setValue(node.comment);
        fieldGrid.setData(node.columns);
        tableMetaTabsObj.activeTab(0);
    }

    function createTable() {
        nowMetaMod = "create";
        mini.get("tableName").setValue("t_new_table");
        mini.get("tableName").setEnabled(true);
        mini.get("tableComment").setValue("新建表");
        fieldGrid.setData([{name: "u_id", comment: "主键", notNull: true, primaryKey: true, dataType: "varchar(32)"}]);
        tableMetaTabsObj.activeTab(0);
        mini.get('win').show();
    }
    newWin();
    function newWin() {
        var tab = {
            title: "新建SQL窗口", url: "manager.html", showCloseButton: true, onload: function (e) {
                var iframe = e.iframe;
                var win = iframe.contentWindow;

                function init() {
                    win.setDataSource(datasource);
                }

                init();
                $(iframe).on("load", function () {
                    init();
                });
                sqlWindows.push(win);
            }
        };
        tabs.addTab(tab);
        tabs.activeTab(tab);
    }
    window.getTableMetas = function () {
        return mini.clone(tree.getData());
    }
    function initData(r) {
        var old = tree.getSelectedNode();
        var isExpandedNode = old && tree.isExpandedNode(old);
        var reload = r == true;
        Request.get("database/tables/" + datasource, {reload: reload}, function (e) {
            if (e) {
                tables = e;
                var data = mini.clone(tables);
                $(data).each(function () {
                    this.icon = "icon-application-view-columns";
                    this.text = this.name + ( this.comment ? "(" + this.comment + ")" : "");
                    $(this.columns).each(function () {
                        this.icon = "icon-table-column";
                        this.text = this.name + ( this.comment ? "(" + this.comment + ")" : "");
                        this.properties['not_null'] = this.properties['not-null']
                    });
                    this.children = this.columns;
                });
                var text = mini.get("datasource").getText();
                if (text == "") text = "默认数据源";
                tree.setData([{icon: "icon-folder-database", text: text, children: data}]);
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