<#import "../../global.ftl" as global />
<#import "../../authorize.ftl" as authorize/>
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
            <#if authorize.module('quartz','C')>
                <a class="mini-button" iconCls="icon-add" plain="true" onclick="create()">创建任务</a>
                <span class="separator"></span>
            </#if>
                <a class="mini-button" iconCls="icon-reload" plain="true" onclick="grid.reload()">刷新</a>
            </td>
            <td style="white-space:nowrap;">
                <label>任务名称: </label>
                <input name="name$LIKE" style="width: 200px" onenter="search()" class="mini-textbox"/>
                <label>状态: </label>
                <input name="enabled" emptyText="全部" showNullItem="true" nullItemText="全部" style="width: 80px;" onvaluechanged="search()"
                       data="[{id:1,text:'正常'},{id:0,text:'已停用'}]" class="mini-combobox"/>
                <a class="mini-button" iconCls="icon-search" plain="true" onclick="search()">查询</a>
            </td>
        </tr>
    </table>
</div>
<div class="mini-fit">
    <div id="grid" class="mini-datagrid" style="width:100%;height:100%;"
         url="<@global.api 'quartz'/>" ajaxOptions="{type:'GET',dataType:'json'}" idField="id"
         onshowrowdetail="onShowRowDetail" autoHideRowDetail="true"
         sizeList="[10,20,50,200]" pageSize="20">
        <div property="columns">
            <div type="expandcolumn">查看历史</div>
            <div field="name" width="120" align="center" headerAlign="center" allowSort="true">任务名称</div>
            <div field="cron" width="80" align="center" align="center" headerAlign="center">cron</div>
            <div field="remark" width="120" align="center" headerAlign="center" allowSort="true">备注</div>
            <div field="enabled" renderer="renderStatus" align="center" width="80" headerAlign="center" allowSort="true">状态</div>
            <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
        </div>
    </div>
</div>
<div style="display: none" id="history_div">
    未来5次执行日期:<span id="lstExecTimes"></span>
    <div id="history_grid" class="mini-datagrid" style="width:100%;height:320px;"
         ajaxOptions="{type:'GET',dataType:'json'}" idField="id" sortField="startTime" sortOrder="desc"
         sizeList="[10,20,50,200]" pageSize="10">
        <div property="columns">
            <div field="startTime" width="100" dateFormat="yyyy-MM-dd HH:mm:ss" align="center" headerAlign="center" allowSort="true">开始时间</div>
            <div field="endTime" width="100" dateFormat="yyyy-MM-dd HH:mm:ss" align="center" align="center" allowSort="true" headerAlign="center">结束时间</div>
            <div field="useTime" renderer="renderUseTime" width="80" align="center" align="center" headerAlign="center">耗时</div>
            <div field="status" width="80" renderer="renderHisStatus" align="center" headerAlign="center" allowSort="true" allowSort="true">状态</div>
            <div field="result" renderer="renderResult" width="120" align="center" headerAlign="center" allowSort="true">执行结果</div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    mini.parse();
    var grid = mini.get('grid');
    var history_grid = mini.get('history_grid');
    bindDefaultAction(grid);
    bindDefaultAction(history_grid);
    search();
    var his_div = $("#history_div");
    function renderUseTime(e) {
        var row = e.record;
        if (row.status != 1)return "-";
        return compareDate(row.startTime, row.endTime);
    }
    function onShowRowDetail(e) {
        var row = e.record;
        var td = grid.getRowDetailCellEl(row);

        function initExecTimes() {
            Request.get("quartz/cron/exec-times/5", {cron: row.cron}, function (data) {
                if (data.success) {
                    $("#lstExecTimes").html("");
                    $(data.data).each(function () {
                        $("#lstExecTimes").append("<span style='margin-left: 2em'>" + this + "</span>");
                    });
                    $("#lstExecTimes").append("<span style='margin-left: 2em'>预计每" + compareDate(mini.parseDate(data.data[0]), mini.parseDate(data.data[1])) + "执行一次</span>");
                }
            });
        }

        initExecTimes();
        history_grid.setUrl(Request.BASH_PATH + "quartz/history/" + row.id);
        history_grid.load();
        his_div.appendTo(td);
        his_div.show();
    }
    function renderResult(e) {
        var text = e.value;
        if (!text)return "";
        if (text.length > 30) {
            return "<a href='javascript:void(0)' onclick=\"showResult('" + e.record.id + "')\">" + (text.substr(0, 29)) + "...</a>";
        }
        return text;
    }
    function showResult(id) {
        var row = history_grid.getRowById(id);
        if (row) {
            openTextWindow(row.result);
        }
    }
    function search() {
        var data = new mini.Form("#searchForm").getData();
        var queryParam = Request.encodeParam(data);
        grid.load(queryParam);
    }
    function create() {
        openWindow(Request.BASH_PATH + "admin/quartz/save.html", "新建定时任务", "80%", "80%", function (e) {
            grid.reload();
        });
    }
    function edit(id) {
        openWindow(Request.BASH_PATH + "admin/quartz/save.html?id=" + id, "编辑定时任务", "80%", "80%", function (e) {
            grid.reload();
        });
    }

    function renderStatus(e) {
        if (!e.value)return "<span style='color: red'>已停用</span>";
        else return "<span style='color: green'>正常</span>";
    }

    function renderHisStatus(e) {
        if (e.value == 0)return "<span style='color: blue'>运行中</span>";

        if (e.value != 1)return "<span style='color: red'>失败</span>";
        else return "<span style='color: green'>成功</span>";
    }

    function rendererAction(e) {
        var row = e.record;
        var html = "";
        html += createActionButton("编辑", "edit('" + row.id + "')", "icon-edit");
        if (!row.enabled) {
            html += createActionButton("启用", "enable('" + row.id + "')", "icon-ok");
        <#if authorize.module("quartz","D")>
            html += createActionButton("删除", "remove('" + row.id + "')", "icon-remove");
        </#if>
        }
        else {
            html += createActionButton("禁用", "disable('" + row.id + "')", "icon-cross");
        }
        return html;
    }
    function remove(id) {
        mini.confirm("确定删除此定时任务", "确定？",
                function (action) {
                    if (action == "ok") {
                        grid.loading("删除中...");
                        Request['delete']("quartz/" + id, {}, function (e) {
                            if (e.success) {
                                showTips("删除成功!");
                            } else {
                                showTips(e.message, 'danger');
                            }
                            grid.reload();
                        });
                    }
                }
        );
    }
    function enable(id) {
        grid.loading("启用中...");
        Request.put("quartz/" + id + "/enable", {}, function (e) {
            if (e.success) {
                showTips("启用成功!");
            } else {
                showTips(e.message, 'danger');
            }
            grid.reload();
        });
    }
    function disable(id) {
        mini.confirm("确定停用此定时任务", "确定？",
                function (action) {
                    if (action == "ok") {
                        grid.loading("停用中...");
                        Request.put("quartz/" + id + "/disable", {}, function (e) {
                            if (e.success) {
                                showTips("停用成功!");
                            } else {
                                showTips(e.message, 'danger');
                            }
                            grid.reload();
                        });
                    }
                }
        );
    }
</script>