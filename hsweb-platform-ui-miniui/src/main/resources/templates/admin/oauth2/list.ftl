<#import "../../global.ftl" as global />
<#import "../../authorize.ftl" as authorize />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
    </style>
</head>
<body>
<div class="mini-toolbar" style="width: 100%;padding:2px;border-bottom:0;">
    <table id="searchForm" style="width:100%;border: 0px">
        <tr>
            <td style="width:100%;">
            <#if authorize.module('oauth2-manager','C')>
                <a class="mini-button" iconCls="icon-add" plain="true" onclick="create()">新建客户端</a>
                <span class="separator"></span>
            </#if>
                <a class="mini-button" iconCls="icon-reload" plain="true" onclick="grid.reload()">刷新</a>
            </td>
            <td style="white-space:nowrap;">
                <label>client_id: </label>
                <input name="id$LIKE" style="width: 120px" onenter="search()" class="mini-textbox"/>
                <label>客户端名称: </label>
                <input name="name$LIKE" style="width: 100px" onenter="search()" class="mini-textbox"/>
                <label>状态: </label>
                <input name="status" emptyText="全部" showNullItem="true" nullItemText="全部" style="width: 80px;" onvaluechanged="search()"
                       data="[{id:1,text:'正常'},{id:-1,text:'已禁用'}]" class="mini-combobox"/>
                <a class="mini-button" iconCls="icon-search" plain="true" onclick="search()">查询</a>
            </td>
        </tr>
    </table>
</div>
<div class="mini-fit">
    <div id="datagrid" class="mini-datagrid" style="width:100%;height:100%;"
         url="<@global.api 'oauth2/client'/>" ajaxOptions="{type:'GET',dataType:'json'}" idField="id"
         sizeList="[10,20,50,200]" pageSize="20">
        <div property="columns">
            <div type="indexcolumn"></div>
            <div field="name" width="80" align="center" align="center" headerAlign="center">名称</div>
            <div field="id" width="100" align="center" headerAlign="center" allowSort="true">client_id</div>
            <div field="secret" width="100" align="center" headerAlign="center" allowSort="true">client_secret</div>
            <div field="comment" width="100" align="center" headerAlign="center" allowSort="true">备注</div>
            <div field="status" renderer="renderStatus" align="center" width="50" headerAlign="center" allowSort="true">状态</div>
            <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    mini.parse();
    var grid = mini.get('datagrid');
    bindDefaultAction(grid);
    search();
    function search() {
        var data = new mini.Form("#searchForm").getData();
        var queryParam = Request.encodeParam(data);
        grid.load(queryParam);
    }
    function rendererAction(e) {
        var row = e.record;
        var html = "";
        if (row.status != 1) {
        <#if authorize.module('oauth2-manager','enable')>
            html += createActionButton("启用", "enable('" + row.id + "')", "icon-ok");
        </#if>
        <#if authorize.module('oauth2-manager','D')>
            html += createActionButton("删除", "remove('" + row.id + "')", "icon-remove");
        </#if>
        } else {
        <#if authorize.module('oauth2-manager','U')>
            html += createActionButton("更新密钥", "refreshSecret('" + row.id + "')", "icon-reload");
        </#if>
        <#if authorize.module('oauth2-manager','disable')>
            html += createActionButton("禁用", "disable('" + row.id + "')", "icon-exclamation");
        </#if>
        }
        <#if authorize.module('oauth2-manager','U')>
            html += createActionButton("编辑", "edit('" + row.id + "')", "icon-edit");
        </#if>
        return html;
    }

    function edit(id){
        openWindow(Request.BASH_PATH + "admin/oauth2/save.html?id="+id, "编辑客户端", "600px", "400px", function (e) {
            grid.reload();
        });
    }
    function create() {
        openWindow(Request.BASH_PATH + "admin/oauth2/save.html", "创建客户端", "600px", "400px", function (e) {
            grid.reload();
        });
    }

    function refreshSecret(id) {
        mini.confirm("确定更新密钥?", "确定？",
                function (action) {
                    if (action == "ok") {
                        grid.loading("更新中...");
                        Request['put']("oauth2/client/secret/" + id, {}, function (e) {
                            if (e.success) {
                                grid.reload();
                                showTips("更新成功!");
                            } else {
                                showTips(e.message, 'danger');
                            }
                        });
                    }
                }
        );
    }

    function remove(id) {
        mini.confirm("确定删除此客户端", "确定？",
                function (action) {
                    if (action == "ok") {
                        grid.loading("删除中...");
                        Request['delete']("oauth2/client/" + id, {}, function (e) {
                            if (e.success) {
                                grid.reload();
                                showTips("删除成功!");
                            } else {
                                showTips(e.message, 'danger');
                            }
                        });
                    }
                }
        );
    }

    function enable(id) {
        grid.loading("启用中...");
        Request.put("oauth2/client/enable/" + id, {}, function (e) {
            if (e.success) {
                grid.reload();
                showTips("启用成功!");
            } else {
                showTips(e.message, 'danger');
            }
        });
    }
    function disable(id) {
        mini.confirm("确定禁用此客户端", "确定？",
                function (action) {
                    if (action == "ok") {
                        grid.loading("注销中...");
                        Request.put("oauth2/client/disable/" + id, {}, function (e) {
                            if (e.success) {
                                grid.reload();
                                showTips("注销成功!");
                            } else {
                                showTips(e.message, 'danger');
                            }
                        });
                    }
                }
        );
    }
    function renderStatus(e) {
        return e.value == 1 ? "<span class='green'>正常</span>" : "<span class='red'>已禁用</span>";
    }
</script>
