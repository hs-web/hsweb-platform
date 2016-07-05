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
            margin-left: 1em;
        }
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div class="header" region="north" height="35" showSplit="false" showHeader="false">
        <div class="mini-toolbar" style="width: 99%;border-bottom:0;">
            <table id="searchForm">
                <tr>
                    <td style="width:100%;">
                        <a class="mini-button" iconCls="icon-add" plain="true" onclick="newClassified()">创建分类</a>
                        <span class="separator"></span>
                    <#if authorize.module('form','C')>
                        <a class="mini-button" iconCls="icon-add" plain="true" onclick="create()">创建表单</a>
                        <span class="separator"></span>
                    </#if>
                        <a class="mini-button" iconCls="icon-reload" plain="true" onclick="grid.reload()">刷新</a>
                    </td>
                    <td style="white-space:nowrap;">
                        <label>表单名称: </label>
                        <input name="name$LIKE" style="width: 100px" onenter="search()" class="mini-textbox"/>
                        <label>备注: </label>
                        <input name="remark$LIKE" style="width: 100px" onenter="search()" class="mini-textbox"/>
                        <a class="mini-button" iconCls="icon-search" plain="true" onclick="search()">查询</a>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <div showHeader="false" region="west" width="150" maxWidth="250" minWidth="100">
        <div id="leftTree" style="height: 100%;" class="mini-tree"
             expandOnLoad="true" resultAsTree="false" ajaxOptions="{type:'GET'}"
             iconField="icon" onnodeclick="nodeselect" showTreeIcon="true"
             idField="id" parentField="parentId" textField="name" borderStyle="border:0">
        </div>
    </div>
    <div title="center" region="center">
        <div class="mini-fit">
            <div id="grid" class="mini-datagrid" style="width:100%;height:100%;"
                 url="<@global.api 'form/~latest'/>" ajaxOptions="{type:'GET',dataType:'json'}" idField="uId"
                 sizeList="[10,20,50,200]" pageSize="20" onshowrowdetail="onShowRowDetail"
                 sortFieldField="sorts[0].field" sortOrderField="sorts[0].dir">
                <div property="columns">
                    <div type="expandcolumn">#</div>
                    <div field="name" width="120" align="center" headerAlign="center" allowSort="true">表单名称</div>
                    <div field="remark" width="100" align="center" align="center" headerAlign="center">备注</div>
                    <div field="createDate" width="100" align="center" headerAlign="center" dateFormat="yyyy-MM-dd" allowSort="true">创建日期</div>
                    <div field="version" align="center" width="50" headerAlign="center" allowSort="true">版本</div>
                    <div field="revision" align="center" width="50" headerAlign="center" allowSort="true">修订版</div>
                    <div field="release" align="center" width="50" headerAlign="center" allowSort="true">发布版</div>
                    <div field="using" renderer="renderStatus" align="center" width="100" headerAlign="center" allowSort="true">是否已发布</div>
                    <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
                </div>
            </div>
            <div id="detailGrid_Form" style="display:none;">
                <div id="employee_grid" class="mini-datagrid" ajaxOptions="{type:'GET',dataType:'json'}" showPager="false" style="width:100%;height:150px;"
                     url="<@global.api 'form'/>" sortFieldField="sorts[0].field" sortOrderField="sorts[0].dir">
                    <div property="columns">
                        <div type="indexcolumn"></div>
                        <div field="name" width="120" align="center" headerAlign="center" allowSort="true">表单名称</div>
                        <div field="remark" width="100" align="center" align="center" headerAlign="center">备注</div>
                        <div field="createDate" width="100" align="center" headerAlign="center" dateFormat="yyyy-MM-dd" allowSort="true">创建日期</div>
                        <div field="version" align="center" width="50" headerAlign="center" allowSort="true">版本</div>
                        <div field="revision" align="center" width="50" headerAlign="center" allowSort="true">修订版</div>
                        <div field="release" align="center" width="50" headerAlign="center" allowSort="true">发布版</div>
                        <div field="using" renderer="renderStatus" align="center" width="100" headerAlign="center" allowSort="true">是否已发布</div>
                        <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>


</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var accessCreate =${authorize.module('form','C')?c};
    var accessUpdate =${authorize.module('form','U')?c};
    var accessDelete =${authorize.module('form','D')?c};
    var accessDeploy =${authorize.module('form','deploy')?c};

</script>
<@global.importRequest/>
<@global.resources 'js/form/list.js'/>