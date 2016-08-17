<#import "../../../global.ftl" as global />
<#import "../../../authorize.ftl" as authorize />
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
            <td style="white-space:nowrap;">
                <label>client_id: </label>
                <input name="clientId$LIKE" style="width: 120px" onenter="search()" class="mini-textbox"/>
                <a class="mini-button" iconCls="icon-search" plain="true" onclick="search()">查询</a>
            </td>
        </tr>
    </table>
</div>
<div class="mini-fit">
    <div id="datagrid" class="mini-datagrid" style="width:100%;height:100%;"
         url="<@global.api 'oauth2/access'/>" ajaxOptions="{type:'GET',dataType:'json'}" idField="id"
         sizeList="[10,20,50,200]" pageSize="20">
        <div property="columns">
            <div type="indexcolumn"></div>
            <div field="clientId" width="100" align="center" headerAlign="center" allowSort="true">client_id</div>
            <div field="expireIn" width="100" align="center" headerAlign="center" allowSort="true">有效期</div>
            <div field="createDate" dateFormat="yyyy-MM-dd HH:mm:ss" width="100" align="center" headerAlign="center" allowSort="true">创建日期</div>
            <div field="leftTime" width="100" align="center" headerAlign="center" allowSort="true">剩余时间</div>
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

    function remove(id) {
        mini.confirm("确定删除此认证", "确定？",
                function (action) {
                    if (action == "ok") {
                        grid.loading("删除中...");
                        Request['delete']("oauth2/access/" + id, {}, function (e) {
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
</script>
