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
        }

        .action-remove {
            color: red;
            cursor: pointer;
        }

        .searchForm {
            width: 100%;
            margin: auto;
        }

        .searchForm .title {
            min-width: 100px;
            text-align: right;
        }

        .searchForm .html {
            width: 200px;
            text-align: left;
        }

        .searchForm td {
            height: 30px;;
        }
    </style>
</head>
<body>
<div class="mini-toolbar" style="width: 100%;padding:2px;border-bottom:0;">
    <table style="width:100%;">
        <tr>
            <td style="width:100%;">
            <#if authorize.module(meta.key,"C")>
                <a class="mini-button" iconCls="icon-edit" plain="true" onclick="createData()">新建</a>
                <span class="separator"></span>
            </#if>
            <#if authorize.module(meta.key,"import")>
                <a class="mini-button" iconCls="icon-upload" plain="true" onclick="importExcel()">导入excel</a>
            </#if>
            <#if authorize.module(meta.key,"export")>
                <a class="mini-menubutton" iconCls="icon-download" plain="true" menu="#excelMenu">导出excel</a>
                <span class="separator"></span>
            </#if>
                <a class="mini-button" iconCls="icon-reload" plain="true" onclick="search()">刷新</a>
                <a class='mini-menubutton' iconCls='icon-search' plain='true' menu='#searchMenu' onclick='search()'>查询</a>
            </td>
        </tr>
    </table>
    <div style="margin: auto;max-width: 1000px" id="searchForm">
    </div>
</div>
<ul id="excelMenu" class="mini-menu" style="display:none;">
    <li iconCls="icon-download" onclick="exportExcel()">导出本页数据</li>
    <li iconCls="icon-download" onclick="exportAllColumnExcel()">导出本页完整数据</li>
<#--<li iconCls="icon-download" >自定义导出列</li>-->
</ul>
<ul id="searchMenu" class="mini-menu" style="display:none;">
    <li iconCls="icon-application-view-list">自定义查询条件</li>
</ul>
<div class="mini-fit">
    <div id="grid" class="mini-datagrid" style="width:100%;height:100%;" ajaxOptions="{type:'GET',dataType:'json'}" idField="id"
         sizeList="[10,20,50,200]" pageSize="20">
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var searchFormConfig =${queryPlanConfig!"''"};
    <#assign json=meta.meta?eval/>
    <#assign actionGt1=false/>
    <#list json.actionConfig as item>
        <#if authorize.module(json.dynForm item.moduleAction)>
            <#assign actionGt1=true/>
        function action_${item_index}_event(_id) {
            var row = getRow(grid, _id);
            var id = row.u_id;
            ${item.onclick};
        }
        </#if>
    </#list>
    var meta = ${meta.meta!''};
    var queryTableConfig = meta.queryTableConfig;
    <#if actionGt1>
    queryTableConfig.push({"width": 100, "visible": true, "align": "center", "headerAlign": "center", "header": "操作", "renderer": "actionButton"});
    </#if>
    var includes = ["u_id"];
    var searchFormConfigMap = {};
    $(searchFormConfig).each(function (i, e) {
        searchFormConfigMap[e.id] = e;
    });
    var queryTypeMapper = {
        "=": {value: "eq"},
        ">=": {value: "gt"},
        "<=": {value: "lt"},
        "like": {
            value: "like"
        },
        "like%": {
            value: "like", helper: function (v) {
                return v + "%";
            }
        }, "%like": {
            value: "like", helper: function (v) {
                return "%" + v;
            }
        }, "%like%": {
            value: "like", helper: function (v) {
                return "%" + v + "%";
            }
        }, "in": {
            value: "in"
        }, "notin": {
            value: "notin"
        }
    }
    var metaId = "${meta.id}";
    queryTableConfig.unshift({type: 'indexcolumn', header: "#", headerAlign: 'center'});
    var tmpIndex=0;
    $(queryTableConfig).each(function (i, e) {
        if (e.field)
            includes.push(e.field)
        for (var f in e) {
            if (e[f] == 'true')e[f] = true;
            if (e[f] == 'false')e[f] = false;
        }
        if (f == "renderer"&&e[f]&&e[f]!='') {
            var scriptId = "renderer" + (tmpIndex++);
            var script = "window." + scriptId + "=function(e){" +
                    "var row = e.record;var value=e.value;" +
                    e[f] +
                    "}";
            eval(script);
            e[f] = "window." + scriptId;
        }
        if (f == "properties") {
            var properties = mini.decode(e['properties']);
            for (var p in properties) {
                e[p] = properties[p];
            }
        }
    });
    function initSearchForm() {
        var html = "<table class='searchForm'><tr>";
        var index = 0;
        var newLineIndex = 3;
        var lineNumber = 1;
        var x = 0;
        $(searchFormConfig).each(function (i, e) {
            if (e.field) {
                x++;
                if (index != 0 && index % newLineIndex == 0) {
                    lineNumber++;
                    html += "</tr><tr>";
                }
                index++;
                html += "<td class='title font' >";
                html += e.title + ":";
                html += "</td>";
                html += "<td class='html'>";
                html += e.html;
                html += "</td>";
            }
        });
        if (x > newLineIndex) {
            x = 6;
        } else {
            x = x * 2;
        }
        html += "<tr/><tr>";
        html += "<td class='searchTd' colspan='" + x + "' align='center'></td>";
        html += "</tr></table>"
        $("#searchForm").html(html);
        $("<a class='mini-button' iconCls='icon-search' plain='true' onclick='search()'>查询</a>" +
                "<a class='mini-button' iconCls='icon-arrow-rotate-clockwise' plain='true' onclick='new mini.Form(\"#searchForm\").reset();search()'>重置条件</a>").appendTo(".searchTd");
    }
    initSearchForm();
    mini.parse();
    var grid = mini.get('grid');
    bindDefaultAction(grid);
    grid.on("load", function (data) {
        mini.showTips({
            content: "成功加载" + data.data.length + "条数据",
            state: 'success',
            x: 'right',
            y: 'top',
            timeout: 2000
        });
    });
    grid.setUrl(Request.BASH_PATH + meta.table_api);
    grid.setColumns(queryTableConfig);
    var defaultQueryParam = {};
    ${json.script!''}

    search();
    function exportExcel() {
        var param = mini.clone(grid.getLoadParams());
        if (param.excludes) {
            param.excludes += ",u_id";
        } else {
            param.excludes = "u_id";
        }
        var exportApi = Request.BASH_PATH + meta.table_api + "/export/导出.xlsx";
        var paramStr = object2param(param, null, "utf-8");
        window.open(exportApi + "?" + paramStr);
    }
    function exportAllColumnExcel() {
        var param = mini.clone(grid.getLoadParams());
        delete param.includes;
        if (param.excludes) {
            param.excludes += ",u_id";
        } else {
            param.excludes = "u_id";
        }
        var exportApi = Request.BASH_PATH + meta.table_api + "/export/导出.xlsx";
        var paramStr = object2param(param, null, "utf-8");
        window.open(exportApi + "?" + paramStr);
    }
    var object2param = function (param, key, encode) {
        if (param == null) return '';
        var paramStr = '';
        var t = typeof (param);
        if (t == 'string' || t == 'number' || t == 'boolean') {
            paramStr += '&' + key + '=' + ((encode == null || encode) ? encodeURIComponent(param) : param);
        } else {
            for (var i in param) {
                var k = key == null ? i : key + (param instanceof Array ? '[' + i + ']' : '.' + i);
                paramStr += object2param(param[i], k, encode);
            }
        }
        return paramStr;
    };

    function search() {
        var param = {};
        var formData = new mini.Form("#searchForm").getData();
        for (var i in defaultQueryParam) {
            formData[i] = defaultQueryParam[i];
        }
        var index = 0;
        for (var f in formData) {
            if (formData[f] == "")continue;
            if (typeof (formData[f]) == 'object') {
                formData[f] = mini.getbyName(f).getFormValue();
            }
            var conf = searchFormConfigMap[f];
            if (conf) {
                var queryType = queryTypeMapper[conf.queryType];
                if (queryType) {
                    param['terms[' + index + '].termType'] = queryType.value;
                    if (queryType.helper) {
                        formData[f] = queryType.helper(formData[f]);
                    }
                    param['terms[' + index + '].field'] = conf.field;
                } else {
                    param['terms[' + index + '].field'] = conf.field + "$" + conf.queryType;

                }
                param['terms[' + index + '].value'] = formData[f];
            } else {
                param['terms[' + index + '].field'] = f;
                param['terms[' + index + '].value'] = formData[f];
            }
            index++;
        }
        param.includes = includes + "";
        grid.load(param);
    }

    function actionButton(e) {
        var html = "";
        var row = e.record;
    <#list json.actionConfig as item>
        <#if authorize.module(json.dynForm item.moduleAction)>
            function showCondition${item_index}() {
                try {
                ${item.condition!'return true;'}
                } catch (e) {
                    if (window.console) {
                        window.console.log(e);
                    }
                }
                return false;
            }

            if (showCondition${item_index}() == true) {
                html += createActionButton("${item.title}", "action_${item_index}_event(" + e.record._id + ")", "${item.icon}");
            }
        </#if>
    </#list>
        return html;
    }

    function createData() {
        var createUrl = meta.create_page;
        createUrl = createUrl.replace("{id}").replace("{metaId}", metaId);
        if (createUrl) {
            openWindow(Request.BASH_PATH + createUrl, "编辑", "80%", "80%", function (e) {
                grid.reload()
            });
        }
    }

    function editData(e) {
        var saveUrl = meta.save_page;
        saveUrl = saveUrl.replace("{id}", e).replace("{metaId}", metaId);
        if (saveUrl) {
            openWindow(Request.BASH_PATH + saveUrl, "编辑", "80%", "80%", function (e) {
                grid.reload()
            });
        }
    }
    function infoData(e) {
        var url = meta.info_page;
        url = url.replace("{id}", e).replace("{metaId}", metaId);
        if (url) {
            openWindow(Request.BASH_PATH + url, "查看", "80%", "80%", function (e) {
                grid.reload()
            });
        }
    }
    var importErrorMsg;
    var fileTmp;
    function importExcel() {
        openFileUploader("excel", "", function (e) {
            grid.loading("上传数据中...");
            var ids = [];
            var mapData = {};
            $(e).each(function (i, e) {
                ids.push(e.id);
                mapData[e.id] = e;
            });
            fileTmp = mapData;
            Request.patch("dyn-form/" + meta.dynForm + "/import/" + ids, {}, function (e1) {
                grid.reload();
                if (e1.success) {
                    var ms = e1.data;
                    importErrorMsg = ms;
                    showImportResult(ms, e);
                } else {
                    mini.alert("导入失败,请确定上传的excel格式正确！");
                }
            });
        })
    }

    function showImportResult(data, fileInfo) {
        var html = "";
        var error = false;
        $(fileInfo).each(function (i, e) {
            var msg = data[e.id];
            html += "导入" + e.name + ",总计:" + msg.total + "条,成功:"
                    + msg.success + ",失败:" + (msg.total - msg.success) + "<br/>";
            if ((msg.total - msg.success) > 0) {
                error = true;
            }
        });
        if (error)
            html += "<a href='javascript:showImportErrorMsg()'>点击查看原因</a>";
        mini.alert(html);
    }
    function showImportErrorMsg() {
        var html = "";
        for (var err in importErrorMsg) {
            var fileName = fileTmp[err].name;
            var errorMessage = importErrorMsg[err].errorMessage;
            if (errorMessage && errorMessage.length > 0) {
                html += "文件名:" + fileName + ":<br/>";
                $(errorMessage).each(function (i, e) {
                    if (i > 5)return;
                    if (i >= 5) {
                        html += ("省略显示" + (errorMessage.length - 5) + "条错误原因");
                        return;
                    }
                    var message;
                    if (e.message.indexOf("[") == 0) {
                        var tmp = mini.decode(e.message);
                        if (tmp.length > 0)message = tmp[0].message;
                    } else {
                        message = e.message;
                    }
                    html += "第" + e.index + "行，原因:" + message + "<br/>";
                });
            }
        }
        mini.alert(html);
    }
</script>