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
            width: 100px;
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
                <a class="mini-button" iconCls="icon-upload" plain="true" onclick="importExcel()">导入excel</a>
            </#if>
            <#if authorize.module(meta.key,"export")>
                <a class="mini-menubutton" iconCls="icon-download" plain="true" menu="#excelMenu">导出excel</a>
                <span class="separator"></span>
            </#if>
                <a class="mini-button" iconCls="icon-reload" plain="true" onclick="grid.reload()">刷新</a>
                <a class='mini-menubutton' iconCls='icon-search' plain='true' menu='#searchMenu' onclick='search()'>查询</a>
            </td>
        </tr>
    </table>
    <div style="width: 700px;margin: auto;" id="searchForm">
    </div>
</div>
<ul id="excelMenu" class="mini-menu" style="display:none;">
    <li iconCls="icon-download">导出本页数据</li>
    <li iconCls="icon-download">导出本页完整数据</li>
    <li iconCls="icon-download">自定义导出列</li>
</ul>
<ul id="searchMenu" class="mini-menu" style="display:none;">
    <li iconCls="icon-application-view-list">自定义查询条件</li>
</ul>
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
        var lineNumber=1;
        $(searchFormConfig).each(function (i, e) {
            if (e.field) {
                if (index != 0 && index % newLineIndex == 0) {
                    lineNumber++;
                    html += "</tr><tr>";
                }
                index++;
                html += "<td class='title'>";
                html += e.title+":";
                html += "</td>";
                html += "<td class='html'>";
                html += e.html;
                html += "</td>";
            }
        });
        $("#searchForm").html(html);
    }
    initSearchForm();
    mini.parse();
    var grid = mini.get('grid');
    bindDefaultAction(grid);
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
    function importExcel() {
        openFileUploader("excel", "", function (e) {
            grid.loading("上传数据中...");
            var ids = [];
            var mapData = {};
            $(e).each(function (i, e) {
                ids.push(e.id);
                mapData[e.id] = e;
            });
            Request.patch("dyn-form/" + meta.dynForm + "/import/" + ids, {}, function (e1) {
                grid.reload();
                if (e1.success) {
                    var ms = e1.data;
                    showImportResult(ms, e);
                }
            });
        })
    }
    function showImportResult(data, fileInfo) {
        var html = "";
        $(fileInfo).each(function (i, e) {
            var msg = data[e.id];
            html += "导入" + e.name + ",总计:" + msg.total + "条,成功:"
                    + msg.success + ",失败:" + (msg.total - msg.success) + "<br/>";
        });
        mini.alert(html);
    }
</script>