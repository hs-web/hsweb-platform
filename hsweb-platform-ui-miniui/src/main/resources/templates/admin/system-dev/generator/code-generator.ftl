<#import "../../../global.ftl" as global />
<#import "../../../authorize.ftl" as authorize />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui />
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

        .excel-cell-selected {
            background: rgb(223, 232, 246);

        }

        .CodeMirror {
            border: 1px solid #D2D6D7;
            font-size: 16px;
            width: 70%;
            margin: auto;
            height: 600px;
        }
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div showHeader="false" region="west" width="150" maxWidth="300" minWidth="100">
        <div id="leftTree" style="height: 100%;" class="mini-tree"
             expandOnLoad="false" resultAsTree="true" ajaxOptions="{type:'GET'}" showTreeIcon="true" iconField="icon"
             onnodeselect="nodeselect" idField="id" parentField="parentId" textField="name" borderStyle="border:0">
        </div>
    </div>
    <div title="center" region="center" bodyStyle="overflow-x: hidden;">
        <div class="mini-toolbar" style="width: 100%;">
            <table id="searchForm" style="width:100%;">
                <tr>
                    <td style="width:100%;">
                        <a class="mini-button" iconCls="icon-add" plain="true" onclick="createTemplate()">新建配置</a>
                        <a class="mini-button" iconCls="icon-edit" plain="true" onclick="editTemplate()">编辑配置</a>
                        <a class="mini-button" iconCls="icon-remove" plain="true" onclick="removeTemplate()">删除模板</a>
                        <a class="mini-button" iconCls="icon-save" plain="true" onclick="saveTempate()">保存配置(ctrl+s)</a>
                        <a class="mini-button" iconCls="icon-download" plain="true" onclick="download()">下载配置</a>
                        <a class="mini-button" iconCls="icon-upload" plain="true" onclick="importConfig()">导入配置</a>
                        <span class="separator"></span>
                        <a class="mini-button" iconCls="icon-control-play-blue" plain="true" onclick="generator()">生成代码(F9)</a>
                        <span class="separator"></span>
                        <a class="mini-button" iconCls="icon-reload" plain="true" onclick="tableMetaGrid.setData([])">重置</a>
                    </td>
                </tr>
            </table>
        </div>
        <div class="mini-fit" style="overflow-x: hidden;">
            <div id="vars" class="mini-datagrid" style="width:40%;height:40%;float: left;margin: auto"
                 allowCellEdit="true" allowCellSelect="true"
                 sortField="id" ajaxOptions="{type:'GET'}" idField="id" showPager="false"
                 contextMenu="#gridMenu">
                <div property="columns">
                    <div field="name" width="100" align="center" headerAlign="center">变量名
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="value" width="100" align="center" headerAlign="center">变量值
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="comment" width="50" align="center" headerAlign="center">备注
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div name="action" width="50" renderer="rendererAction" align="center" headerAlign="center">操作</div>
                </div>
            </div>
            <div id="tableMeta" class="mini-datagrid" style="width:59%;height:40%;margin: auto"
                 allowRowSelect="true" enableHotTrack="false" editNextOnEnterKey="true"
                 allowCellEdit="true" allowCellSelect="true" cellEditAction="celldblclick"
                 showPager="false"
                 contextMenu="#tableMetaGridMenu">
                <div property="columns">
                </div>
            </div>
            <div id="result" style="display: none;height: 600px;width: 100%">
                <div class="mini-toolbar" style="width: 100%;">
                    <table style="width:100%;">
                        <tr>
                            <td style="width:100%;">
                                <a class="mini-button" iconCls="icon-download" plain="true" onclick="downloadCode()">下载代码</a>
                            </td>
                        </tr>
                    </table>
                </div>
                <div id="resultTree" style="height: 100%;width:28%;float: left" class="mini-tree"
                     expandOnLoad="false" resultAsTree="false" ajaxOptions="{type:'GET'}" showTreeIcon="true" iconField="icon"
                     onnodeselect="resultTreeNodeSelect" idField="absPath" parentField="parentPath" textField="fileName" borderStyle="border:0">
                </div>
                <textarea id="resultCode"></textarea>
            </div>
            <div id="logger">

            </div>
            <ul id="gridMenu" class="mini-contextmenu" onbeforeopen="onBeforeOpen">
                <li name="add" iconCls="icon-add" onclick="varsGrid.addRow({})">新增变量</li>
            </ul>
            <ul id="tableMetaGridMenu" class="mini-contextmenu" onbeforeopen="onBeforeOpen">
                <li name="add" iconCls="icon-add" onclick="tableMetaGrid.addRow({})">新增列</li>
                <li name="add" iconCls="icon-find" onclick="selectFromDb()">从数据库中选择
                </li>
            </ul>
        </div>
    </div>
</div>
<div id="dbMetaWin" title="选择表" class="mini-window" style="width: 400px;" showFooter="true">
    <input class="mini-combobox" id="dbList" allowInput="true" style="width: 100%"><br>

    <div property="footer" style="text-align:right;padding: 5px 15px 5px 5px;">
        <input type='button' value="确定" onclick="chooseDbMeta()" style='vertical-align:middle;'/>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<@global.importPlugin "mousetrap/mousetrap.min.js"/>
<@global.importPlugin "miniui/copyExcel.js"/>

<script type="text/javascript">
    var templates = [];
    mini.parse();
    var tree = mini.get("leftTree");
    var varsGrid = mini.get('vars');
    var tableMetaGrid = mini.get('tableMeta');
    new CopyExcel(tableMetaGrid);
    var resultTree = mini.get('resultTree');
    var nowEditNode;
    var dbMeta;
    function editTemplate() {
        var selected = tree.getSelectedNode();
        var node = getRootSelectNode(selected);
        if (node) {
            openWindow("admin/system-dev/generator/template.html", "编辑模板", "80%", "80%", function (e) {
                if (e && e != 'close' && e != 'cancel') {
                    tree.updateNode(node, e);
                    var data = tree.getData();
                    tree.loadData(data);
                    //  tree.expandNode(node);
                    tree.selectNode(node);
                }
            }, function () {
                var iframe = this.getIFrameEl();
                var win = iframe.contentWindow;
                win.setData(node);
            });
        }
    }
    var nowEditorCode;
    function selectFromDb() {
        mini.get('dbMetaWin').show();
    }
    function resultTreeNodeSelect(e) {
        saveCode();
        if (e.node.code) {
            if (e.node.fileName.endWith(".xml"))
                initCode("text/xml", "");
            else if (e.node.fileName.endWith(".html"))
                initCode("text/html", "");
            else if (e.node.fileName.endWith(".js"))
                initCode("text/javascript", "");
            else {
                initCode("text/x-java", "");
            }
            editor.setValue(e.node.code);
            nowEditorCode = e.node;
        } else if (e.node.type == 'template') {
            editor.setValue("");
            nowEditorCode = e.node;
        } else {
            nowEditorCode = null;
        }
    }
    var editor;
    function saveCode() {
        if (nowEditorCode) {
            nowEditorCode.code = editor.getValue();
        }
    }

    function under2can() {
        var data = tableMetaGrid.getData();
        $(data).each(function () {

        });
    }
    Mousetrap.bind('ctrl+s', function (e) {
        saveTempate();
        return false;
    });
    Mousetrap.bind('f9', function (e) {
        generator();
        return false;
    });
    function initCode(mode, data) {
        var option = {
            lineNumbers: true,
            matchBrackets: true,
            lineWrapping: true,
            foldGutter: true,
            gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"],
            mode: mode
        };
        if (editor) {
            $('.CodeMirror').remove();
        }
        editor = CodeMirror.fromTextArea(document.getElementById("resultCode"), option);

    }

    function generator() {
        var data = {};
        data.fields = getCleanData(tableMetaGrid);
        data.vars = getCleanData(varsGrid);
        var template = getRootSelectNode();
        if (!template) {
            showTips("请选中一个模板")
            return;
        }
        $("#logger").hide();
        $("#result").hide();
        template = mini.clone(template);
        cleanTreeData(template);
        data.template = template;
        var box = mini.loading("生成中...", "请稍候");
        Request.post("generator", data, function (e) {
            mini.hideMessageBox(box);
            if (e.success) {
                $("#result").show();
                var data = [];
                e.data.fileName = e.data.name + "(生成结果)";
                data.push(e.data);
                var list = [];
                initAbsPath(data[0], data[0].children, function (e) {
                    var e2 = mini.clone(e);
                    delete e2.children;
                    list.push(e2);
                });
                //
                var oldData = mini.clone(resultTree.getData());
                if (oldData && oldData.length > 0) {
                    mini.confirm("是否合并已经生成的代码？", "确定？",
                            function (action) {
                                if (action == "ok") {
                                    var oldlist = [];
                                    initAbsPath(oldData[0], oldData[0].children, function (e) {
                                        var e2 = mini.clone(e);
                                        delete e2.children;
                                        oldlist.push(e2);
                                    });
                                    //合并数据
                                    var oldMap = {};
                                    $(oldlist).each(function () {
                                        oldMap[this.absPath] = this;
                                    });
                                    $(list).each(function () {
                                        oldMap[this.absPath] = this;
                                    });
                                    var newData = [];
                                    for (var f in oldMap) {
                                        newData.push(oldMap[f]);
                                    }
                                    resultTree.loadList(newData);
                                    resultTree.expandAll();
                                    initCode("text/x-java", "");
                                } else {
                                    resultTree.loadList(list);
                                    resultTree.expandAll();
                                    initCode("text/x-java", "");
                                }
                            }
                    );
                } else {
                    resultTree.loadList(list);
                    resultTree.expandAll();
                    initCode("text/x-java", "");
                }
            } else {
                $("#logger").show();
                $("#logger").text(e.message.replace("\n", "<br/>"));
            }
        })
    }
    function onBeforeOpen(e) {

    }
    function rendererAction(e) {
        var html = createActionButton("向上移动", "moveUp(varsGrid," + e.record._id + ")", 'icon-arrow-up');
        html += createActionButton("向下移动", "moveDown(varsGrid," + e.record._id + ")", 'icon-arrow-down');
        html += createActionButton("删除", "removeRow(varsGrid," + e.record._id + ")", 'icon-remove');
        return html;
    }
    function nodeselect(e) {
        if (nowEditNode) {
            //save
            nowEditNode.vars = getCleanData(varsGrid);
        }
        nowEditNode = getRootSelectNode(e.node);
        initTableMetaGrid();
    }

    function initTableMetaGrid() {
        if (nowEditNode) {
            if (nowEditNode.vars) {
                varsGrid.setData(nowEditNode.vars);
            }
            var columns = mini.clone(nowEditNode.config);
            if (columns) {
                var columns_new = [];
                var i = 0;
                $(columns).each(function () {
                    var obj = this;
                    if (this.renderer) {
                        var scriptId = "renderer_" + (i++);
                        var scriptText = "window." + scriptId + "=function(e){" +
                                "var row=e.record;" +
                                this.renderer +
                                "}";
                        eval(scriptText);
                        this.renderer = "window." + scriptId;
                    }
                    obj["headerAlign"] = "center";
                    obj["align"] = "center";
                    obj.editor = {type: "textbox"};
                    if (this.properties) {
                        var properties = mini.decode(this.properties);
                        for (var p in properties) {
                            obj[p] = properties[p];
                        }
                    }
                    columns_new.push(obj);
                });
                columns_new.push({
                    name: "action", headerAlign: "center", "align": "center", header: "操作", renderer: function (e) {
                        var html = createActionButton("向上移动", "moveUp(tableMetaGrid," + e.record._id + ")", 'icon-arrow-up');
                        html += createActionButton("向下移动", "moveDown(tableMetaGrid," + e.record._id + ")", 'icon-arrow-down');
                        html += createActionButton("删除", "removeRow(tableMetaGrid," + e.record._id + ")", 'icon-remove');
                        return html;
                    }
                });
                tableMetaGrid.set({
                    columns: columns_new
                });
            }
        }
    }

    function getRootSelectNode(node) {
        if (!node)
            node = tree.getSelectedNode();
        if (node) {
            if (node.id == 'parent')return node;
            var parent = tree.getParentNode(node);
            if (!parent)return node;
            return getRootSelectNode(parent);
        }
    }
    function createTemplate() {
        openWindow("admin/system-dev/generator/template.html", "创建模板", "80%", "80%", function (e) {
            if (e && e != 'close' && e != 'cancel') {
                var data = tree.getData();
                if (!data || data.length == 0) {
                    data = [];
                }
                data.push(e);
                tree.loadData(data);
            }
        });
    }
    loadData();
    function chooseDbMeta() {
        var tName = mini.get("dbList").getValue();
        if (tName) {
            var meta = dbMeta[tName];
            if (meta) {
                var fields = [];
                $(meta.fields).each(function () {
                    var data = mini.clone(this);
                    if (data.name == 'u_id') {
                        fields.push({column: data.name, property: "id", comment: data.comment, dataType: data.dataType});
                    } else
                        fields.push({column: data.name, comment: data.comment, dataType: data.dataType});
                });
                tableMetaGrid.setData(fields);
                var varData = varsGrid.getData();
                $(varData).each(function () {
                    if (this.name == 'tableName') {
                        this.value = tName;
                        varsGrid.updateRow(this, this);
                    }
                });
            }
        }
        mini.get('dbMetaWin').hide();
    }
    function loadData() {
        Request.get("database/tables", function (e) {
            if (e) {
                dbMeta = [];
                var comboboxData = [];
                $(e).each(function () {
                    dbMeta[this.name] = this;
                    comboboxData.push({id: this.name, text: this.name + (this.comment ? "(" + this.comment + ")" : "")});
                });
                mini.get("dbList").setData(comboboxData);
            }
        });
        Request.get("user-profile/code-generator", function (e) {
            if (e.success) {
                var data = mini.decode(e.data.content);
                tree.loadData(data)
                tree.selectNode(data[0]);
            } else {
                if (e.code == 404) {
                    Request.get("ui/resources/json/demo.g.json", function (e) {
                        console.log(e);
                        tree.loadData([e])
                        tree.selectNode(e);
                    })
                }
                else
                    mini.alert(e.message);
            }
        });
    }

    function download() {
        var node = getRootSelectNode();
        if (node) {
            var data = mini.clone(node);
            cleanTreeData(data);
            downloadText(mini.encode(data), data.name + ".g.json");
        }
    }

    function importConfig() {
        openFileUploader("json", "上传模板", function (e) {
            $(e).each(function () {
                var fileId = this.id;
                Request.get("file/download/" + fileId, function (e) {
                    if (e) {
                        var data = tree.getData();
                        if (!data || data.length == 0) {
                            data = [];
                        }
                        data.push(e);
                        tree.loadData(data);
                    } else {
                        alert("上传失败");
                    }
                });
            });
        });
    }

    function saveTempate() {
        var data = mini.clone(tree.getData());
        $(data).each(function () {
            cleanTreeData(this);
        })
        Request.patch("user-profile/code-generator", data, function (e) {
            if (e.success) {
                showTips("保存成功");
            } else {
                mini.alert(e.message);
            }
        });
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

    function initAbsPath(parent, children, each) {
        if (!parent.absPath)parent.absPath = "/";
        if (children)
            $(children).each(function () {
                this.parentPath = parent.absPath;
                if (this.parentPath == "/")
                    this.absPath = "/" + this.fileName;
                else
                    this.absPath = parent.absPath + "/" + this.fileName;
                each(this);
                initAbsPath(this, this.children, each);
            });
    }

    function downloadCode() {
        var data = resultTree.getList();
        data = mini.clone(data);
        if (data && data.length > 0) {
            var list = [];
            $(data).each(function () {
                if (this.type == 'template') {
                    if (!this.code)this.code = "";
                    if (this.absPath.indexOf("/") == 0) {
                        this.absPath = this.absPath.substring(1, this.absPath.length);
                    }
                    list.push({name: this.absPath, text: this.code});
                }
            });
            downloadZip(list, getRootSelectNode().name + ".zip");
        }
    }

    function removeTemplate() {
        mini.confirm("确定删除选中的模板？删除后无法恢复!", "确定？",
                function (action) {
                    if (action == "ok") {
                        tree.removeNode(getRootSelectNode());
                    }
                }
        );
    }
</script>