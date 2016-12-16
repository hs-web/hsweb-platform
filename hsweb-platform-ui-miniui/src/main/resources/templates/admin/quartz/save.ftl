<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importUeditorParser/>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 90%;
        }

        #scriptArea {
            width: 95%;
            height: 95%;
            border: 0px;
            overflow: hidden;
        }
    </style>
</head>
<body>
<div id="data-form" style="margin-top:20px">
    <table style="width: 90%;margin: auto" data-sort="sortDisabled">
        <tbody>
        <tr class="firstRow">
            <th style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4">
				<span style="font-size: 24px;">
					定时任务配置
				</span>
                <br>
            </th>
        </tr>
        <tr>
            <td valign="middle" style="border-color: rgb(221, 221, 221);" width="180"
                align="right">
                任务名称
                <br>
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221);" width="180">
                <input class="mini-textbox" style="width: 90%" name="name">
            </td>
            <td valign="middle" style="border-color: rgb(221, 221, 221);" width="180"
                align="right">
				<span>
					脚本语言
				</span>
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221);" width="254">
                <input class="mini-combobox" name="language" value="groovy" data="languageData" onvaluechanged="changeLanguage" clearonload="true">
            </td>
        </tr>
        <tr>
            <td valign="middle" style="border-color: rgb(221, 221, 221);" width="180"
                align="right">
                cron表达式
                <br>
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221);" rowspan="1"
                colspan="2">
                <input class="mini-buttonedit" onbuttonclick="chooseCron" textName="cron" onvaluechanged="initCronExecTime()" style="width: 90%" name="cron">
            </td>
            <td rowspan="1" valign="top" align="null" width="235" style="border-color: rgb(221, 221, 221);">
                最近5次执行时间: <input emptyText="请先选择cron表达式" style="width: 250px" class="mini-combobox" id="execTimeList"/>
            </td>
        </tr>
        <tr>
            <td valign="middle" rowspan="1" colspan="1" style="border-left-color: rgb(221, 221, 221); border-top-color: rgb(221, 221, 221);"
                align="right">
				<span style="text-align: -webkit-right;">
					备注
				</span>
            </td>
            <td valign="top" rowspan="1" colspan="3" style="border-left-color: rgb(221, 221, 221); border-top-color: rgb(221, 221, 221);">
                <input class="mini-textarea" style="width: 90%" name="remark">
            </td>
        </tr>
        <tr>
            <td valign="top" style="border-color: rgb(221, 221, 221);" width="180"
                align="right">
                执行脚本
            </td>
            <td valign="top" style="border-color: rgb(221, 221, 221);" rowspan="1"
                colspan="3" height="400">
                <iframe id="scriptArea" style="border: 1px solid grey"></iframe>
            </td>
        </tr>
        </tbody>
    </table>
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
<@global.resources 'js/quartz/save.js'/>
