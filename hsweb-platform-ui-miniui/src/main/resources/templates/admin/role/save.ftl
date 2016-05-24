<#import "../../global.ftl" as global />
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
            height: 95%;
        }
        .module-span {
            font-size: 12px;;
        }
    </style>
</head>
<body>
<div id="data-form" style="margin-top:20px">
    <table data-sort="sortDisabled" style="width:80%;margin:auto;">
        <tbody>
        <tr class="firstRow">
            <th style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4"><span id="title" style="font-size: 24px;">
            ${param.id???string('编辑角色','新建角色')}
            </span></th>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">角色标识</td>
            <td valign="middle" colspan="3" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left">
                <input style="width:100%" required="true" name="id" id="id" class="mini-textbox"></td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">角色名</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left">
                <input style="width:100%" required="true" name="name" id="name" class="mini-textbox"></td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="131">角色类型</td>
            <td valign="top" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="434">
                <input style="width:100%" name="type" id="type" class="mini-combobox" url="<@global.api 'config/info/system/role-type'/>"></td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">备注</td>
            <td valign="middle" colspan="3" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left">
                <input style="width:100%" name="remark" id="remark" class="mini-textarea">
            </td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">权限配置</td>
            <td valign="top" rowspan="1" colspan="3" style="border-color: rgb(221, 221, 221);">
            </td>
        </tr>
        </tbody>
    </table>
</div>

<div id="funcTree" class="mini-treegrid" style="width:80%;height:60%;margin: auto"
     ajaxOptions="{type:'GET'}"
     treeColumn="id" idField="id" parentField="parentId" resultAsTree="false"
     expandOnLoad="true" showTreeIcon="true"
     allowSelect="false" allowCellSelect="false" enableHotTrack="false"
     ondrawcell="ondrawcell" allowCellWrap="true">
    <div property="columns">
        <div type="indexcolumn"></div>
        <div name="id" field="id" width="120">ID</div>
        <div name="name" field="name" width="80">模块名称</div>
        <div field="optional" width="80%">权限</div>
    </div>
</div>
<div style="width: 100%;height: 20px;text-align: center">
    <a class="mini-button" iconCls="icon-save" plain="true" onclick="save()">保存</a>
    <a class="mini-button" iconCls="icon-undo" plain="true" onclick="closeWindow('back')">返回</a>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var id = "${param.id!''}";
</script>
<@global.resources 'js/role/save.js'/>