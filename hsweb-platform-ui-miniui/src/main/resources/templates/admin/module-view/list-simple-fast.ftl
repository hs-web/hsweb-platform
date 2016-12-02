<#import "../../global.ftl" as global />
<@compress single_line=true>
<!DOCTYPE html>
<html lang="zh-cn">
<head>
    <meta charset="UTF-8">
    <title></title>
    <@global.importMiniui />
    <@global.importUeditorParser/>
    <@global.importFontIcon/>
    <@global.resources "css/toolbaroverflow.css" ,"js/toolbaroverflow.js"/>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }

        .searchForm .title {
            min-width: 100px;
            text-align: right;
        }

        .searchForm .html {
            width: 200px;
            text-align: left;
        }

        .searchForm td {
            height: 30px;;
        }
    </style>
</head>
<body>
<div class="mini-toolbar" style="width: 100%">
    <div id="toolbar">
    </div>
    <div style="margin: auto;max-width: 1000px;z-index: 999999999" id="searchForm">
    </div>
</div>
<div class="mini-fit">
    <div id="grid" class="mini-datagrid" style="width:100%;height:100%;" ajaxOptions="{type:'GET',dataType:'json'}" idField="id"
         sizeList="[10,20,50,200]" pageSize="20">
    </div>
</div>
</body>
</html>
    <@global.importRequest/>
    <@global.importPlugin "localstore/store.min.js"/>
    <@global.importPlugin "module-meta/list-page-parser.js"/>
<script type="text/javascript">
    var key = "${key!param.key!''}";
    var config = {
        enableSearch: false,
        getToolBar: function (old) {
            var nBar = [];
            $(old).each(function () {
                if (this.action == "C") {
                    nBar.push(this);
                }
            });
            return nBar;
        }
    };
    var parser = new ListPageParser(key, config);
    window.onInit = function (data, formData, script) {
        if (window.resizeWindow) {
            window.resizeWindow(300);
        }
        if (script) {
            var script = "(function(){return function(data,formData,parser){" + script + "}})()";
            script = eval(script);
            script(data, formData, parser);
        }
        parser.init();
    };
    $(function () {
        if (window.parent == window.top)
            parser.init();
    });
</script>
</@compress>