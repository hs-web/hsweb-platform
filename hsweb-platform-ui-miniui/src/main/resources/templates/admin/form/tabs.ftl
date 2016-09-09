<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
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
    var tabs, meta, data, formData;
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
        mini.parse();
        tabs = mini.get('tabs');
        var tabConfig = m.tabConfig;
        if (tabConfig) {
            tabConfig = mini.decode(tabConfig);
            var showIndex = 0;
            $(tabConfig).each(function (i, e) {
                var show = true;
                if (e.condition) {
                    var script = "window.___showCondition_" + i + "=function(data,formData){" + e.condition + "}";
                    try {
                        eval(script);
                        show = window["___showCondition_" + i](data, formData);
                    } catch (e) {
                        if (console.log) {
                            console.log(e);
                        }
                    }
                    if (!show)return;
                }
                var scriptText = e.scriptText;
                var tab = {
                    title: e.title, url: initUrl(e.url), onload: function (e) {
                        var iframe = e.iframe;
                        if (iframe) {
                            var win = iframe.contentWindow;

                            function doInit() {
                                if (win) {
                                    if (win.onInit) {
                                        win.onInit(data, formData, scriptText);
                                    }
                                    if (readOnly && win.setReadOnly) {
                                        win.setReadOnly();
                                    }
                                }
                            }

                            $(iframe).on("load", function () {
                                doInit();
                            });
                            doInit();
                        }
                    }
                };
                tabs.addTab(tab);
                if (showIndex == 0) {
                    tabs.activeTab(tab);
                }
                showIndex++;
            });
            if (showIndex == 0) {
                if (window.hide) {
                    window.hide();
                }
            }
        }
    }
    function initUrl(url) {
        if (url.indexOf("http") != 0) {
            url = Request.BASH_PATH + url;
        }
        var r = /\{(.+?)}/g;
        var matches = url.match(r);
        $(matches).each(function () {
            var group = this.substring(1, this.length - 1);
            var val = eval("(function(){return formData." + group + "})()");
            url = url.replace("{" + group + "}", val?val:"");
        });
        return url;
    }
</script>
