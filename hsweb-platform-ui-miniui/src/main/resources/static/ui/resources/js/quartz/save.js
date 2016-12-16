var languageData = [{id: "groovy", text: "groovy", name: "groovy"},
    {id: "js", text: "js", name: "javascript"},
    {id: "java", text: "java", name: "java"}];
mini.parse();

uParse('#data-form', {
    rootPath: Request.BASH_PATH + 'ui/plugins/ueditor',
    chartContainerHeight: 500
});
var iframe = $("#scriptArea");
var codeWindow;
var data = {script: ""};
function initScript() {
    iframe.attr("src", Request.BASH_PATH + "admin/ide/editor.html");
    codeWindow = iframe[0].contentWindow;
    iframe.on("load", function () {
        var lang = mini.getbyName("language");
        lang = lang.getSelected()["name"];
        var sc = data.script;
        if(!sc|| sc == "") {
            if(lang=="java"){
                sc="package org.hsweb.quratz.jobs;\n"+
                    "\n"+
                    "import org.hsweb.expands.script.engine.java.Executor;\n\n" +
                    "public class MyJob001 implements Executor{\n"+
                    "\n"+
                    "    @Override\n"+
                    "    public Object execute(Map<String, Object> var) throws Exception {\n"+
                    "        return null;\n"+
                    "    }\n"+
                    "}\n";
            }
        }
        codeWindow.init(lang, sc, true);
    });
}
loadData();
function changeLanguage() {
    var oldCode = codeWindow.getScript();
    data.script = oldCode;
    initScript();
}
function loadData() {
    if (id != "") {
        Request.get("quartz/" + id, {}, function (e) {
            if (e.success) {
                data = e.data;
                new mini.Form('#data-form').setData(e.data);
                initScript();
                initCronExecTime();
            }
        });
    } else {
        initScript();
    }
}

function initCronExecTime() {
    var cron = mini.getbyName("cron").getValue();
    if (cron) {
        Request.get("quartz/cron/exec-times/5", {cron: cron}, function (data) {
            if (data.success) {
                var list = [];
                $(data.data).each(function (i, e) {
                    list.push({id: i, text: e})
                });
                mini.get("execTimeList").setData(list);
                mini.get("execTimeList").setValue(0);
            }
        });
    }
}
function chooseCron(e) {
    openCronEditor(function (cron) {
        e.sender.setValue(cron);
        e.sender.setText(cron);
        initCronExecTime();
    }, e.sender.value ? e.sender.value : "* * * * * ?");
}

function save() {
    var api = "quartz/" + id;
    var func = id == "" ? Request.post : Request.put;
    var form = new mini.Form("#data-form");
    form.validate();
    if (form.isValid() == false) return;
    //提交数据
    var data = form.getData();
    data.script = codeWindow.getScript();
    if (!data.script || !data.script) {
        showTips("脚本不能为空", "danger")
        return;
    }
    var box = mini.loading("提交中...", "");
    func(api, data, function (e) {
        mini.hideMessageBox(box);
        if (e.success) {
            if (id == '') {
                //新增
                if (window.history.pushState)
                    window.history.pushState(0, "", '?id=' + e.data);
                id = e.data;
                showTips("创建成功!");
            } else {
                //update
                showTips("修改成功!");
            }
        } else {
            showTips(e.message, "danger");
        }
    });
}
