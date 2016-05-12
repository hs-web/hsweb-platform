<#import "../../global.ftl" as global />
<#import "../../authorize.ftl" as authorize />
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

        .action-edit {
            color: green;
            cursor: pointer;
        }

        .action-remove {
            color: red;
            cursor: pointer;
        }

        .searchForm {
            width: 100%;
            margin: auto;
        }

        .searchForm .title {
            width: 80px;
            text-align: right;
        }

        .searchForm .html {
            width: 200px;
            text-align: left;
        }

        .searchForm td {
            height: 30px;;
        }
    </style>
</head>
<body>
<div class="mini-toolbar" style="width: 100%;padding:2px;border-bottom:0;">
    <table style="width:100%;">
        <tr>
            <td style="width:100%;">
            <#if authorize.module(meta.key,"C")>
                <a class="mini-button" iconCls="icon-edit" plain="true" onclick="createData()">新建</a>
                <span class="separator"></span>
            </#if>
            <#if authorize.module(meta.key,"import")>
                <a class="mini-button" iconCls="icon-upload" plain="true">导入</a>
            </#if>
            <#if authorize.module(meta.key,"export")>
                <a class="mini-button" iconCls="icon-download" plain="true">导出excel</a>
                <span class="separator"></span>
            </#if>

                <a class="mini-button" iconCls="icon-reload" plain="true" onclick="grid.reload()">刷新</a>
                <a class="mini-button" iconCls="icon-search" plain="true" onclick="search()">搜索</a>
            </td>
        </tr>
    </table>
    <div style="width: 700px;margin: auto;" id="searchForm">
    </div>
</div>
<div class="mini-fit">
    <div id="grid" class="mini-datagrid" style="width:100%;height:100%;" ajaxOptions="{type:'GET'}" idField="id"
         sizeList="[10,20,50,200]" pageSize="20">
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var searchFormConfig =${queryPlanConfig!"''"};
    var meta = ${meta.meta!''};
    var queryTableConfig = meta.queryTableConfig;
    var includes = ["u_id"];
    queryTableConfig.unshift({type: 'indexcolumn', header: "#", headerAlign: 'center'});
    $(queryTableConfig).each(function (i, e) {
        if (e.field)
            includes.push(e.field)
        for (var f in e) {
            if (e[f] == 'true')e[f] = true;
            if (e[f] == 'false')e[f] = false;
        }
    })
    function initSearchForm() {
        var html = "<table  class='searchForm'><tr>";
        var index = 0;
        var newLineIndex = 3;
        $(searchFormConfig).each(function (i, e) {
            if (e.field) {
                if (index != 0 && index % newLineIndex == 0) {
                    html += "</tr><tr>";
                }
                index++;
                html += "<td class='title'>";
                html += e.title + ":";
                html += "</td>";
                html += "<td class='html'>";
                html += e.html;
                html += "</td>";
            }
        });
        html += "</tr></table>";
        $("#searchForm").html(html);
    }
    initSearchForm();
    mini.parse();
    var grid = mini.get('grid');
    grid.setUrl(Request.BASH_PATH + meta.table_api);
    grid.setColumns(queryTableConfig);
    search();
    function search() {
        var param = {};
        param.includes = includes + "";
        grid.load(param);
    }
    function createActionMenu(title, action) {
        return "&nbsp;&nbsp;<a href='javascript:;' onclick=\"" + action + "\">" + title + "</a>";
    }

    function actionButton(e) {
        return createActionMenu("查看", "infoData('" + e.record.u_id + "')") + createActionMenu("编辑", "editData('" + e.record.u_id + "')");
    }

    function createData() {
        var createUrl = meta.create_page;
        if (createUrl) {
            openWindow(Request.BASH_PATH + createUrl, "编辑", "80%", "80%", function (e) {
                grid.reload()
            });
        }
    }
    function editData(e) {
        var saveUrl = meta.save_page;
        saveUrl = saveUrl.replace("{u_id}", e);
        if (saveUrl) {
            openWindow(Request.BASH_PATH + saveUrl, "编辑", "80%", "80%", function (e) {
                grid.reload()
            });
        }
    }
    function infoData(e) {
        var url = meta.info_page;
        url = url.replace("{u_id}", e);
        if (url) {
            openWindow(Request.BASH_PATH + url, "查看", "80%", "80%", function (e) {
                grid.reload()
            });
        }
    }
</script>