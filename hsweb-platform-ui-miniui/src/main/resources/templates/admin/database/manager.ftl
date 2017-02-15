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
            width: 99%;
            height: 100%;
        }

        .CodeMirror {
            border: 1px solid #D2D6D7;
            font-size: 16px;
            width: 100%;
            margin: auto;
            height: 180px;
        }

        .split {
            margin-left: 0.5em;
        }
    </style>
</head>
<body>
<div class="mini-toolbar">
    <a class="mini-button" iconCls="icon-application" onclick="exec()" plain="true">运行</a>
</div>
<iframe id="sqlEditor" src="<@global.api "admin/ide/editor.html"/>" style="width:100%;height: 200px;border: 1px solid #cacaca"></iframe>

<div class="mini-fit">
    <div id="mainTabs" closeclick="" class="mini-tabs" activeIndex="0" style="width:100%;height:100%;">

    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var sqlEditor = document.getElementById("sqlEditor");
    var editor;
    mini.parse();
    var datasource = "";
    window.setDataSource = function (ds) {
        if (datasource != ds && editor) {
            editor.location.reload();
        }
        datasource = ds;

    }
    var tabs = mini.get('mainTabs');
    function nodedblclick(e) {
        var node = e.node;
    }
    initScriptEditor("");
    function exec() {
        tabs.removeAll();
        var sql;
        if ((sql = editor.getSelection()) == '') {
            sql = editor.getScript()
        }
        if ($.trim(sql) == "")return;
        Request.post("database/exec/" + datasource, sql, function (e) {
            if (e.success) {
                var data = e.data;
                $(data).each(function () {
                    var info = this;
                    if (info.type == "select") {
                        var el = addTab("select");
                        createSelectResultTable(info, el);
                    } else {
                        addTab(info.type).innerHTML = info.sql + "<br/> 影响数据:" + info.total + "行";
                    }
                    if (info.type == "alter" || info.type == "create" || info.type == "comment" || info.type == "drop") {
                        window.parent.initData();
                    }
                });
            } else {
                addTab("<span style='red'>错误</span>").innerHTML = e.message;
            }
        });
    }
    var index = 0;
    function createSelectResultTable(data, el) {
        var id = "grid" + (index++);
        var html = "<div id=\"" + id + "\"  allowCellEdit=\"true\"allowCellSelect=\"true\" showPager=false class=\"mini-datagrid\" style=\"width:100%;height:100%;\">\n" +
                "   </div> ";
        el.innerHTML = html;
        mini.parse();
        var grid = mini.get(id);
        var columns = [{type: "indexcolumn", header: "#", width: 10, headerAlign: "center"}];
        $(data.columns).each(function () {
            columns.push({field: this, width: 50, align: "center", headerAlign: "center", autoEscape: true, header: this, editor: {type: "textarea"}});
        });
        grid.set({
            columns: columns
        });
        grid.setData(data.data);
    }
    function addTab(title) {
        var tab = {title: title};
        tab = tabs.addTab(tab);
        var el = tabs.getTabBodyEl(tab);
        tabs.activeTab(tab);
        return el;
    }

    function initScriptEditor(script) {
        $(sqlEditor).on("load", function () {
            var win = sqlEditor.contentWindow;
            if (win.init) {
                editor = win;
                editor.init("sql", script, false);
                initAutoComplete();
            }
        });
    }
    function initAutoComplete() {
        var data = window.parent.getTableMetas();
        var autoComplete = [];
        if (data && data[0]) {
            $(data[0].children).each(function () {
                var t = this;
                autoComplete.push({meta: this.comment, caption: this.name.toLowerCase(), value: this.name.toLowerCase(), score: 1});
                $(this.children).each(function () {
                    autoComplete.push({meta: this.comment ? t.comment + ":" + this.comment : "", caption: t.name.toLowerCase() + "." + this.name, value: this.name, score: 1});
                });
            });
        }
        if (editor)
            editor.setCompleteData(autoComplete);
    }
    window.setSql = function (sql) {
        var i = window.setInterval(function () {
            if (editor) {
                editor.setScript(sql);
                clearInterval(i);
            }
        }, 100);
    }
</script>