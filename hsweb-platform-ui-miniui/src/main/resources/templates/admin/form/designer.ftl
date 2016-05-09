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
            overflow-x: auto;
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
<div id="layout1" class="mini-layout" style="width:100%;height:100%;min-width: 800px;border: 0px;">
    <div class="header" region="north" height="40" showSplit="false" showHeader="false">
        <div id="toolbar1" class="mini-toolbar" style="padding:2px;">
            <table style="width:100%;">
                <tr>
                    <td style="width:100%;">
                        <a class="mini-menubutton" plain="true" menu="#popupMenu">文件</a>
                        <a class="mini-button" iconCls="icon-save" onclick="save()" plain="true">保存</a>
                        <a class="mini-button" iconCls="icon-find" onclick="save(preview)" plain="true">预览</a>
                        <a class="mini-button" iconCls="icon-goto" style="color: red" onclick="deploy()" plain="true">发布</a>
                        <a class="mini-button" iconCls="icon-bullet-cross" style="color: red" onclick="closeWindow('exit')" plain="true">退出</a>
                        <span class="separator"></span>
                        <a class="mini-button" iconCls="icon-reload" plain="true" onclick="window.location.reload()">刷新</a>
                        <a class="mini-button" iconCls="icon-upload" plain="true">导入</a>
                        <a class="mini-button" iconCls="icon-download" plain="true">下载</a>
                    </td>
                    <td style="white-space:nowrap;">
                    </td>
                </tr>
            </table>
        </div>
        <ul id="popupMenu" class="mini-menu" style="display:none;">
            <li>
                <span>操作</span>
                <ul>
                    <li iconCls="icon-new">新建表单</li>
                    <li class="separator"></li>
                    <li iconCls="icon-add">创建新版本</li>
                </ul>
            </li>
            <li class="separator"></li>
            <li iconCls="icon-open">打开</li>
        </ul>
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
        <div id="editorWindow" class="mini-window" title="" style="width:600px;height:500px;"
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
    function preview() {
        // window.open('/admin/form/view.html?id='+id);
        openWindow('/admin/form/view.html?id=' + id, "预览表单", "80%", "80%");
    }


</script>
<@global.importRequest />
<@global.importPlugin "form-designer/designer.config.js","form-designer/designer.js"/>