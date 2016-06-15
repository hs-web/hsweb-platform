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
            margin-left: 0.8em;
        }

        .action-remove {
            color: red;
            cursor: pointer;
            margin-left: 0.8em;
        }
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div showHeader="false" region="west" width="150" maxWidth="300" minWidth="100">
        <div id="leftTree" style="height: 100%;" class="mini-tree" url="<@global.api "module?paging=false&sortField=sort_index&excludes=m_option" />"
             expandOnLoad="true" resultAsTree="false" ajaxOptions="{type:'GET'}" showTreeIcon="true" iconField="icon"
             onnodeselect="nodeselect" idField="id" parentField="parentId" textField="name" borderStyle="border:0">
        </div>
    </div>
    <div title="center" region="center" bodyStyle="overflow:hidden;">
        <div class="mini-toolbar" style="width: 100%;padding:2px;border-bottom:0;">
            <table id="searchForm" style="width:100%;">
                <tr>
                    <td style="width:100%;">
                    <#if authorize.module('module-meta','C')>
                        <a class="mini-button" iconCls="icon-add" plain="true" onclick="create()">新建模块配置</a>
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
                 url="<@global.api 'module-meta'/>" sortField="id" ajaxOptions="{type:'GET'}" idField="id"
                 sizeList="[10,20,50,200]" pageSize="20">
                <div property="columns">
                    <div type="indexcolumn"></div>
                    <div field="key" width="120" align="center" headerAlign="center" allowSort="true">标识</div>
                    <div field="remark" width="100" align="center" headerAlign="center">备注</div>
                    <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
<@global.importRequest/>
<@global.resources 'js/module-meta/list.js'/>
<script type="text/javascript">
    var accessUpdate =${authorize.module('module-meta','U')?c};
    var accessDelete =${authorize.module('module-meta','D')?c};
    var nowSelectedModuleId = "";
    function nodeselect(e) {
        if (e.node) {
            nowSelectedModuleId = e.node.id;
            search();
        }
    }
    function search() {
        var data = new mini.Form("#searchForm").getData();
        data.module_id = nowSelectedModuleId;
        var queryParam = Request.encodeParam(data);
        grid.load(queryParam);
    }
</script>