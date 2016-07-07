/**
 * Created by zhouhao on 16-5-6.
 */
var nowEditorNode;
var defaultGridData=[
    { id: "M", text: "菜单可见",checked:true}
    ,{ id: "R", text: "查询",checked:true}
    ,{ id: "C", text: "新增",checked:true}
    ,{ id: "U", text: "修改",checked:true}
    ,{ id: "D", text: "删除",checked:false}
];
mini.parse();
var grid = mini.get("m_option_table");
var tree = mini.get("leftTree");
grid.setData(defaultGridData);
if (nowEditorId != "") {
    tree.selectNode({id: nowEditorId});
}
function newModule() {
    var node = tree.getSelectedNode();
    if (!node) {
        var newNode = {id: "", name: "新建权限", parentId: "-1", sortIndex: 0};
        tree.addNode(newNode, "add");
        tree.selectNode(newNode);
    } else {
        var childSize = tree.getChildNodes(node).length;
        var newNode = {id: "", name: "新建权限", parentId: node.id, sortIndex: node.sortIndex + "0" + (childSize + 1)};
        tree.addNode(newNode, "add", node);
        tree.selectNode(newNode);
    }
    grid.setData(defaultGridData);
}
function drawnode(e) {
    e.nodeHtml =  e.node.name + "(" + e.node.id + ")" + "</i> &nbsp;";
}
function nodeselect(e) {
    if (!e.node) {
        try{
            window.history.pushState(0, 0, "?editId=");
        }catch(e){}

        return;
    }
    nowEditorId = e.node.id;
    nowEditorNode = e.node;
    new mini.Form("#formContainer").setData(e.node);
    mini.get("m_option_table").setData(mini.decode(e.node.optional));
    $("#tableTitle").html(e.node.name);
    if (nowEditorId != "") {
        mini.get("id").setEnabled(false);
    } else {
        mini.get("id").setEnabled(true);
    }
    if (window.history.pushState)
    window.history.pushState(0, 0, "?editId=" + nowEditorId);
}
function save() {
    var form = new mini.Form("#formContainer");
    form.validate();
    if (!form.isValid())return;
    var m_option = mini.get("m_option_table").getData();
    var new_m_option = [];
    $(m_option).each(function (i, e) {
        new_m_option.push({id: e.id, text: e.text, checked: e.checked});
    });
    var data = form.getData();
    data.optional = mini.encode(new_m_option);
    var func = nowEditorId == "" ? Request.post : Request.put;
    var box = mini.loading("提交中...", "");
    func("module/" + nowEditorId, data, function (e) {
        mini.hideMessageBox(box);
        if (e.success) {
            if (nowEditorId == "")nowEditorId = e.data;
            mini.get("leftTree").updateNode(nowEditorNode, data);
            tree.selectNode(data);
            showTips("保存成功");
        } else {
            mini.alert(e.message);
        }
    });
}
function remove() {
    if (nowEditorId == ""){
        tree.removeNode(nowEditorNode);return;
    }
    if (nowEditorId != "")
        mini.confirm("确定删除权限，删除后无法恢复？", "确定？",
            function (action) {
                if (action == "ok") {
                    Request['delete']("module/" + nowEditorId, {}, function (e) {
                        if (e.success) {
                            showTips("删除成功!");
                            tree.removeNode(nowEditorNode);
                        }
                        else mini.alert(e.data);
                    });
                }
            }
        );
}
function saveAll() {
    var dataList = tree.getList();
    var valideSus = true;
    $(dataList).each(function (i, e) {
        if ("" == e.id) {
            valideSus = false;
            tree.selectNode(e);
            showTips("请先完成编辑!", "danger");
            return;
        }
    });
    if (valideSus)
        Request.put("module", dataList, function (e) {
            if (e.success) {
                showTips("保存成功!");
                tree.reload();
            } else {
                mini.alert(e.data);
            }
        })
}

function onBeforeOpen(e) {
    var menu = e.sender;
    var node = tree.getSelectedNode();
    if (!node) {
        e.cancel = true;
        return;
    }
}
function ondrop(e) {
    var dragNode = e.dragNode;
    var dropNode = e.dropNode;
    var dragAction = e.dragAction;
    var index = dragNode.sortIndex;
    var pNode;
    if ("before" == dragAction || "after" == dragAction) {
        dropNode.sortIndex = dragNode.sortIndex;
        pNode = tree.getParentNode(dragNode);
    }
    if ("add" == dragAction) {
        pNode = dropNode;
    }
    reSortModule(pNode);
    tree.selectNode(dragNode);
}
function reSortModule(node) {
    var childNodes = tree.getChildNodes(node);
    $(childNodes).each(function (i, e) {
        var index = parseInt(node.sortIndex);
        if (isNaN(index)) e.sortIndex=i+1;
        else
            e.sortIndex = index + "0" + (i + 1);
        reSortModule(e);
    });
}
function showHelp() {
    mini.alert("左侧菜单支持右键，支持拖拽排序。<br/>编辑后，注意点击保存!");
}