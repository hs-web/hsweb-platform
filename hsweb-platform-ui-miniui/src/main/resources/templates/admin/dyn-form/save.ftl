<@compress single_line=true>
    <#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title></title>
    <@global.importMiniui/>
    <@global.importUeditorParser/>
    <@global.resources "css/form-save.css"/>
</head>
<body>
<div id="formContent">
</div>
<div class="tools" style="margin: 20px auto 30px;width: 400px">
    <a class="mini-menubutton"  iconCls="icon-database-table" plain="true" menu="#DraftMenu">草稿箱</a>
    <a class="mini-button" style="margin-left: 1em" iconCls="icon-reload" plain="true" onclick="window.location.reload()">重新填写</a>
    <a class="mini-button"  style="margin-left: 1em" iconCls="icon-tick" plain="true" onclick="save()">提交</a>
    <a class="mini-button backButton" style="margin-left: 1em" iconCls="icon-undo" plain="true" onclick="window.closeWindow(id)">返回</a>
</div>
<ul id="DraftMenu" class="mini-menu" style="display:none;">
    <li iconCls="icon-save" onclick="saveDraft()">保存为草稿(ctrl+s)</li>
    <li iconCls="icon-find" onclick="mini.get('window').show()" id="draftLi">选择草稿(<span class="draftSize">0</span>)(ctrl+q)</li>
</ul>
<div id="window" showModal="false" style="width: 500px;height: 300px" class="mini-window" title="草稿箱">
    <div id="grid" class="mini-datagrid" onrowdblclick="chooseDraft()" style="width:100%;height:100%;" idField="id" showPager="false">
        <div property="columns">
            <div type="indexcolumn"></div>
            <div field="name" width="120" align="center" headerAlign="center" allowSort="true">名称</div>
            <div field="createDate" width="100" align="center" headerAlign="center" dateFormat="yyyy-MM-dd HH:mm:ss" allowSort="true">创建日期</div>
            <div name="action" width="100" renderer="rendererAction" align="center" headerAlign="center">操作</div>
        </div>
    </div>
</div>
</body>
</html>
    <@global.importRequest/>
<script type="text/javascript">
    var formName = "${name!param.name!''}";
    var id = "${id!param.id!''}";
    var version = "${version!'0'}";
</script>
    <@global.importPlugin  "localstore/store.min.js"
    ,"form-designer/form.parser.fast.js"
    ,"mousetrap/mousetrap.min.js"/>
    <@global.resources "js/form-save.js"/>
</@compress>