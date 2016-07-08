<#import "../../../global.ftl" as global />
<#import "../../../authorize.ftl" as authorize />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui />
<@global.importUeditorParser/>
<@global.importPlugin
'codemirror/lib/codemirror.css'
,'codemirror/addon/fold/foldgutter.css'
,'codemirror/addon/hint/show-hint.css'
,'codemirror/addon/dialog/dialog.css'
,'codemirror/theme/eclipse.css'
,'codemirror/lib/codemirror.js'
,'codemirror/addon/search/searchcursor.js'
,'codemirror/addon/search/search.js'
,'codemirror/addon/dialog/dialog.js'
,'codemirror/addon/edit/matchbrackets.js'
,'codemirror/addon/edit/closebrackets.js'
,'codemirror/addon/wrap/hardwrap.js'
,'codemirror/addon/fold/foldcode.js'
,'codemirror/addon/hint/show-hint.js'
,'codemirror/addon/hint/javascript-hint.js'
,'codemirror/addon/hint/css-hint.js'
,'codemirror/addon/hint/anyword-hint.js'
,'codemirror/mode/javascript/javascript.js'
,'codemirror/mode/groovy/groovy.js'
,'codemirror/mode/htmlmixed/htmlmixed.js'
,'codemirror/mode/xml/xml.js'
,'codemirror/mode/css/css.js'
,'codemirror/mode/clike/clike.js'
,'codemirror/keymap/sublime.js'
/>
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
            width: 80%;
            margin: auto;
            height: 600px;
            min-width: 600px;
        }
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div showHeader="false" region="west" width="150" maxWidth="300" minWidth="100">
        <div id="leftTree" style="height: 100%;" class="mini-tree"
             expandOnLoad="true" resultAsTree="false" ajaxOptions="{type:'GET'}" showTreeIcon="true" iconField="icon"
             contextMenu="#treeMenu" onnodedblclick="renameFile()" allowDrag="true" allowLeafDropIn="true" allowDrop="true"
             onbeforedrop="beforedrop"
             onnodeclick="nodeselect" idField="id" parentField="parentId" textField="name" borderStyle="border:0">
        </div>
        <ul id="treeMenu" class="mini-contextmenu" onbeforeopen="onBeforeOpen">
            <li class="treeNode copy" iconCls="icon-page-white-copy" onclick="copy()">复制(ctrl+c)</li>
            <li class="treeNode cut" iconCls="icon-cut" onclick="cut()">粘贴(ctrl+v)</li>
            <li class="treeNode createDir" iconCls="icon-folder" onclick="mkdir()">新建目录</li>
            <li class="treeNode createFile" iconCls="icon-application" onclick="newFile()">新建模板</li>
            <li class="treeNode rename" iconCls="icon-edit" onclick="renameFile()">重命名(ctrl+r)</li>
            <li class="treeNode deleteNode" iconCls="icon-remove" onclick="deleteNode()">删除(ctrl+d)</li>
        </ul>
    </div>
    <div title="center" region="center">
        <div id="formContainer">
            <table data-sort="sortDisabled" style="width:80%;min-width:600px;margin: 10px auto auto;">
                <tbody>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">模板名称</td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="name" id="name" class="mini-textbox" required="true"/>
                    </td>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">文件名</td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="fileName" id="fileName" class="mini-textbox" required="true"/>
                    </td>
                </tr>
                <tr>
                    <td colspan="4" align="center">
                        <a class="mini-button" iconCls="icon-save" plain="true" onclick="saveNode()">保存</a>
                        <span style="width: 0.8em"></span>
                        <a class="mini-button" iconCls="icon-ok" plain="true" onclick="submit()">完成编辑</a>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
        <div>
            <textarea id="code" style="display: none"></textarea>

            <div class="configGrid">
                <div style="width: 80%;min-width: 600px;margin: auto">
                    <a class="mini-button" iconCls="icon-add" plain="true" onclick="datagrid.addRow({})">表结构配置</a>
                </div>
                <div id="datagrid" class="mini-datagrid" style="width: 80%;height:500px;margin: auto;min-width: 600px"
                     idField="id" allowCellEdit="true" allowCellSelect="true" showPager="false">
                    <div property="columns">
                        <div type="indexcolumn" align="center" headerAlign="center">#</div>
                        <div field="header" width="60" align="center" headerAlign="center">列名
                            <input property="editor" class="mini-textbox"/>
                        </div>
                        <div field="field" width="60" align="center" headerAlign="center">字段
                            <input property="editor" class="mini-textbox"/>
                        </div>
                        <div field="width" width="50" align="center" headerAlign="center">宽度
                            <input property="editor" class="mini-textbox" vtype="int"/>
                        </div>
                        <div field="renderer" width="50" align="center" headerAlign="center">渲染事件
                            <input property="editor" onbuttonclick="editJson" class="mini-buttonedit"/>
                        </div>
                        <div field="properties" width="100" align="center" headerAlign="center">其他属性(JSON)
                            <input property="editor" onbuttonclick="editJson" class="mini-buttonedit"/>
                        </div>
                        <div name="action" width="80" renderer="rendererQueryTableAction" align="center" headerAlign="center">操作</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
<@global.importRequest/>
<@global.importPlugin "mousetrap/mousetrap.min.js"/>
<script type="text/javascript">
    var clipboard;
    mini.parse();
    Mousetrap.bind('ctrl+c', function (e) {
        copy();
        return false;
    });
    Mousetrap.bind('ctrl+r', function (e) {
        renameFile();
        return false;
    });
    Mousetrap.bind('ctrl+v', function (e) {
        cut();
        return false;
    });
    Mousetrap.bind(['del',"ctrl+d"], function (e) {
        deleteNode();
        return false;
    });
    var tree = mini.get('leftTree');
    var defaultData = [{id: "parent", name: "新建模板", icon: "icon-application", type: "dir"}];
    tree.loadList(defaultData);
    uParse('#formContainer', {
        rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
        chartContainerHeight: 500
    });
    var datagrid = mini.get('datagrid');
    bindCellBeginButtonEdit(datagrid);
    function rendererQueryTableAction(e) {
        var html = createActionButton("向上移动", "moveUp(datagrid," + e.record._id + ")", 'icon-arrow-up');
        html += createActionButton("向上移动", "moveDown(datagrid," + e.record._id + ")", 'icon-arrow-down');
        html += createActionButton("向上移动", "removeRow(datagrid," + e.record._id + ")", 'icon-remove');
        return html;
    }
    var nowEditNode;
    function onBeforeOpen(e) {
        var menu = e.sender;
        var node = tree.getSelectedNode();
        $('.treeNode').show();
        if (!clipboard) {
            $('.cut').hide();
        }
        if (node) {
            if (node.type != 'dir') {
                $('.createDir').hide();
                $('.createFile').hide();
            }
            if (node.id == 'parent') {
                $('.deleteNode').hide();
                $('.copy').hide();
            }
        }
        return;
    }
    function editJson(e) {
        var tmp = e.sender.value;
        if (!tmp) {
            tmp = "";
        }
        openScriptEditor("text/javascript", tmp, function (script) {
            e.sender.setValue(script);
            e.sender.setText(script);
        });
    }
    function copy() {
        var node = tree.getSelectedNode();
        if (node) {
            node = mini.clone(node);
            cleanTreeData(node);
            clipboard = node;
        }
    }
    function cut() {
        var node = tree.getSelectedNode();
        if (clipboard && node) {
            var target=mini.clone(clipboard);
            tree.addNode(target,0, node);
            tree.beginEdit(target);
            tree.expandNode(target);
        }
    }
    function beforedrop(e) {
        var dragNode = e.dragNode;
        var dropNode = e.dropNode;
        var dragAction = e.dragAction;
        if (dropNode.type != 'dir'&&dragAction=='add') {
            e.cancel = true;
        }
    }
    function mkdir() {
        var node = tree.getSelectedNode();
        if (node && node.type == 'dir') {
            tree.addNode({name: "新建文件夹", type: "dir"}, "add", node);
        }
    }
    function saveNode() {
        if (nowEditNode) {
            var form = new mini.Form("#formContainer");
            var data = form.getData();
            if (editor)
                data.template = editor.getValue();
            tree.updateNode(nowEditNode, data);
        }
    }
    function nodeselect(e) {
        saveNode();
        var node = e.node;
        if (node.id != 'parent') {
            $('.CodeMirror').show();
            $('.configGrid').hide();
            nowEditNode = node;
            mini.get("name").setValue(nowEditNode.name);
            if (!nowEditNode.fileName)nowEditNode.fileName = nowEditNode.name;
            mini.get("fileName").setValue(nowEditNode.fileName);
            if (nowEditNode.type != 'dir') {
                if (nowEditNode.fileName.endWith(".java")) {
                    init("text/x-java", "");
                } else if (nowEditNode.fileName.endWith(".xml")) {
                    init("text/xml", "");
                } else if (nowEditNode.fileName.endWith(".js")) {
                    init("text/javascript", "");
                } else if (nowEditNode.fileName.endWith(".html")) {
                    init("text/html", "");
                } else {
                    init("text/x-java", "");
                }
                if (nowEditNode.template)
                    editor.setValue(nowEditNode.template);
            } else {
                $(".CodeMirror").remove();
                editor = null;
            }
        } else {
            $('.configGrid').show();
            $('.CodeMirror').hide();
        }
    }
    function renameFile() {
        var node = tree.getSelectedNode();
        if (node) {
            tree.beginEdit(node);
        }
    }
    function newFile() {
        var node = tree.getSelectedNode();
        if (node && node.type == 'dir') {
            tree.addNode({name: "新建模板", type: "template", icon: "icon-application"}, "add", node);
        }
    }
    function deleteNode() {
        var node = tree.getSelectedNode();
        if (node && node.id != 'parent') {
            tree.removeNode(node);
        }
    }
    var editor;
    init("text/x-java", "");
    $('.CodeMirror').hide();
    function init(mode, data) {
        var option = {
            lineNumbers: true,
            matchBrackets: true,
            lineWrapping: true,
            extraKeys: {
                "Alt-/": 'autocomplete'
            },
            foldGutter: true,
            gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"],
            mode: mode
        };
        if (editor) {
            $('.CodeMirror').remove();
        }
        editor = CodeMirror.fromTextArea(document.getElementById("code"), option);
    }

    window.setData = function (data) {
        data = mini.clone(data);
        tree.loadData([data]);
        datagrid.setData(data.config);
    }

    function submit() {
        saveNode();
        var data = mini.clone(tree.getData())[0];
        var gridData = getCleanData(datagrid);
        data.config = gridData;
        cleanTreeData(data);
        closeWindow(data);
    }

    function cleanTreeData(data) {
        delete data._id;
        delete data._uid;
        delete data._pid;
        delete data._level;
        delete data.parentId;
        delete data.expanded;
        if (data.children) {
            $(data.children).each(function () {
                cleanTreeData(this)
            });
        }
    }
</script>