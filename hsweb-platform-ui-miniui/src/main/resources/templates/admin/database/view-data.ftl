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
    <a class="mini-button" iconCls="icon-upload" onclick="importExcel()" plain="true">导入excel</a>
    <a class="mini-button" iconCls="icon-download" onclick="importExcel()" plain="true">导出excel</a>
    <a class="mini-button" iconCls="icon-search" onclick="search()" plain="true">查询</a>
</div>
<div class="mini-fit">
    <div id="datagrid" allowCellEdit="true" allowCellSelect="true" showPager=true class="mini-datagrid" style="width:100%;height:100%;">
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    mini.parse();
    var grid = mini.get('datagrid');
    bindDefaultAction(grid);
    window.initData = function (tableMeta) {
        var columns=[];
        $(tableMeta.fields).each(function () {
            columns.push({field: this.name, width: 50, align: "center", headerAlign: "center", autoEscape: true, header: this.name, editor: {type: "textarea"}});
        });
        grid.set({
            columns: columns
        });
    }
</script>