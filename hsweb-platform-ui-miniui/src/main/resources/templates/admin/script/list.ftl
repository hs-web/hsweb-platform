<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<#import "../../authorize.ftl" as authorize/>
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
,'codemirror/addon/hint/anyword-hint.js'
,'codemirror/mode/javascript/javascript.js'
,'codemirror/mode/clike/clike.js'
,'codemirror/mode/groovy/groovy.js'
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
            width: 100%;
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
            <a class="mini-button" iconCls="icon-add" onclick="newScript()" plain="true">新增脚本</a>
            <a class="mini-button" iconCls="icon-add" onclick="newClassified()" plain="true">新建分类</a>
            <a class="mini-button" iconCls="icon-reload" onclick="initData()" plain="true">刷新</a>
        </div>
    </div>
    <div showHeader="false" region="west" width="150" maxWidth="250" minWidth="100">
        <div id="leftTree" style="height: 100%;" class="mini-tree"
             onbeforeload="onBeforeTreeLoad"
             expandOnLoad="true" resultAsTree="false" ajaxOptions="{type:'GET'}"
             iconField="icon" onnodeselect="nodeselect" showTreeIcon="true"
             idField="id" parentField="parentId" textField="name" borderStyle="border:0"
             contextMenu="#treeMenu">
        </div>
    </div>
    <div title="center" region="center">
        <br/>

        <div id="formContainer">
            <table data-sort="sortDisabled" style="width:90%;min-width:600px;margin: auto">
                <tbody>
                <tr class="firstRow">
                    <th style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4">
                        <h1 align="center" id="tableTitle">动态脚本</h1>
                    </th>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">名称</td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="name" id="name" class="mini-textbox" required="true"/>
                    </td>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">类型</td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="type" id="type" class="mini-combobox" required="true" data="scriptType"/>
                    </td>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">备注<br></td>
                    <td colspan="3" width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="remark" id="remark" class="mini-textbox"/>
                    </td>
                </tr>
                <tr>
                    <td colspan="4" align="center">
                        <a class="mini-button" iconCls="icon-save" plain="true" onclick="save">保存</a>
                        <span class="split"></span>
                    <#if authorize.module("script","compile")>
                        <a class="mini-button" iconCls="icon-page-white-cdr" plain="true" onclick="compile()">编译</a>
                    </#if>
                        <span class="split"></span>
                        <a class="mini-button" iconCls="icon-remove" plain="true" onclick="remove()">删除</a>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
        <div id="tableMetaTabs" class="mini-tabs" activeIndex="0" style="width:90%;height:90%;margin: auto">
            <div title="脚本" showCloseButton="false" name="first" style="text-align: center;width: 100%;margin: auto;">
                <textarea id="code"></textarea>
            </div>
            <div title="运行" name="exec" showCloseButton="false" style="text-align: center;width: 100%;margin: auto;">
                <a class="mini-button" iconCls="icon-application" plain="true" onclick="exec">运行</a>
                <input id="method" class="mini-combobox" style="width: 80px" value="GET" textField="id" data="[{id:'GET'},{id:'POST'},{id:'PUT'},{id:'DELETE'}]"/>
                <input id="paramBuilder" class="mini-textarea" style="width: 80%" emptyText="参数构建脚本(js)"/>
                <br>
                <br>

                <div id="result" style="width: 80%;height:300px;border: 1px solid #D2D6D7;margin: auto;font-size: 16px">

                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var scriptType = [
        {id: "groovy", text: "groovy"},
        {id: "java", text: "java"},
        {id: "javascript", text: "javascript"}
    ];
    uParse('#formContainer', {
        rootPath: '<@global.basePath />ui/plugins/ueditor',
        chartContainerHeight: 500
    });
    var nowEditorId = "${param.editId!''}";
    var nowEditorNode;
    var editor;
    mini.parse();
    var tree = mini.get("leftTree");
    initData();
    function compile() {
        if (nowEditorId != '')
            Request.get("script/compile/" + nowEditorId, function (e) {
                if (e.success) {
                    showTips("编译成功");
                } else {
                    showTips(e.message, "danger");
                }
            });
    }
    function initData() {
        var TreeData = [];
        Request.createQuery("classified/byType/script").select(["id", "parentId", "name", "icon"]).noPaging()
                .exec(function (e) {
                    if (e) {
                        for (var i = 0; i < e.length; i++) {
                            e[i]._type = "classified";
                            TreeData.push(e[i]);
                        }
                        Request.createQuery("script").select(["id", "name", "remark", "type", "classifiedId"]).noPaging()
                                .exec(function (data) {
                                    if (data) {
                                        for (var i = 0; i < data.length; i++) {
                                            data[i]._type = "script";
                                            data[i].parentId = data[i]['classifiedId'];
                                            data[i].name = data[i].name + "." + data[i].type;
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
        if (nowEditorId != "")
            mini.confirm("确定删除脚本，删除后无法恢复？", "确定？",
                    function (action) {
                        if (action == "ok") {
                            Request['delete']("script/" + nowEditorId, {}, function (e) {
                                if (e.success) {
                                    showTips("删除成功!");
                                    initData();
                                }
                                else mini.alert(e.message);
                            });
                        }
                    }
            );
        else
            tree.removeNode(nowEditorNode);
    }

    function save() {
        var api = "script/" + nowEditorId;
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
        data.content = editor.getValue();
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
    function exec() {
        if (nowEditorId != '') {
            $("#result").html("");
            var paramBuilder = mini.get('paramBuilder').getValue();
            var method = mini.get('method').getValue();
            var script = "(function(){" + paramBuilder + "})();";
            try {
                var param = eval(script);
                if (typeof(param) == 'undefined')param = {};
                var api = Request.BASH_PATH + "script/exec/" + nowEditorId;
                $("#result").append("执行:" + api + "</br>");
                $("#result").append("方法 :" + method + "</br>");
                $("#result").append("参数 :" + mini.encode(param) + "</br>");

                Request.doAjax(api, param,method, function (e) {
                    $("#result").append("执行结果 :" + mini.encode(e) + "</br>");
                }, true, method != 'GET'&&method != 'DELETE');
            } catch (e) {
                $("#result").html("error:" + e);
                throw e;
            }
        }
    }
    function nodeselect(e) {
        if (!e.node) {
            return;
        }
        nowEditorNode = e.node;
        if (e.node._type == "script") {
            nowEditorId = e.node.id;
            initConfig();
        }
    }
    function initConfig() {
        if (nowEditorId == "") {
            new mini.Form("#formContainer").setData({});
            editor.setValue("");
            return;
        }
        Request.get("script/" + nowEditorId, {}, function (e) {
            if (e.success) {
                new mini.Form("#formContainer").setData(e.data);
                var type = e.data.type;
                if (type == 'js')type = 'javascript';
                if (type == 'java')type = 'text/x-java';
                initScriptEditor(type, e.data.content);
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
                        var data = {name: value, type: "script", parentId: pid};
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
    function newScript() {
        var node = tree.getSelectedNode();
        if (!node) {
            showTips("请选中一个类别!", "danger");
            return;
        }
        var parent = nowEditorNode;
        if (nowEditorNode._type != 'classified') {
            parent = tree.getParentNode(nowEditorNode);
        }
        var newNode = {id: "", name: "新建脚本", _type: "script"};
        tree.addNode(newNode, "add", parent);
        tree.selectNode(newNode);
        new mini.Form("#formContainer").setData({});
        grid.setData([]);
    }
    initScriptEditor("groovy", "");
    function initScriptEditor(mode, script) {
        $(".CodeMirror").remove();
        $("#code").html(script);
        editor = CodeMirror.fromTextArea(document.getElementById("code"), {
            lineNumbers: true,
            matchBrackets: true,
            lineWrapping: true,
            extraKeys: {
                "Alt-/": 'autocomplete'
            },
            foldGutter: true,
            gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"],
            mode: mode
        });
    }
</script>