<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importFontIcon/>
    <style>
        html, body {
            width: 100%;
            height: 100%;
            border: 0;
            margin: 0;
            padding: 0;
            overflow: hidden;
        }

        .action-edit {
            color: green;
            cursor: pointer;
        }

        .action-remove {
            color: red;
            cursor: pointer;
        }

        .action-enable {
            color: green;
            cursor: pointer;
        }

        .action-icon {
            width: 16px;
            height: 16px;
            display: inline-block;
            background-position: 50% 50%;
            cursor: pointer;
            line-height: 16px;
        }

        .action-span {
            font-size: 16px;
            cursor: pointer;
            display: inline-block;
            line-height: 16px;
        }
    </style>
</head>
<body>
<div class="mini-fit" style="height:100px;">
    <div id="tabs" class="mini-tabs" activeIndex="0" style="width:100%;height:100%;"
         arrowPosition="side" showNavMenu="true">
    </div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    mini.parse();
    var tabs = mini.get('tabs');
    var meta;
    var data, formData;
    var readOnly = false;
    window.setReadOnly = function () {
        readOnly = true;
    }
    window.getData = function () {
        return {};
    }
    window.setData = function (d, fData) {
        formData = fData;
        data = d;
    }
    window.init = function (m) {
        var tabConfig = m.tabConfig;
        if (tabConfig) {
            tabConfig = mini.decode(tabConfig);
            $(tabConfig).each(function (i, e) {
                var tab = {title: e.title, url: initUrl(e.url)};
                tabs.addTab(tab);
                if (i == 0) {
                    tabs.activeTab(tab);
                }
            });
        }
    }
    function initUrl(url) {
        if (formData) {
            for (var f in formData) {
                url = url.replace("{" + f + "}", formData[f]);
            }
            return url.replace(/{.+?}/g,"");
        }
        return url.replace(/{.+?}/g,"");
    }
    window.onblur = function (e) {

    }
</script>
