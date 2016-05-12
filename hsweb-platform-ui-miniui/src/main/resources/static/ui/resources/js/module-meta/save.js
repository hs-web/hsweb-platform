/**
 * Created by zhouhao on 16-5-7.
 */
uParse('#data-form', {
    rootPath: '<@global.basePath />ui/plugins/ueditor',
    chartContainerHeight: 500
});
mini.parse();
var tree = mini.get('funcTree');

var module_data = [];
loadData();
function loadData() {
    Request.get("module", {paging:false,sortField:"sort_index"}, function (e) {
        module_data = e;
        tree.loadList(e);
        if (id != "") {
            Request.get("role/" + id, {}, function (e) {
                if (e.success) {
                    e.data.password = "$default";
                    setTimeout(function(){setCheckedActions(e.data.modules)},10);
                    new mini.Form('#data-form').setData(e.data);
                    mini.get('u_id').setEnabled(false);
                }
            });
        }
    });
}
var showAllSelect = true;

function ondrawcell(e) {
    var tree = e.sender,
        record = e.record,
        column = e.column,
        field = e.field,
        id = record[tree.getIdField()],
        funs = mini.decode(record.m_option);

    function createCheckboxs(funs) {
        if (!funs || funs.length == 0) return "";
        var html = "<button style='border:solid 1px #aaa;' onclick=\"allClick(this,'" + record.u_id + "')\" class='module-span'>全选</button>&nbsp;&nbsp;<span>";
        $(funs).each(function (i, e) {
            var id = "module-" + record.u_id + "-" + e.id;
            html += "<span class='module-span' >" +
                "<input m-id='" + record.u_id + "' value='" + e.id + "' " + (e.checked == true ? 'checked' : '') + " id='" + id + "'   class='module-action action-" + record.u_id + "' type='checkbox' />" +
                "<span onclick=\"chooseAction(this,'" + id + "')\">" + (e.text||'') + "(" + e.id + ")</span>" +
                "</span>";
        });
        html += "</span>";
        return html;
    }

    if (field == 'm_option') {
        e.cellHtml = createCheckboxs(funs);
    }
}

function allClick(e, uid) {
    if (e.innerHTML == "全选") {
        $('.action-' + uid).prop("checked", "checked");
        e.innerHTML = '反选'
    } else {
        $($(e).next().children()).each(function (i, e) {
            var checkbox = $(e).children();
            $(checkbox).prop("checked", $(checkbox).prop('checked') ? false : 'checked');
        });
        e.innerHTML = '全选'
    }
}

function chooseAction(e, id) {
    $("#" + id).prop("checked", $("#" + id).prop('checked') ? false : 'checked');
}

function setCheckedActions(actions) {
    $('.module-action').prop("checked", false);
    var actionsMap = {};
    $(actions).each(function (i, e) {
        actionsMap[e.module_id] = e.actions;
    });
    $('.module-action').each(function (i, e) {
        var moduleId = $(e).attr("m-id");
        var action = $(e).val();
        if (!actionsMap[moduleId])return;
        if (actionsMap[moduleId].indexOf(action) != -1) {
            $(e).prop("checked", "checked");
        }

    });
}

function getCheckedActions() {
    var actions = {};
    $('.module-action').each(function (i, e) {
        var moduleId = $(e).attr("m-id");
        var action = $(e).val();
        if ($(e).prop("checked")) {
            var action_mapping = actions[moduleId];
            if (!action_mapping) {
                action_mapping = [];
                actions[moduleId] = action_mapping;
            }
            action_mapping.push(action);
        }
    });
    var newData = [];
    for (var f in actions) {
        newData.push({module_id: f, o_level: mini.encode(actions[f])});
    }
    return newData;
}

