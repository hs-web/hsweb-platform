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
    </style>
</head>
<body>
<div class="mini-toolbar" style="width: 100%;padding:2px;border-bottom:0;">
    <table id="searchForm" style="width:100%;">
        <tr>
            <td style="width:100%;">
            <#if authorize.module('role','C')>
                <a class="mini-button" iconCls="icon-add" plain="true" onclick="create()">创建角色</a>
                <span class="separator"></span>
            </#if>
                <a class="mini-button" iconCls="icon-reload" plain="true" onclick="grid.reload()">刷新</a>
            </td>
            <td style="white-space:nowrap;"><label style="font-family:Verdana;">名称: </label>
                <input name="name$LIKE" onenter="search()" class="mini-textbox"/>
                <a class="mini-button" iconCls="icon-search" plain="true" onclick="search()">查询</a>
            </td>
        </tr>
    </table>
</div>
<div class="mini-fit">
    <div id="grid" class="mini-datagrid" style="width:100%;height:100%;"
         url="<@global.api 'role'/>" sortField="u_id" ajaxOptions="{type:'GET'}" idField="id"
         sizeList="[10,20,50,200]" pageSize="20">
        <div property="columns">
            <div type="indexcolumn"></div>
            <div field="name" width="120" align="center" headerAlign="center" allowSort="true">名称</div>
            <div field="type" width="100" align="center" headerAlign="center">类型</div>
            <div field="remark" width="100" align="center" headerAlign="center">备注</div>
            <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<@global.resources 'js/role/list.js'/>
<script type="text/javascript">
    var accessUpdate =${authorize.module('role','U')?c};
    var accessDelete =${authorize.module('role','D')?c};
</script>