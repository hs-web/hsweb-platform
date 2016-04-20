<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui "bootstrap"/>
<@global.importPlugin "ueditor/themes/default/css/ueditor.min.css"/>
    <script type="text/javascript" charset="utf-8">
        window.UEDITOR_HOME_URL = location.protocol + '//' + document.domain + (location.port ? (":" + location.port) : "") + "/ui/plugins/ueditor/";
    </script>
<@global.importPlugin "form-designer/ueditor.config.js"
,"ueditor/ueditor.all.min.js"
, "ueditor/lang/zh-cn/zh-cn.js"
/>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }

        .logger {
            background: black;
            color: white;
            height: 100%;
        }
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div class="header" region="north" height="40" showSplit="false" showHeader="false">
        <span style="font-size: 20px;">hsweb 表单设计器</span>
    </div>
    <div title="south" region="east" showSplit="true" showHeader="false" width="200" bodyStyle="border:0px;">
        <div class="mini-fit" style="height:100px;">
            <div id="properties-table" class="mini-datagrid" style="width:100%;height: 100%;border: 0px"
                 idField="key" allowCellEdit="true" showPager="false" onCelldblclick="showEditor"
                 allowCellSelect="true" allowAlternating="true" editNextOnEnterKey="true"
                 editNextRowCell="true" oncellendedit="submitProperties" oncellbeginedit="cellbeginedit">
                <div property="columns">
                    <div field="describe" width="50" headerAlign="center" allowSort="false">属性</div>
                    <div field="value" width="80" headerAlign="center" allowSort="false">值
                        <input property="editor" class="mini-textbox"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div showHeader="false" region="west" width="180" maxWidth="250" minWidth="100">
        <div id="leftTree" class="mini-tree" url="<@global.pluginUrl "form-designer/menu.json" />"
             onnodedblclick="nodedblclick" idField="id" resultAsTree="false"
             parentField="pid" textField="text" borderStyle="border:0"
             expandOnNodeClick="true" expandOnLoad="0">
        </div>
    </div>
    <div title="center" region="center" bodyStyle="overflow-y:auto;overflow-x:hidden;">
        <script id="container" name="content" type="text/plain" style="align:center;width: 100%;height:80%;border: 0px;">
        </script>
        <div id="editorWindow" class="mini-window" title="" style="width:500px;height:300px;"
             showMaxButton="false" showCollapseButton="false" showShadow="true"
             showToolbar="false" showFooter="true" showModal="true" allowResize="true" allowDrag="true">
            <div id="editorWindowFrame" class="mini-fit" style="height:100px;align:center;">

            </div>
            <div property="footer" style="text-align:right;padding:5px;padding-right:15px;">
                <input type='button' value='保存' onclick="Designer.saveEditor()" style='vertical-align:middle;'/>
            </div>
        </div>
    </div>
    <div showHeader="false" region="south" height="100px" bodyStyle="overflow-y:auto;overflow-x:hidden;">
        <div class="mini-fit logger" style="height:100px;">
            $->info: 双击菜单，插入控件。右侧属性表格中编辑属性
        </div>
    </div>
</body>
</html>
<@global.importPlugin "form-designer/designer.config.js"/>
<script type="text/javascript">
    var fieldData = {};
    mini.parse();
    var ue = UE.getEditor('container');
    var propertiesTable = mini.get('properties-table');
    var nowEditorTarget = "main";

    fieldData.main = Designer.fields.main.getDefaultProperties();

    initProperties();

    ue.addListener('focus', function () {
        propertiesTable.commitEdit();
    });
    ue.addListener('selectionchange', function () {
        var focusNode = ue.selection.getStart();
        var id = $(focusNode).attr("field-id");
        if (id) {
            nowEditorTarget = id;
        } else {
            nowEditorTarget = "main";
        }
        initProperties();
    });

    function showEditor(e) {
        var row = e.record;
        var data = list2Map(propertiesTable.getData());
        var conf = Designer.fields[data._meta];
        if (conf) {
            var editor = conf.getPropertiesEditor()[row.key];
            if (editor) {
                editor(data, function (e) {
                    $(fieldData[nowEditorTarget]).each(function (index, d) {
                        if (d.key == row.key) {
                            d.value = e;
                        }
                    });
                    initProperties();
                });
                e.cancel = true;
            }
        }
    }

    function list2Map(list) {
        var map = {};
        $(list).each(function (index, o) {
            map[o.key] = o.value;
        });
        return map;
    }
    function cellbeginedit(e) {
        var row = e.record;
        if (row.key == '_meta') {
            var conf = Designer.fields[row.value];
            if (!conf.propertiesEditable(row.key)) {
                e.cancel = true;
            }
        }
        showEditor(e);
    }
    function submitProperties(e) {
        fieldData[nowEditorTarget] = propertiesTable.getData();
    }
    function initProperties() {
        propertiesTable.setData(fieldData[nowEditorTarget]);
    }
    function insert(id) {
        var conf = Designer.fields[id];
        var f_id = randomChar();
        if (conf) {
            ue.execCommand('insertHtml', conf.html(f_id))
            nowEditorTarget = f_id;
            fieldData[nowEditorTarget] = conf.getDefaultProperties();
            initProperties();
        }
    }

    function nodedblclick(e) {
        var node = e.node;
        insert(node.id);
    }

    function randomChar(len) {
        len = len || 32;
        var $chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz';
        var maxPos = $chars.length;
        var pwd = '';
        for (var i = 0; i < len; i++) {
            pwd += $chars.charAt(Math.floor(Math.random() * maxPos));
        }
        return pwd;
    }

    var logger = {
        append: function (level, msg) {
            $(".logger").append("<br/>$->" + level + ": " + msg);
            $(".logger").scrollTop($(".logger").scrollTop() + 100);//= document.getElementById(id).scrollTop+99999999;
        }
        , info: function (msg) {
            logger.append("info", "<span class='info'>" + msg + "</span>");
        }, debug: function (msg) {
            logger.append("debug", "<span class='debug'>" + msg + "</span>");
        }, error: function (msg) {
            logger.append("error", "<span class='error'>" + msg + "</span>");
        }
    };
</script>
