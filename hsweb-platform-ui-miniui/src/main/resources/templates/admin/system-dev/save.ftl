<#import "../../global.ftl" as global />
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

        .action-icon {
            width: 16px;
            height: 16px;
            display: inline-block;
            background-position: 50% 50%;
            cursor: pointer;
            line-height: 16px;
        }
    </style>
</head>
<body>
<div class="mini-fit" id="content-body">
    <div id="tabs1" class="mini-tabs" activeIndex="0" style="width:100%x;height:85%;" plain="false">
        <div title="基础设置">
            <div class="data-form">
                <table data-sort="sortDisabled" style="width: 80%;margin: auto;">
                    <tbody>
                    <tr class="firstRow">
                        <th align="center" style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4">基础设置</th>
                    </tr>
                    <tr>
                        <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="283" align="right">关联模块</td>
                        <td valign="top" style="border-color: rgb(221, 221, 221);" width="375"><input style="width:100%" value="${param.module_id!''}" name="key" id="key" class="mini-textbox" required="true"/></td>
                        <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="262" align="right">关联角色<br></td>
                        <td valign="top" style="border-color: rgb(221, 221, 221);" width="541">
                            <input url="<@global.api "role?paging=false"/>" valuefield="id" textfield="name" multiselect="true" valuefromselect="true" clearonload="true" style="width:100%" name="roleId" id="roleId" class="mini-combobox">
                        </td>
                    </tr>
                    <tr>
                        <td valign="middle" style="border-color: rgb(221, 221, 221); word-break: break-all;" width="292" align="right">备注</td>
                        <td valign="top" style="border-color: rgb(221, 221, 221); word-break: break-all;" rowspan="1" colspan="2">
                            <input style="width:100%" name="remark" id="remark" class="mini-textarea">
                        </td>
                        <td valign="top" style="border-color: rgb(221, 221, 221); word-break: break-all;" width="541"><br></td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <br>

            <p></p>

            <div class="data-form">
                <table class="data-form" data-sort="sortDisabled" style="width: 80%;margin: auto">
                    <tbody>
                    <tr class="firstRow">
                        <th align="center" style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="4">数据来源</th>
                    </tr>
                    <tr>
                        <td valign="middle" style="border-color: rgb(221, 221, 221);" width="150" align="right">表格数据API</td>
                        <td valign="top" style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="3">
                            <input style="width:100%" name="table_api" id="table_api" class="mini-textbox">
                        </td>
                    </tr>
                    <tr>
                        <td valign="middle" style="border-color: rgb(221, 221, 221);" width="150" align="right">新增页面</td>
                        <td valign="top" style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="3">
                            <input style="width:100%" name="create_page" id="create_page" class="mini-textbox">
                        </td>
                    </tr>
                    <tr>
                        <td valign="middle" style="border-color: rgb(221, 221, 221);" width="150" align="right">编辑页面</td>
                        <td valign="top" style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="3">
                            <input style="width:100%" name="save_page" id="save_page" class="mini-textbox">
                        </td>
                    </tr>
                    <tr>
                        <td valign="middle" style="border-color: rgb(221, 221, 221);" width="150" align="right">详情页面</td>
                        <td valign="top" style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="3">
                            <input style="width:100%" name="info_page" id="info_page" class="mini-textbox">
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div title="查询方案">
            <div class="data-form">
                <table data-sort="sortDisabled" style="width: 80%;margin: auto;">
                    <tbody>
                    <tr class="firstRow">
                        <th align="center" style="border-color: rgb(221, 221, 221);" rowspan="1" colspan="2">查询方案</th>
                    </tr>
                    <tr>
                        <td valign="middle" style="word-break: break-all; border-color: rgb(221, 221, 221);" width="150" align="right">动态表单</td>
                        <td valign="top" style="border-color: rgb(221, 221, 221);" width="375">
                            <input style="width:50%" name="dynForm" id="dynForm" showNullItem="true"
                                   idField="name" valueField="name" textField="name" class="mini-combobox" onvaluechanged="dynFormChanged"
                                   url="<@global.api "form/~latest?paging=false&includes=name,version"/>">
                            版本:<input class="mini-spinner" value="0" name="dynFormVersion"/>(为0时使用发布版)
                            <a href="javascript:viewForm()">预览</a>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <div style="width: 80%;margin: auto;">
                <h1 align="center">查询条件配置</h1>
                <a class="mini-button" iconCls="icon-add" plain="true" onclick="addQueryField()">添加字段</a>
                <span class="formFieldList">
                    <input id="formFieldList" allowInput="true" pinyinField="name" valuefromselect="true"
                           clearonload="true" style="width:200px" name="formFieldList" class="mini-combobox"/>
                </span>
            </div>
            <div id="query_plan_grid" class="mini-datagrid" style="width: 80%;height:30%;margin: auto;"
                 idField="id" allowCellEdit="true" allowCellSelect="true" showPager="false">
                <div property="columns">
                    <div type="indexcolumn"></div>
                    <div field="title" width="60" align="center" headerAlign="center">标题
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="field" width="60" align="center" headerAlign="center">字段
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="type" width="65" align="center" headerAlign="center">关联类型
                        <input property="editor" class="mini-combobox" data="type"/>
                    </div>
                    <div field="queryType" width="60" align="center" headerAlign="center">查询类型
                        <input property="editor" allowInput="true" class="mini-combobox" data="queryType"/>
                    </div>
                <#--<div field="terms" width="100" align="center" headerAlign="center">条件嵌套-->
                <#--<input property="editor" class="mini-buttonedit"/>-->
                <#--</div>-->
                    <div field="customAttr" autoEscape="true" width="100" align="center" headerAlign="center">自定义控件属性(JSON)
                        <input property="editor" onbuttonclick="editJson" class="mini-buttonedit"/>
                    </div>
                    <div field="customHtml" autoEscape="true" width="100" align="center" headerAlign="center">自定义控件(HTML)
                        <input property="editor" onbuttonclick="editHTML" class="mini-buttonedit"/>
                    </div>
                    <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
                </div>
            </div>
            <div style="width: 80%;margin: auto;">
                <h1 align="center">表格配置</h1>
                <a class="mini-button" iconCls="icon-add" plain="true" onclick="addQueryTableField()">添加字段</a>
                <span class="tableFieldList">
                    <input id="tableFieldList" allowInput="true" pinyinField="name" valuefromselect="true"
                           clearonload="true" style="width:200px" name="tableFieldList" class="mini-combobox"/>
                </span>
            </div>
            <div id="query_table_grid" class="mini-datagrid" style="width: 80%;height:50%;margin: auto;"
                 idField="id" allowCellEdit="true" allowCellSelect="true" showPager="false">
                <div property="columns">
                    <div type="indexcolumn"></div>
                    <div field="header" width="60" align="center" headerAlign="center">标题
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="field" width="60" align="center" headerAlign="center">字段
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="displayField" width="60" align="center" headerAlign="center">文本字段
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="width" width="50" align="center" headerAlign="center">宽度
                        <input property="editor" class="mini-textbox" vtype="int"/>
                    </div>
                    <div field="allowSort" dataType="boolean" width="50" align="center" headerAlign="center">可排序
                        <input property="editor" class="mini-combobox" textField="id" data="[{id:true},{id:false}]"/>
                    </div>
                    <div field="visible" width="50" align="center" headerAlign="center">是否显示
                        <input property="editor" class="mini-combobox" textField="id" data="[{id:true},{id:false}]"/>
                    </div>
                    <div field="renderer" width="100" align="center" headerAlign="center">渲染事件
                        <input property="editor" onbuttonclick="editScript" class="mini-buttonedit"/>
                    </div>
                    <div field="properties" width="100" align="center" headerAlign="center">其他属性(JSON)
                        <input property="editor" onbuttonclick="editJson" class="mini-buttonedit"/>
                    </div>
                    <div name="action" width="100" renderer="rendererQueryTableAction" align="center" headerAlign="center">操作</div>
                </div>
            </div>
        </div>
        <div title="页面配置">
            <div style="width: 80%;margin: auto;">
                <h1 align="center">表格操作栏</h1>
                <a class="mini-button" iconCls="icon-add" plain="true" onclick="mini.get('action_grid').addRow({})">添加</a>
            </div>
            <div id="action_grid" class="mini-datagrid" style="width: 80%;height:50%;margin: auto;"
                 idField="id" allowCellEdit="true" allowCellSelect="true" showPager="false">
                <div property="columns">
                    <div type="indexcolumn" align="center" headerAlign="center">#</div>
                    <div field="title" width="60" align="center" headerAlign="center">标题
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="moduleAction" width="60" align="center" headerAlign="center">权限action
                        <input property="editor" class="mini-textbox"/>
                    </div>
                    <div field="icon" width="60" renderer="renderIcon" align="center" headerAlign="center">图标
                        <input property="editor" onbuttonclick="chooseIcon" class="mini-buttonedit"/>
                    </div>
                    <div field="condition" width="60" align="center" headerAlign="center">显示条件(JS)
                        <input property="editor" onbuttonclick="editScript" class="mini-buttonedit"/>
                    </div>
                    <div field="onclick" width="60" align="center" headerAlign="center">事件
                        <input property="editor" onbuttonclick="editScript" class="mini-buttonedit"/>
                    </div>
                    <div name="action" width="100" renderer="rendererActionTableAction" align="center" headerAlign="center">操作</div>
                </div>
            </div>
            <div style="width: 80%;margin: auto;">
                <h1 align="center">js脚本</h1>
                <iframe id="script" style="width: 100%;height: 300px;border: 0px;" src="<@global.api "admin/utils/scriptEditorFrame.html"/>">

                </iframe>
            </div>
        </div>
    </div>
    <div style="height: 10%;text-align: center">
        <a class="mini-button" iconCls="icon-save" plain="true" onclick="save()">保存 </a>
    </div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var module_id = "${param.module_id!''}";
    var id = "${param.id!''}";
    var type = [
        {id: "or", text: "or"}, {id: "and", text: "and"}
    ];
    var queryType = [
        {id: "=", text: "="}
        , {id: "like", text: "like"}
        , {id: "like%", text: "like%"}
        , {id: "%like", text: "%like"}
        , {id: "%like%", text: "%like%"}
        , {id: "in", text: "in"}
        , {id: "not in", text: "not in"}
        , {id: ">=", text: ">="}
        , {id: "<=", text: "<="}
        , {id: "not null", text: "not null"}
        , {id: "is null", text: "is null"}
        , {id: "between", text: "between"}
        , {id: "notbetween", text: "notbetween"}
    ];
    uParse('.data-form', {
        rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
        chartContainerHeight: 500
    });
    var formMetaFieldList = null;
    mini.parse();
    var query_plan_grid = mini.get('query_plan_grid');
    var query_table_grid = mini.get('query_table_grid');
    var action_grid = mini.get('action_grid');
    bindCellBeginButtonEdit(query_plan_grid);
    bindCellBeginButtonEdit(query_table_grid);
    bindCellBeginButtonEdit(action_grid);

    var scriptEl = $('#script')[0];
    var scriptWindow;
    $("#script").on("load",function(){
        scriptWindow = this.contentWindow;
        loadData();
    });
    function editScript(e) {
        var tmp = e.sender.value;
        if (!tmp) {
            tmp = "";
        }
        openScriptEditor("javascript", tmp, function (script) {
            e.sender.setValue(script);
            e.sender.setText(script);
        });
    }

    function editJson(e) {
        var tmp = e.sender.value;
        if (!tmp) {
            tmp = "";
        }
        openScriptEditor("text/json", tmp, function (script) {
            e.sender.setValue(script);
            e.sender.setText(script);
        });
    }

    function editHTML(e) {
        var tmp = e.sender.value;
        if (!tmp) {
            tmp = "";
        }
        openScriptEditor("text/html", tmp, function (script) {
            e.sender.setValue(script);
            e.sender.setText(script);
        });
    }

    function chooseIcon(e) {
        openWindow(Request.BASH_PATH + "admin/utils/get-icon.html", "选择图标", "800", "400", function (icon) {
            if (icon && icon.indexOf("icon-") != -1) {
                e.sender.setValue(icon);
                e.sender.setText(icon);
            }
        });
    }
    function removeQueryPlanRow(id) {
        query_plan_grid.findRow(function (row) {
            if (!row)return;
            if (row.id == id) {
                query_plan_grid.removeRow(row);
                return;
            }
        });
    }

    function viewForm() {
        var name = mini.getbyName("dynForm").getValue();
        var version = mini.getbyName("dynFormVersion").getValue();
        openWindow(Request.BASH_PATH + "/admin/form/view.html?name=" + name + "&version=" + version, "预览表单", "80%", "80%", function (e) {

        })
    }
    function removeQueryTableRow(id) {
        query_table_grid.findRow(function (row) {
            if (!row)return;
            if (row.id == id) {
                query_table_grid.removeRow(row);
                return;
            }
        });
    }

    function rendererActionTableAction(e) {
        var html = "";
        html += "<i class='action-icon icon-arrow-up' style='width: 16px' onclick=\"moveUp(action_grid," + e.record._id + ")\"></i>&nbsp;&nbsp;";
        html += "<i class='action-icon icon-arrow-down' style='width: 16px'  onclick=\"moveDown(action_grid," + e.record._id + ")\"></i>&nbsp;&nbsp;";
        return html + "<i class='action-icon icon-remove' style='width: 16px' onclick=\"removeRow(action_grid," + e.record._id + ")\"></i>";
    }

    function rendererQueryTableAction(e) {
        var html = "";
        html += "<i class='action-icon icon-arrow-up' style='width: 16px' onclick=\"moveUp(query_table_grid," + e.record._id + ")\"></i>&nbsp;&nbsp;";
        html += "<i class='action-icon icon-arrow-down' style='width: 16px'  onclick=\"moveDown(query_table_grid," + e.record._id + ")\"></i>&nbsp;&nbsp;";
        return html + "<i class='action-icon icon-remove' style='width: 16px' onclick=\"removeRow(query_table_grid," + e.record._id + ")\"></i>";
    }

    function rendererAction(e) {
        var html = "";
        html += "<i class='action-icon icon-arrow-up' style='width: 16px' onclick=\"moveUp(query_plan_grid," + e.record._id + ")\"></i>&nbsp;&nbsp;";
        html += "<i class='action-icon icon-arrow-down' style='width: 16px'  onclick=\"moveDown(query_plan_grid," + e.record._id + ")\"></i>&nbsp;&nbsp;";
        return html + "<i class='action-icon icon-remove' style='width: 16px' onclick=\"removeRow(query_plan_grid," + e.record._id + ")\"></i>";
    }

    function addQueryField() {
        if (formMetaFieldList == null) {
            query_plan_grid.addRow({type: 'and', queryType: "=", id: randomChar()});
        } else {
            var selected = mini.get('formFieldList').getValue();
            if (selected != "") {
                var data = [];
                var names = selected.split(',');
                $(formMetaFieldList).each(function (i1, e1) {
                    if (names.indexOf(e1.id) != -1) {
                        data.push({field: e1.id, title: e1.comment, type: 'and', queryType: "=", id: randomChar()});
                    }
                });
                query_plan_grid.addRows(data);
            } else {
                query_plan_grid.addRow({type: 'and', queryType: "=", id: randomChar()});
            }
        }
    }

    function addQueryTableField() {
        if (formMetaFieldList == null) {
            query_table_grid.addRow({width: 100, visible: true, id: randomChar(), align: 'center', headerAlign: 'center'});
        } else {
            var selected = mini.get('tableFieldList').getValue();
            if (selected != "") {
                var data = [];
                var names = selected.split(',');
                $(formMetaFieldList).each(function (i1, e1) {
                    if (names.indexOf(e1.id) != -1) {
                        data.push({field: e1.id, displayField: e1.id, header: e1.comment, width: 100, id: randomChar(), visible: true, align: 'center', headerAlign: 'center'});
                    }
                });
                query_table_grid.addRows(data);
            } else {
                query_table_grid.addRow({width: 100, visible: true, id: randomChar(), align: 'center', headerAlign: 'center'});
            }
        }
    }

    function dynFormChanged(e) {
        if (e&&e.selected&&e.selected.name != "") {
            mini.getbyName("dynFormVersion").setMaxValue(e.selected.version);
            Request.get("form-meta/" + e.selected.name, {}, function (e) {
                if (e.success) {
                    formMetaFieldList = e.data;
                    mini.get('formFieldList').setData(e.data);
                    mini.get('tableFieldList').setData(e.data);
                }
            });
        }
    }

    function randomChar(len) {
        len = len || 8;
        var $chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz';
        var maxPos = $chars.length;
        var pwd = '';
        for (var i = 0; i < len; i++) {
            pwd += $chars.charAt(Math.floor(Math.random() * maxPos));
        }
        return pwd;
    }

    function loadData() {
        if (id != "") {
            Request.get("module-meta/" + id, {}, function (e) {
                if (e.success) {
                    var roleId = e.data.roleId;
                    var data = {key: e.data.key, roleId: roleId, remark: e.data.remark};
                    var meta = mini.decode(e.data.meta);
                    data.save_page = meta.save_page;
                    data.info_page = meta.info_page;
                    data.create_page = meta.create_page;
                    data.table_api = meta.table_api;
                    data.dynForm = meta.dynForm;
                    data.dynFormVersion = meta.dynFormVersion;
                    scriptWindow.initScript("text/javascript", meta.script)
                    mini.getbyName("dynForm").doValueChanged();
                    new mini.Form("#content-body").setData(data);
                    query_plan_grid.setData(meta.queryPlanConfig);
                    query_table_grid.setData(meta.queryTableConfig);
                    if (!meta.actionConfig) {
                        action_grid.setData([
                            {"onclick": "infoData(id);", "icon": "icon-find", "title": "查看", "moduleAction": ""},
                            {"onclick": "editData(id);", "icon": "icon-edit", "title": "编辑", "moduleAction": "U"}
                        ]);
                    } else {
                        action_grid.setData(meta.actionConfig);
                    }
                }
            });
        } else {
            scriptWindow.initScript("text/javascript", "");
            action_grid.setData([
                {"onclick": "infoData(id);", "icon": "icon-find", "title": "查看", "moduleAction": ""},
                {"onclick": "editData(id);", "icon": "icon-edit", "title": "编辑", "moduleAction": "U"}
            ]);
        }
    }
    function save() {
        var api = "module-meta/" + id;
        var func = id == "" ? Request.post : Request.put;
        var form = new mini.Form("#content-body");
        form.validate();
        if (form.isValid() == false) return;
        //提交数据
        var data = form.getData();
        console.log(data);
        var newData = {};
        newData.key = data.key;
        newData.moduleId = newData.key;
        newData.remark = data.remark;
        if (data.roleId != '')data.roleId = "," + data.roleId + ",";
        newData.roleId = data.roleId;
        var meta = {};
        meta.queryPlanConfig = getCleanData(query_plan_grid);
        meta.queryTableConfig = getCleanData(query_table_grid);
        meta.actionConfig = getCleanData(action_grid);
        meta.script=scriptWindow.getScript();
        $(meta.queryTableConfig).each(function (i, e) {
            e.width = parseInt(e.width);
        });
        for (var f in data) {
            meta[f] = data[f];
        }
        newData.meta = mini.encode(meta);
        func(api, newData, function (e) {
            if (e.success) {
                if (id == '') {
                    //新增
                    if (window.history.pushState)
                        window.history.pushState(0, "", '?id=' + e.data);
                    id = e.data;
                    showTips("创建成功!");
                } else {
                    showTips("修改成功!");
                }
            } else {
                showTips(e.message, "danger");
            }
        });
    }

</script>