<#import "../../global.ftl" as global />
<#import "../../authorize.ftl" as authorize/>
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
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

        .action-enable {
            color: green;
            cursor: pointer;
        }
    </style>
</head>
<body>
<div class="mini-toolbar" style="width: 100%;padding:2px;border-bottom:0;">
    <table id="searchForm" style="width:100%;border: 0px">
        <tr>
            <td style="width:100%;">
            <#if authorize.module('user','C')>
                <a class="mini-button" iconCls="icon-add" plain="true" onclick="create()">创建用户</a>
                <span class="separator"></span>
            </#if>
                <a class="mini-button" iconCls="icon-reload" plain="true" onclick="grid.reload()">刷新</a>
            </td>
            <td style="white-space:nowrap;">
                <label>用户名: </label>
                <input name="username$LIKE" style="width: 100px" onenter="search()" class="mini-textbox"/>
                <label>状态: </label>
                <input name="status" emptyText="全部" showNullItem="true" nullItemText="全部" style="width: 80px;" onvaluechanged="search()"
                       data="[{id:1,text:'正常'},{id:-1,text:'已注销'}]" class="mini-combobox"/>
                <a class="mini-button" iconCls="icon-search" plain="true" onclick="search()">查询</a>
            </td>
        </tr>
    </table>
</div>
<div class="mini-fit">
    <div id="grid" class="mini-datagrid" style="width:100%;height:100%;"
         url="<@global.api 'user'/>" ajaxOptions="{type:'GET',dataType:'json'}" idField="id"
         sizeList="[10,20,50,200]" pageSize="20">
        <div property="columns">
            <div type="indexcolumn"></div>
            <div field="username" width="120" align="center" headerAlign="center" allowSort="true">用户名</div>
            <div field="name" width="120" align="center" headerAlign="center" allowSort="true">姓名</div>
            <div field="phone" width="100" align="center" align="center" headerAlign="center">联系电话</div>
            <div field="createDate" width="100" align="center" headerAlign="center" dateFormat="yyyy-MM-dd" allowSort="true">创建日期</div>
            <div field="status" renderer="renderStatus" align="center" width="100" headerAlign="center" allowSort="true">状态</div>
            <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
        </div>
    </div>
</div>
</body>
</html>
<script type="text/javascript">
    var accessUpdate =${authorize.module('user','U')?c};
    var accessDelete =${authorize.module('user','D')?c};
</script>
<@global.importRequest/>
<@global.resources 'js/user/list.js'/>