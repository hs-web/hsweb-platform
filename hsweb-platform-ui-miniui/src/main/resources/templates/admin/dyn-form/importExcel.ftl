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
<div class="mini-toolbar">
    重复数据处理方式:<input class="mini-combobox" style="width: 125px" value="SKIP" name="mode" data="repeatMode">
    <a class="mini-button" iconCls="icon-download" onclick="downloadTemplate()" plain="true">下载此模板</a>
    <a class="mini-button" iconCls="icon-upload" onclick="importData" plain="true" style="color: red;">导入数据</a>
    <br/>已保存方案:<input name="draft" onvaluechanged="changePlan" showClose="true" oncloseclick="removeDraft"
                      showNullItem="true" textField="name" class="mini-combobox" style="width: 160px" allowInput="true"/>
    <a class="mini-button" iconCls="icon-save" onclick="savePlan()" plain="true">保存</a>
    <a class="mini-button" iconCls="icon-undo" onclick="closeWindow()" plain="true">关闭</a>
</div>
<div class="mini-fit">
    <div id="field-list" idField="name" class="mini-datagrid" style="width:100%;height:100%;" allowCellEdit="true" allowCellSelect="true" showPager="false">
        <div property="columns">
            <div name="text" field="text" width="60" align="center" headerAlign="center">表头
                <input property="editor" class="mini-textbox"/>
            </div>
            <div name="validator" renderer="renderComment" field="validator" width="60" align="center" headerAlign="center">说明</div>
        </div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var forName = "${param.name!''}";
    var repeatMode = [
        {id: "SKIP", text: "跳过"},
        {id: "REPLACE", text: "覆盖"},
        {id: "THROWABLE", text: "报错"}
    ];
    mini.parse();
    var field_list = mini.get('field-list');
    var defaultData=[];
    initField();
    function downloadTemplate() {
        var data = field_list.getData();
        var header = [];
        $(data).each(function () {
            header.push({title: this.text, field: this.name});
        });
        downloadExcel(mini.encode(header), "[]", forName)
    }
    function initField() {
        Request.get("dyn-form/excel/imports/" + forName, function (e) {
            if (e.success) {
                field_list.setData(e.data);
                defaultData =mini.clone(e.data);
            }
        });
    }
    loadDraft();
    function loadDraft() {
        Request.get("draft/import-" + forName, function (e) {
            if (e.success) {
                mini.getbyName("draft").setData(e.data);
            }
        });
    }
    function changePlan(e) {
        if (e.selected && e.selected.value) {
            field_list.setData(e.selected.value);
        } else {
            field_list.setData(defaultData);
        }
        field_list.selectAll();
    }
    function savePlan() {
        var data = field_list.getData();
        mini.prompt("请输入方案名称：", "请输入",
                function (action, value) {
                    if (action == "ok") {
                        Request.post("draft/import-" + forName, {value: data, name: value}, function (e) {
                            loadDraft();
                            if (e.success) {
                                mini.getbyName("draft").setValue(e.data);
                                showTips("方案已保存.");
                            }
                        });
                    }
                }
        );
    }
    function removeDraft() {
        var id = mini.getbyName("draft").getValue();
        if (id) {
            mini.confirm("确认删除此方案?", "请确认", function (action) {
                if (action == 'ok') {
                    Request['delete']("draft/import-" + forName + "/" + id, function (e) {
                        if (e.success) {
                            showTips("方案已删除.");
                        }
                        loadDraft();
                    });
                }
            });
        }
    }
    function importData() {
        openFileUploader("excel", "导入excel数据", function (e) {
            field_list.loading("上传数据中...");
            var ids = [];
            var mapData = {};
            $(e).each(function (i, e) {
                ids.push(e.id);
                mapData[e.id] = e;
            });
            var config = {};
            var mapper = {};
            var mapper__ = field_list.getData();
            $(mapper__).each(function () {
                mapper[this.text] = this.name;
            });
            config.files = ids;
            config.mapper = mapper;
            config.mode = mini.getbyName("mode").getValue();
            Request.patch("dyn-form/import/" + forName, config, function (e1) {
                field_list.unmask();
                if (e1.success) {
                    showUploadMessage(mapData, e1.data);
                } else {
                    mini.alert("导入失败,请确定上传的excel格式正确！");
                }
            });
        })
    }

    function showUploadMessage(files, result) {
        var html = "";
        for (var fileId in result) {
            var file = files[fileId];
            html += "文件" + file.name + ":<br/>";
            var res = result[fileId];
            if (res.success) {
                html += "新增:" + res.data.insert + "条<br/>";
                html += "更新:" + res.data.update + "条<br/>";
                html += "跳过:" + res.data.skip + "条<br/>";
                if (res.data.errors) {
                    var index = 0;
                    for (var x in res.data.errors) {
                        if (index++ < 5)
                            html += "第" + x + "行:" + res.data.errors[x][0].message + "<br/>";
                        else {
                            html += ".....<br/>";
                            break;
                        }
                    }
                }
            } else {
                html += "失败:" + res.message;
            }
        }
        mini.alert(html);
    }

    function renderComment(e) {
        var v = e.value;
        var row = e.record;
        var html = [];
        if (v) {
            $(v).each(function () {
                if (this.indexOf("NotNull") != 0
                        || this.indexOf("NotEmpty") != 0
                        || this.indexOf("NotBlank") != 0) {
                    if (html.indexOf("不能为空") == -1)
                        html.push("不能为空");
                }
            });
        }
        if (row.needAudit) {
            html.push("修改后需要审核");
        }
        return html + "";
    }
</script>
