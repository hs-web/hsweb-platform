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

        .font-2x {
            font-size: 16px;;
        }
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div class="header" region="north" height="30" showSplit="false" showHeader="false">
        <div class="mini-toolbar">
            <a class="mini-button" iconCls="icon-add" onclick="newModule()" plain="true">新增权限</a>
            <a class="mini-button" iconCls="icon-save" onclick="saveAll()" plain="true">保存全部</a>
            <a class="mini-button" iconCls="icon-reload" onclick="mini.get('leftTree').reload()" plain="true">刷新</a>

            <a class="mini-button" iconCls="icon-help" onclick="showHelp()" plain="true">查看帮助</a>
        </div>
    </div>
    <div showHeader="false" region="west" width="250" maxWidth="500" minWidth="200">
        <div id="leftTree" class="mini-tree" url="<@global.api "module?paging=false&sortField=sort_index" />"
             expandOnLoad="true" resultAsTree="false" ajaxOptions="{type:'GET'}" ondrawnode="drawnode" showTreeIcon="false"
             onnodeselect="nodeselect" idField="u_id" parentField="p_id" textField="name" borderStyle="border:0"
             allowDrag="true" allowLeafDropIn="true" allowDrop="true" contextMenu="#treeMenu" ondrop="ondrop"
                >
        </div>

        <ul id="treeMenu" class="mini-contextmenu" onbeforeopen="onBeforeOpen">
            <li iconCls="icon-add" onclick="newModule()">新增权限</li>
            <li iconCls="icon-save" onclick="saveAll()">保存全部</li>
        </ul>
    </div>
    <div title="center" region="center" bodyStyle="overflow:hidden;">
        <br/>

        <div id="formContainer">
            <table data-sort="sortDisabled" style="width:80%;min-width:600px;margin: auto">
                <tbody>
                <tr class="firstRow">
                    <th style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4">
                        <h1 align="center" id="tableTitle">新建权限</h1>
                    </th>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">权限ID</td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="u_id" id="u_id" class="mini-textbox" required="true"/>
                    </td>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">权限名称</td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="name" id="name" class="mini-textbox" required="true"/>
                    </td>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">路径映射</td>
                    <td width="129" valign="middle" align="left" colspan="3">
                        <input style="width:100%" name="uri" id="uri" class="mini-textbox">
                    </td>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right"><a href="http://fontawesome.io/icons/" target="_blank">图标</a></td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="icon" id="icon" class="mini-textbox"/>
                    </td>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">父级权限ID</td>
                    <td width="129" valign="middle" align="left"><input enabled="flase" name="p_id" id="p_id" class="mini-textbox"/>&nbsp;*拖拽左侧菜单调整结构</td>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">备注<br></td>
                    <td valign="middle" rowspan="1" colspan="1" width="50" align="left"><input style="width:100%" name="remark" id="remark" class="mini-textarea"/></td>
                    <td rowspan="1" valign="middle" align="right" width="50" style="word-break: break-all;">排序</td>
                    <td rowspan="1" valign="middle" align="left" width="128"><input name="sort_index" enabled="flase" id="sort_index" class="mini-textbox"/>&nbsp;*拖拽左侧菜单即可排序</td>
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
        <div style="margin: auto;width:300px;">
            <br/>

            <h3 align="center">可选操作</h3>
            <a class="mini-button" iconCls="icon-add" onclick="mini.get('m_option_table').addRow({},0)" plain="true"></a>
            <a class="mini-button" iconCls="icon-remove" plain="true" onclick="mini.get('m_option_table').removeRow(mini.get('m_option_table').getSelected())"></a>

            <div id="m_option_table" class="mini-datagrid"
                 style="margin: auto;width:400px;height:150px;border: 0px;"
                 showPager="false" allowCellEdit="true" allowCellSelect="true" allowAlternating="true" editNextOnEnterKey="true">
                <div property="columns">
                    <div field="id" width="30" align="center" headerAlign="center">ID
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="text" width="30" align="center" headerAlign="center">备注
                        <input property="editor" class="mini-textarea"/>
                    </div>
                    <div field="checked" width="30" align="center" headerAlign="center">默认
                        <input property="editor" class="mini-combobox" data="[{'id':true},{'id':false}]" textField="id"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    uParse('#formContainer', {
        rootPath: '<@global.basePath />ui/plugins/ueditor',
        chartContainerHeight: 500
    });
    var nowEditorId = "${param.editId}";
    var nowEditorNode;
    mini.parse();
    var grid = mini.get("datagrid");
    var tree = mini.get("leftTree");
    if (nowEditorId != "") {
        tree.selectNode({u_id: nowEditorId});
    }
    function newModule() {
        var node = tree.getSelectedNode();
        if (!node) {
            var newNode = {u_id: "", name: "新建权限", p_id: "-1", sort_index: 0};
            tree.addNode(newNode, "add");
            tree.selectNode(newNode);
        } else {
            var childSize = tree.getChildNodes(node).length;
            var newNode = {u_id: "", name: "新建权限", p_id: node.u_id, sort_index: node.sort_index + "0" + (childSize + 1)};
            tree.addNode(newNode, "add", node);
            tree.selectNode(newNode);
        }
    }
    function drawnode(e) {
        e.nodeHtml = "<i class='" + (e.node.icon) + " font-2x'>&nbsp;" + e.node.name + "(" + e.node.u_id + ")" + "</i> &nbsp;";
    }
    function nodeselect(e) {
        if (!e.node) {
            window.history.pushState(0, 0, "?editId=");
            return;
        }
        nowEditorId = e.node.u_id;
        nowEditorNode = e.node;
        new mini.Form("#formContainer").setData(e.node);
        mini.get("m_option_table").setData(mini.decode(e.node.m_option));
        $("#tableTitle").html(e.node.name);
        if (nowEditorId != "") {
            mini.get("u_id").setEnabled(false);
        } else {
            mini.get("u_id").setEnabled(true);
        }
        window.history.pushState(0, 0, "?editId=" + nowEditorId);
    }
    function save() {
        var form = new mini.Form("#formContainer");
        form.validate();
        if (!form.isValid())return;
        var m_option = mini.get("m_option_table").getData();
        var new_m_option = [];
        $(m_option).each(function (i, e) {
            new_m_option.push({id: e.id, text: e.text, checked: e.checked});
        });
        var data = form.getData();
        data.m_option = mini.encode(new_m_option);
        var func = nowEditorId == "" ? Request.post : Request.put;
        func("module/" + nowEditorId, data, function (e) {
            if (e.success) {
                if (nowEditorId == "")nowEditorId = e.data;
                mini.get("leftTree").updateNode(nowEditorNode, data);
                tree.selectNode(data);
                showTips("保存成功");
            } else {
                mini.alert(e.data);
            }
        });
    }
    function remove() {
        if (nowEditorId != "")
            mini.confirm("确定删除权限，删除后无法恢复？", "确定？",
                    function (action) {
                        if (action == "ok") {
                            Request.delete("module/" + nowEditorId, {}, function (e) {
                                if (e.success) {
                                    showTips("删除成功!");
                                    tree.removeNode(nowEditorNode);
                                }
                                else mini.alert(e.data);
                            });
                        }
                    }
            );
    }
    function saveAll() {
        var dataList = tree.getList();
        var valideSus = true;
        $(dataList).each(function (i, e) {
            if ("" == e.u_id) {
                valideSus = false;
                tree.selectNode(e);
                showTips("请先完成编辑!", "danger");
                return;
            }
        });
        if (valideSus)
            Request.put("module", dataList, function (e) {
                if (e.success) {
                    showTips("保存成功!");
                    tree.reload();
                } else {
                    mini.alert(e.data);
                }
            })
    }
    function showTips(msg, state) {
        mini.showTips({
            content: msg,
            state: state || 'success',
            x: 'center',
            y: 'top',
            timeout: 3000
        });
    }
    function onBeforeOpen(e) {
        var menu = e.sender;
        var node = tree.getSelectedNode();
        if (!node) {
            e.cancel = true;
            return;
        }
        if (node && node.text == "Base") {
            e.cancel = true;
            //阻止浏览器默认右键菜单
            e.htmlEvent.preventDefault();
            return;
        }
    }
    function ondrop(e) {
        var dragNode = e.dragNode;
        var dropNode = e.dropNode;
        var dragAction = e.dragAction;
        var index = dragNode.sort_index;
        var pNode;
        if ("before" == dragAction || "after" == dragAction) {
            dropNode.sort_index = dragNode.sort_index;
            pNode = tree.getParentNode(dragNode);
        }
        if ("add" == dragAction) {
            pNode = dropNode;
        }
        reSortModule(pNode);
        tree.selectNode(dragNode);
    }
    function reSortModule(node) {
        var childNodes = tree.getChildNodes(node);
        $(childNodes).each(function (i, e) {
            var index = parseInt(node.sort_index);
            if (isNaN(index)) e.sort_index=i+1;
            else
            e.sort_index = index + "0" + (i + 1);
            reSortModule(e);
        });
    }
    function showHelp() {
        mini.alert("左侧菜单支持右键，支持拖拽排序。<br/>编辑后，注意点击保存!");
    }
</script>