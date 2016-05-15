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
            height: 90%;
        }
    </style>
</head>
<body>
<div id="data-form" style="margin-top:20px">
    <table data-sort="sortDisabled" style="width:80%;margin:auto;">
        <tbody>
        <tr class="firstRow">
            <th style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4"><span id="title" style="font-size: 24px;">
            ${param.id???string('编辑用户','新建用户')}
            </span></th>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">用户名</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left">
                <input style="width:100%" required="true" name="username" id="username" class="mini-textbox"></td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="131">密码</td>
            <td valign="top" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="434">
                <input style="width:100%" required="true" name="password" id="password" class="mini-password"></td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">姓名</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left"><input style="width:100%" name="name" id="name" class="mini-textbox"></td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="131">电话</td>
            <td valign="top" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="434"><input style="width:100%" name="phone" id="phone" class="mini-textbox"></td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">邮箱</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left">
                <input style="width:100%" name="email" id="email" vtype="email" class="mini-textbox"></td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" rowspan="1" colspan="2"><br></td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">角色配置</td>
            <td valign="top" rowspan="1" colspan="3" style="border-color: rgb(221, 221, 221);">

            </td>
        </tr>
        </tbody>
    </table>
</div>
<div id="roleGrid" class="mini-datagrid" style="width:80%;height:200px;margin: auto"
     url="<@global.api "role?paging=false"/>" ajaxOptions="{type:'GET'}" showpager="false"
     allowCellSelect="true" multiSelect="true" >
    <div property="columns">
        <div type="checkcolumn"></div>
        <div name="id" field="id" width="60">ID</div>
        <div name="name" field="name" width="120">角色名称</div>
        <div name="remark" field="remark" width="120">备注</div>
    </div>
</div>
<#--
position:fixed;z-index: 99999;bottom: 0px;-->
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
<@global.resources 'js/user/save.js'/>
