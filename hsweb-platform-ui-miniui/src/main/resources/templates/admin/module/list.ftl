<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
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
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div class="header" region="north" height="35" showSplit="false" showHeader="false">
        <div class="mini-toolbar">
            <a class="mini-button" iconCls="icon-add" onclick="newModule()" plain="true">新增权限</a>
            <a class="mini-button" iconCls="icon-save" onclick="saveAll()" plain="true">保存全部</a>
            <a class="mini-button" iconCls="icon-reload" onclick="mini.get('leftTree').reload()" plain="true">刷新</a>

            <a class="mini-button" iconCls="icon-help" onclick="showHelp()" plain="true">查看帮助</a>
        </div>
    </div>
    <div showHeader="false" region="west" width="250" maxWidth="500" minWidth="200">
        <div id="leftTree" style="height: 100%;" class="mini-tree" url="<@global.api "module?paging=false&sorts[0].field=sortIndex" />"
             expandOnLoad="true" resultAsTree="false" ajaxOptions="{type:'GET'}" ondrawnode="drawnode" showTreeIcon="true"
             iconField="icon"
             onnodeselect="nodeselect" idField="id" parentField="parentId" textField="name" borderStyle="border:0"
             allowDrag="true" allowLeafDropIn="true" allowDrop="true" contextMenu="#treeMenu" ondrop="ondrop">
        </div>

        <ul id="treeMenu" class="mini-contextmenu" onbeforeopen="onBeforeOpen">
            <li iconCls="icon-add" onclick="newModule()">新增权限</li>
            <li iconCls="icon-save" onclick="saveAll()">保存全部</li>
        </ul>
    </div>
    <div title="center" region="center">
        <br/>

        <div id="formContainer">
            <table data-sort="sortDisabled" style="width:80%;min-width:600px;margin: auto">
                <tbody>
                <tr class="firstRow">
                    <th style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4">
                        <h1 align="center" id="tableTitle">新建权限</h1>
                    </th>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">权限ID</td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="id" id="id" class="mini-textbox" required="true"/>
                    </td>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">权限名称</td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="name" id="name" class="mini-textbox" required="true"/>
                    </td>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">路径映射</td>
                    <td width="129" valign="middle" align="left" colspan="3">
                        <input style="width:100%" name="uri" id="uri" class="mini-textbox">
                    </td>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right"><a href="http://fontawesome.io/icons/" target="_blank">图标</a></td>
                    <td width="129" valign="middle" style="word-break: break-all;" align="left">
                        <input style="width:100%" name="icon" textName="icon" id="icon" onbuttonclick="onbuttonedit" class="mini-buttonedit"/>
                    </td>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">父级权限ID</td>
                    <td width="129" valign="middle" align="left"><input enabled="flase" name="parentId" id="parentId" class="mini-textbox"/>&nbsp;*拖拽左侧菜单调整结构</td>
                </tr>
                <tr>
                    <td width="50" valign="middle" style="word-break: break-all;" align="right">备注<br></td>
                    <td valign="middle" rowspan="1" colspan="1" width="50" align="left">
                        <input style="width:100%" name="remark" id="remark" class="mini-textarea"/></td>
                    <td rowspan="1" valign="middle" align="right" width="50" style="word-break: break-all;">排序</td>
                    <td rowspan="1" valign="middle" align="left" width="128">
                        <input name="sortIndex" enabled="flase" id="sortIndex" class="mini-textbox"/>&nbsp;*拖拽左侧菜单即可排序</td>
                </tr>
                <tr>
                    <td colspan="4" align="center">
                        <a class="mini-button" iconCls="icon-save" plain="true" onclick="save">保存</a>
                        &nbsp; &nbsp;
                        <a class="mini-button" iconCls="icon-remove" plain="true" onclick="remove()">删除</a>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
        <div style="margin: auto;width:600px;">
            <br/>
            <h3 align="center">可选操作</h3>
            <a class="mini-button" iconCls="icon-add" onclick="mini.get('m_option_table').addRow({},0)" plain="true"></a>
            <a class="mini-button" iconCls="icon-remove" plain="true" onclick="mini.get('m_option_table').removeRow(mini.get('m_option_table').getSelected())"></a>

            <div id="m_option_table" class="mini-datagrid"
                 style="margin: auto;width:100%;height:300px;border: 0px;"
                 showPager="false" allowCellEdit="true"
                 allowCellSelect="true" allowAlternating="true" editNextOnEnterKey="true">
                <div property="columns">
                    <div field="id" width="30" align="center" headerAlign="center">ID
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="text" width="30" align="center" headerAlign="center">备注
                        <input property="editor" class="mini-textarea"/>
                    </div>
                    <div field="checked" width="30" align="center" headerAlign="center" renderer="renderTrueOrFalse">默认
                        <input property="editor" class="mini-combobox" data="[{'id':true,text:'是'},{'id':false,text:'否'}]" valueField="id" textField="text"/>
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
    uParse('#formContainer', {
        rootPath: '<@global.basePath />ui/plugins/ueditor',
        chartContainerHeight: 500
    });
    var nowEditorId = "${param.editId!''}";
    function onbuttonedit(e) {
        openWindow(Request.BASH_PATH + "admin/utils/get-icon.html", "选择图标", "800", "400", function (icon) {
            if (icon && icon.indexOf("icon-") != -1) {
                e.sender.setValue(icon);
                e.sender.setText(icon);
            }
        });
    }
    function renderTrueOrFalse(e){
        return e.value+""=="true"?"是":"否";
    }
</script>
<@global.resources "js/module/list.js"/>