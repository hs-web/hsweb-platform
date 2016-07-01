<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui />
<@global.importUeditorParser/>
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
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div class="header" region="north" height="35" showSplit="false" showHeader="false">
        <div class="mini-toolbar">
            <a class="mini-button" iconCls="icon-add" onclick="newConfig()" plain="true">新增配置</a>
            <a class="mini-button" iconCls="icon-add" onclick="newClassified()" plain="true">新建分类</a>
            <a class="mini-button" iconCls="icon-reload" onclick="initData()" plain="true">刷新</a>
        </div>
    </div>
    <div showHeader="false" region="west" width="150" maxWidth="250" minWidth="100">
        <div id="leftTree" style="height: 100%;" class="mini-tree"
        <#--url="<@global.api "classified/byType/config?paging=false&sortField=sortIndex&includes=id,name,parentId" />"-->
             onbeforeload="onBeforeTreeLoad"
             expandOnLoad="true" resultAsTree="false" ajaxOptions="{type:'GET'}"
             iconField="icon" onnodeselect="nodeselect" showTreeIcon="true"
             idField="id" parentField="parentId" textField="name" borderStyle="border:0"
             contextMenu="#treeMenu">
        </div>

        <ul id="treeMenu" class="mini-contextmenu" onbeforeopen="onBeforeOpen">
            <li iconCls="icon-add" onclick="newConfig()">新增配置</li>
        </ul>
    </div>
    <div title="center" region="center" bodyStyle="overflow:hidden;">
        <br/>

        <div id="formContainer">
            <table data-sort="sortDisabled" style="width:80%;min-width:600px;margin: auto">
                <tbody>
                <tr class="firstRow">
                    <th style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4">
                        <h1 align="center" id="tableTitle">新建配置</h1>
                    </th>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">ID</td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="id" id="id" class="mini-textbox" required="true"/>
                    </td>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">备注<br></td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="remark" id="remark" class="mini-textbox"/>
                    </td>
                </tr>
                <tr>
                    <td colspan="4" align="center">
                        <a class="mini-button" iconCls="icon-save" plain="true" onclick="save">保存</a>
                        &nbsp; &nbsp;
                        <a class="mini-button" iconCls="icon-remove" plain="true" onclick="remove()">删除</a>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
        <div style="margin: auto;width:80%;">
            <br/>

            <h3 align="center">配置内容</h3>
            <a class="mini-button" iconCls="icon-add" onclick="grid.addRow({},0)" plain="true"></a>
            <a class="mini-button" iconCls="icon-remove" plain="true" onclick="grid.removeRow(grid.getSelected())"></a>

            <div id="contentGrid" class="mini-datagrid"
                 style="margin: auto;width:100%;height:300px;border: 0px;"
                 showPager="false" allowCellEdit="true"
                 allowCellSelect="true" allowAlternating="true" editNextOnEnterKey="true">
                <div property="columns">
                    <div field="key" width="30" align="center" headerAlign="center">KEY
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="value" width="50" align="center" headerAlign="center">VALUE
                        <input property="editor" onbuttonclick="onbuttonedit" class="mini-buttonedit"/>
                    </div>
                    <div field="comment" width="30" align="center" headerAlign="center">备注
                        <input property="editor" class="mini-textarea"/>
                    </div>
                    <div width="30" renderer="actionRender" align="center" headerAlign="center">操作</div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var configType = [
//        {id: "properties", text: "properties"},
        {id: "json", text: "json"}
    ];
    uParse('#formContainer', {
        rootPath: '<@global.basePath />ui/plugins/ueditor',
        chartContainerHeight: 500
    });
    var nowEditorId = "${param.editId!''}";
    var nowEditorNode;
    mini.parse();
    var tree = mini.get("leftTree");
    var grid = mini.get("contentGrid");
    grid.on("cellbeginedit", function (e) {
        if (e.field == "value") {
            e.editor.setValue(e.value);
            e.editor.setText(e.value);
        }
    });
    initData();
    function actionRender(e) {
        var html = "";
        html += createActionButton("上移", "moveUp(grid," + e.record._id + ")", "icon-arrow-up");
        html += createActionButton("下移", "moveDown(grid," + e.record._id + ")", "icon-arrow-down");
        html += createActionButton("删除", "removeRow(grid," + e.record._id + ")", "icon-remove");
        return html;
    }
    function initData() {
        var TreeData = [];
        Request.createQuery("classified/byType/config").select(["id", "parentId", "name", "icon"]).noPaging()
                .exec(function (e) {
                    if (e) {
                        for (var i = 0; i < e.length; i++) {
                            e[i]._type = "classified";
                            TreeData.push(e[i]);
                        }
                        Request.createQuery("config").select(["id", "remark", "classifiedId"]).noPaging()
                                .exec(function (data) {
                                    if (data) {
                                        for (var i = 0; i < data.length; i++) {
                                            data[i]._type = "config";
                                            data[i].parentId = data[i]['classifiedId'];
                                            data[i].name = data[i].id + "(" + data[i].remark + ")";
                                            TreeData.push(data[i]);
                                        }
                                        tree.loadList(TreeData);
                                        if (nowEditorNode)
                                            tree.selectNode(nowEditorNode);
                                    }
                                });
                    }
                });
    }

    function remove() {
        var id = mini.get("id").getValue();
        if (id != "")
            mini.confirm("确定删除配置，删除后无法恢复？", "确定？",
                    function (action) {
                        if (action == "ok") {
                            Request['delete']("config/" + id, {}, function (e) {
                                if (e.success) {
                                    showTips("删除成功!");
                                    initData();
                                }
                                else mini.alert(e.message);
                            });
                        }
                    }
            );
    }

    function save() {
        var api = "config/" + nowEditorId;
        var fun = nowEditorId == "" ? Request.post : Request.put;
        var form = new mini.Form("#formContainer");
        form.validate();
        if (!form.isValid())return;
        var data = form.getData();
        var node = nowEditorNode;
        if (nowEditorNode._type == "classified") {
            data.classifiedId = nowEditorNode.id;
        } else {
            data.classifiedId = (node = tree.getParentNode(nowEditorNode)).id;
        }
        data.content = mini.encode(getConfigContent());
        var box = mini.loading("提交中...");
        fun(api, data, function (e) {
            mini.hideMessageBox(box);
            if (e.success) {
                showTips("保存成功");
                if (nowEditorId == "") {
                    nowEditorId = e.data;
                }
                initData();
            } else {
                showTips(e.message, "danger");
            }
        });
    }
    function onbuttonedit(e) {
        openScriptEditor("json", e.sender.value, function (script) {
            if (script == "close" || script == "cancel")return;
            e.sender.value = script;
        });
    }
    function nodeselect(e) {
        if (!e.node) {
            return;
        }
        nowEditorNode = e.node;
        if (e.node._type == "config") {
            nowEditorId = e.node.id;
            initConfig();
        }
    }
    function initConfig() {
        if (nowEditorId == "") {
            new mini.Form("#formContainer").setData([]);
            grid.setData([]);
            mini.get("id").setEnabled(true);
            return;
        }
        Request.get("config/" + nowEditorId, {}, function (e) {
            if (e.success) {
                mini.get("id").setEnabled(false);
                new mini.Form("#formContainer").setData(e.data);
                var content = mini.decode(e.data.content);
                grid.setData(content);
            }
        });
    }
    function newClassified() {
        var pid;
        var nodeTmp = nowEditorNode;
        if (!nowEditorNode)pid = "-1";
        else if (nowEditorNode._type != 'classified') {
            pid = ( nodeTmp = tree.getParentNode(nowEditorNode)).id;
        } else {
            pid = nowEditorNode.id;
        }
        mini.prompt("请输入分类名称", "请输入",
                function (action, value) {
                    if (action == "ok") {
                        if (value == "")return;
                        var data = {name: value, type: "config", parentId: pid};
                        Request.post("classified", data, function (e) {
                            if (e.success) {
                                initData();
                            } else {
                                mini.alert(e.message);
                            }
                        });
                    }
                });
    }
    function getConfigContent() {
        var content = grid.getData();
        var data = [];
        $(content).each(function (i, e) {
            data.push({key: e.key, value: e.value, comment: e.comment});
        });
        return data;
    }
    function newConfig() {
        var node = tree.getSelectedNode();
        if (!node) {
            showTips("请选中一个类别!", "danger");
            return;
        }
        var parent = nowEditorNode;
        if (nowEditorNode._type != 'classified') {
            parent = tree.getParentNode(nowEditorNode);
        }
        var newNode = {id: "", name: "新建配置", _type: "config"};
        tree.addNode(newNode, "add", parent);
        tree.selectNode(newNode);
        new mini.Form("#formContainer").setData({});
        mini.get("id").setEnabled(true);
        grid.setData([]);
    }
</script>