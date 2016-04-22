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

        .debug {
            color: #00b7ee;
        }

        .error {
            color: red;
        }

        .warn {
            color: red;
        }
    </style>
</head>
<body>
<div id="layout1" class="mini-layout" style="width:100%;height:100%;">
    <div class="header" region="north" height="40" showSplit="false" showHeader="false">
        <span style="font-size: 20px;">hsweb 表单设计器</span>

        <div style="position:absolute;top:10px;right:100px;">
            <a class="mini-button" iconCls="icon-save" onclick="save()" plain="true">保存</a>
            &nbsp;&nbsp;
            <a class="mini-button" onclick="save(preview)" iconCls="icon-find" onclick="deploy()" plain="true">预览</a>
            &nbsp;&nbsp;
            <a class="mini-button" style="color: red" iconCls="icon-goto" onclick="deploy()" plain="true">发布</a>
        </div>
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
            $->INFO: 双击菜单，插入控件。右侧属性表格中编辑属性，按[ctrl+s]可自动保存。
        </div>
    </div>
</body>
</html>
<script type="text/javascript">
    var id = "${param.id!''}";
    function preview(){
        window.open('/admin/form/view.html?id='+id);
    }
</script>
<@global.importRequest />
<@global.importPlugin "form-designer/designer.config.js","form-designer/designer.js"/>