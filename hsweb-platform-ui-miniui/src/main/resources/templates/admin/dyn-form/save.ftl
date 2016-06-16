<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importUeditorParser/>
    <style type="text/css">
        .form-table {
            border: 0px;
        }

        .action-icon {
            width: 16px;
            height: 16px;
            display: inline-block;
            background-position: 50% 50%;
            cursor: pointer;
            line-height: 16px;
        }

        .action-span {
            font-size: 16px;
            cursor: pointer;
            display: inline-block;
            line-height: 16px;
        }
        .tool a{
            margin-left: 0.8em;
        }
    </style>
</head>
<body>
<div id="formContent">
</div>
<div style="margin: 20px auto 30px;width: 350px" class="tool">
    <a class="mini-menubutton" iconCls="icon-database-table" plain="true" menu="#DraftMenu">草稿箱</a>
    <a class="mini-button" iconCls="icon-reload" plain="true" onclick="window.location.reload()">重新填写</a>
    <a class="mini-button" iconCls="icon-tick" plain="true" onclick="save()">提交</a>
    <a class="mini-button" iconCls="icon-undo" plain="true" onclick="window.closeWindow(id)">返回</a>
</div>
<ul id="DraftMenu" class="mini-menu" style="display:none;">
    <li iconCls="icon-save" onclick="saveDraft()">保存为草稿(ctrl+s)</li>
    <li iconCls="icon-find" onclick="mini.get('window').show()" id="draftLi">选择草稿(<span class="draftSize">0</span>)(ctrl+q)</li>
</ul>
<div id="window" showModal="false" style="width: 500px;height: 300px" class="mini-window" title="草稿箱">
    <div id="grid" class="mini-datagrid" onrowdblclick="chooseDraft()" style="width:100%;height:100%;" idField="id" showPager="false">
        <div property="columns">
            <div type="indexcolumn"></div>
            <div field="name" width="120" align="center" headerAlign="center" allowSort="true">名称</div>
            <div field="createDate" width="100" align="center" headerAlign="center" dateFormat="yyyy-MM-dd HH:mm:ss" allowSort="true">创建日期</div>
            <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<@global.importPlugin  "form-designer/form.parser.js"/>
<@global.importPlugin "mousetrap/mousetrap.min.js"/>
<script type="text/javascript">
    var formName = "${name!''}";
    var version="#{version!'0'}";
    var id = "${id!''}";
    var formParser = new FormParser({name: formName, target: "#formContent",version:version});
    var grid;
    var win;
    var needAudit=true;
    formParser.onload = function () {
        mini.parse();
        grid = mini.get("grid");
        win = mini.get("window");
        loadDraft();
        var meta = formParser.data.meta.main;
        var conf = list2Map(meta);
        //数据需要审核
        needAudit=conf.needAudit;
        uParse('#formContent', {
            rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
            chartContainerHeight: 5000
        });
        $(".mini-radiobuttonlist td").css("border", "0px");
        $(".mini-checkboxlist td").css("border", "0px");
        $(".mini-radiobuttonlist").css("display ", "inline");
    };
    load();

    function list2Map(list) {
        var map = {};
        $(list).each(function (index, o) {
            map[o.key] = o.value;
        });
        return map;
    }

    function createActionButton(text, action, icon) {
        return '<span class="action-span" title="' + text + '" onclick="' + action + '">' +
                '<i class="action-icon ' + icon + '"></i>' + "" //text
                + '</span>&nbsp;&nbsp;';
    }
    function rendererAction(e) {
        return createActionButton("选择草稿", "chooseDraft(" + e.record._id + ")", "icon-tick") + createActionButton("删除草稿", "removeDraft('" + e.record.id + "')", "icon-remove");
    }
    function removeDraft(id) {
        mini.confirm("确定删除此草稿？", "确定？",
                function (action) {
                    if (action == "ok") {
                        Request['delete']("draft/" + formName + "/" + id, {}, function (e) {
                            if (e.success) {
                                showTips("删除成功");
                                loadDraft();
                            } else {
                                mini.alert("删除失败:" + e.message);
                            }
                        });
                    }
                }
        );
    }

    function chooseDraft(rowId) {
        var row;
        if (rowId)
            row = getRow(grid, rowId);
        else {
            row = grid.getSelected();
        }
        if (row.value) {
            formParser.setData(row.value);
        }
        win.hide();
    }
    function load() {
        if (id != "") {
            var api = "dyn-form/" + formName + "/" + id;
            Request.get(api, {}, function (e) {
                if (e.success) {
                    formParser.load(e.data);
                } else {
                    mini.alert(e.message);
                }
            });
        } else {
            formParser.load();
        }
    }
    function loadDraft() {
        $("#draftLi").hide();
        Request.get("draft/" + formName, {}, function (e) {
            if (e.success) {
                grid.setData(e.data);
                if (e.data.length > 0) {
                    $(".draftSize").text(e.data.length);
                    $("#draftLi").show();
                }
            }
        });
    }
    function saveDraft() {
        var data = formParser.getData(false);
        if (!data)return;
        for (var f in data) {
            if (typeof (data[f]) == 'object') {
                data[f] = mini.getbyName(f).getFormValue();
            }
        }
        mini.prompt("请输入草稿名称：", "请输入",
                function (action, value) {
                    if (action == "ok") {
                        Request.post("draft/" + formName, {value: data, name: value}, function (e) {
                            if (e.success) {
                                showTips("草稿已保存,草稿箱的数据暂时无法永久保存,请及时使用.", "danger");
                            }
                            loadDraft();
                        });
                    }
                }
        );
    }

    function doSave(func,api,data){
        var box = mini.loading("提交中...", "");
        func(api, data, function (e) {
            mini.hideMessageBox(box);
            if (e.success) {
                if (id == "") {
                    id = e.data;
                    if (window.history.pushState)
                        window.history.pushState(0, "", "?id=" + id);
                }
                showTips("保存成功!");
            } else if (e.code == 400) {
                try {
                    var validMessage = mini.decode(e.message);
                    $(validMessage).each(function (i, e) {
                        mini.getbyName(e.field).setIsValid(false);
                        mini.getbyName(e.field).setErrorText(e.message);
                    });
                    var field = mini.getbyName(validMessage[0].field);
                    if (field)
                        field.focus();
                    showTips("保存失败:" + validMessage[0].message + "....", "danger")
                } catch (e) {
                    if (window.console) {
                        console.log(e);
                    }
                    mini.alert("保存失败,请联系管理员!");
                }
            } else {
                showTips("保存失败!", "danger")
            }
        });
    }
    function save() {
        var api = "dyn-form/" + formName + "/" + id;
        var func = id == "" ? Request.post : Request.put;
        //提交数据
        var data = formParser.getData();
        if (!data)return;
        for (var f in data) {
            if (typeof (data[f]) == 'object') {
                data[f] = mini.getbyName(f).getFormValue();
            }
        }
        if(needAudit){
            mini.confirm("<span class='red'>此数据提交后需要审核才能生效<br/>提交后在审核之前无法再进行修改<br/>请确保数据已经填写完整</span>", "确定？",
                function (action) {
                    if (action == "ok") {
                        doSave(func,api,data);
                    }
                }
            );
        }else{
            doSave(func,api,data)
        }
    }

    Mousetrap.bind('ctrl+s', function(e) {
        saveDraft();
        return false;
    });
    Mousetrap.bind('ctrl+q', function(e) {
        win.show();
        return false;
    });
</script>