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
                接口信息
            </span>
            </th>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">client_id</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left" align="left">
                <span name="id"></span>
            </td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">client_secret</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left" align="left">
                <span name="secret"></span>
            </td>
        </tr>
        <tr>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" align="right" width="210">接入名称</td>
            <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="433" align="left">
                <span name="name"></span>
            </td>
        </tr>
        </tbody>
    </table>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    mini.parse();
    uParse('#data-form', {
        rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
        chartContainerHeight: 500
    });
    loadData();
    function loadData() {
        if (id != "") {
            Request.get("oauth2/client/user", function (e) {
                if (e.success) {
                   for(var f in e.data){
                       $("[name="+f+"]").text(e.data[f]);
                   }
                }
            });
        }
    }
</script>
