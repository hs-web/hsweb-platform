<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
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
    <table style="width:100%;">
        <tr>
            <td style="width:100%;">
                <a class="mini-button" iconCls="icon-add" plain="true" onclick="create()">添加字段</a>
                <span class="separator"></span>
                <input class="mini-combobox" allowInput="true" textField="name" showNullItem="true"
                       value="${param.plan_id!''}" name="plan" style="width: 250px;" onvaluechanged="changPlan"
                       url="<@global.api "query-plan/type/"+(param.name!'')/>"/>
                <a class="mini-button" iconCls="icon-save" plain="true" onclick="savePlan()">保存方案</a>
                <span class="separator"></span>
                <a class='mini-button' iconCls='icon-search' plain='true' onclick='search()'>查询</a>
            </td>
        </tr>
    </table>
    <div style="margin: auto;max-width: 1000px" id="searchForm">
    </div>
</div>
<div class="mini-fit">
    <div id="datagrid" class="mini-treegrid" style="width:100%;height:100%;" showTreeIcon="true"
         treeColumn="field" idField="id" parentField="parentId" resultAsTree="false"
         allowResize="false" expandOnLoad="true" allowCellEdit="true" allowCellSelect="true">
        <div property="columns">
            <div name="field" field="field" width="120" align="left" headerAlign="center" renderer="renderField">字段
                <input property="editor" class="mini-combobox" pinyinField="text" textField="comment" data="form_meta" allowInput="true" style="width:100%;"/>
            </div>
            <div field="type" width="80" renderer="renderType" align="center" headerAlign="center"> 类型
                <input property="editor" class="mini-combobox" data="type_data" style="width:100%;"/>
            </div>
            <div field="termType" width="80" align="center" headerAlign="center" renderer="renderTermType">方案
                <input property="editor" class="mini-combobox" allowInput="true" data="termType_data" style="width:100%;"/>
            </div>
            <div field="value" width="220" align="center" headerAlign="center">值
                <input property="editor" class="mini-textbox" style="width:100%;"/>
            </div>
            <div name="action" width="80" align="center" headerAlign="center" renderer="renderAction">操作</div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var type_data = [{id: "and", text: "并且"}, {id: "or", text: "或者"}];
    var termType_data = [{id: "eq", text: "等于"}, {id: "like", text: "模糊匹配"}
        , {id: "gt", text: "大于"}, {id: "lt", text: "小于"}
        , {id: "gte", text: "大于等于"}, {id: "lte", text: "小于等于"}
        , {id: "in", text: "在…之中", title: "值在提供的选项中,以逗号分割"}, {id: "nin", text: "不在…之中"}];
    var tableMeta = "${param.name!''}";
    var form_meta = tableMeta == '' ? [] : Request.get("form-meta/" + tableMeta).data;

    var form_meta_map = {};
    $(form_meta).each(function () {
        form_meta_map[this.id] = this;
    });

    function renderField(e) {
        var v = form_meta_map[e.value];
        if (v) {
            return v.comment;
        }else{
            return e.value;
        }
    }

    function renderAction(e) {
        var row = e.record;
        var html = createActionButton("嵌套字段", "addParent(" + row._uid + ")", "icon-add");
        html += createActionButton("删除字段", "removeNode(" + row._uid + ")", "icon-remove");
        return html;
    }

    function removeNode(id) {
        grid.removeNode(grid.getRowByUID(id));
    }
    function renderType(e) {
        for (var i = 0; i < type_data.length; i++) {
            if (type_data[i].id == e.value)return "<span title='" + (type_data[i].title ? type_data[i].title : type_data[i].text) + "'>" + type_data[i].text + "</span>";
        }
        return "";
    }
    function renderTermType(e) {
        for (var i = 0; i < termType_data.length; i++) {
            if (termType_data[i].id == e.value)return "<span title='" + (termType_data[i].title ? termType_data[i].title : termType_data[i].text) + "'>" + termType_data[i].text + "</span>";
        }
        return e.value;
    }

    mini.parse();
    var grid = mini.get('datagrid');
    function search() {
        if (window.onsearch) {
            window.onsearch(parseTerms());
        }
    }
    function changPlan(e) {
        var node = e.selected;
        if (node) {
            grid.setData(mini.decode(node.config));
        } else {
            grid.setData([]);
        }
    }
    function savePlan() {
        var nowSelectPlan = mini.getbyName("plan").getValue();
        if (nowSelectPlan == "" || nowSelectPlan == mini.getbyName("plan").getText()) {
            nowSelectPlan = mini.getbyName("plan").getText();
            if (nowSelectPlan == "") {
                showTab("请填写方案名称!");
                mini.getbyName("plan").focus();
                return;
            }
            var data = getCleanData(grid);
            var plan = {name: nowSelectPlan, type: tableMeta, config: data};
            Request.post("query-plan", plan, function (e) {
                if (e.success) {
                    showTips("保存成功");
                    mini.getbyName("plan").load(mini.getbyName("plan").getUrl());
                } else {
                    mini.alert(e.message);
                }
            });
        } else {
            var plan = {name: mini.getbyName("plan").getText(), type: tableMeta, config: getCleanData(grid)};
            Request.put("query-plan/" + nowSelectPlan, plan, function (e) {
                if (e.success) {
                    showTips("保存成功");
                    mini.getbyName("plan").load(mini.getbyName("plan").getUrl());
                } else {
                    mini.alert(e.message);
                }
            });
        }
    }
    function create() {
        var row = {parentId: "-1", type: "and"};
        grid.addNode(row, 0);
    }

    function addParent(id) {
        var row = grid.getRowByUID(id);
        if (row) {
            grid.addNode({parentId: row.parentId, type: "and"}, 0, row);
        }
    }
    function parseTerms() {
        var terms = {};
        var data = mini.clone(getCleanData(grid));

        function parseParam(prefix, index, term) {
            if (!term.children || term.children.length == 0) {
                terms[prefix + "[" + index + "]" + ".column"] = term.field;
                terms[prefix + "[" + index + "]" + ".value"] = term.value;
                terms[prefix + "[" + index + "]" + ".type"] = term.type;
                terms[prefix + "[" + index + "]" + ".termType"] = term.termType;
            } else {
                //terms[prefix + "[" + (index ) + "]" + ".field"] = "";
                //terms[prefix + "[" + (index ) + "]" + ".value"] = "";
                terms[prefix + "[" + (index ) + "]" + ".type"] = term.type;
                terms[prefix + "[" + (index ) + "]" + ".termType"] = term.termType;

                terms[prefix + "[" + index + "].terms[0]" + ".column"] = term.field;
                terms[prefix + "[" + index + "].terms[0]" + ".value"] = term.value;
                terms[prefix + "[" + index + "].terms[0]" + ".type"] = term.type;
                terms[prefix + "[" + index + "].terms[0]" + ".termType"] = term.termType;
                $(term.children).each(function (i, e) {
                    parseParam(prefix + "[" + (index) + "].terms", i + 1, e);
                });
            }
        }

        $(data).each(function (i, e) {
            parseParam("terms", i, e);
        });
        return terms;
    }

</script>