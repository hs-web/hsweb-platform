<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
    <style>
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 100%;
        }
    </style>
</head>
<body>
<div class="mini-fit" style="width: 100%;">
    <br/>

    <div style="width: 80%;margin: auto">
        <a class="mini-button" iconCls="icon-ok" plain="true" onclick="ok()">完成编辑</a>
        <a class="mini-button" iconCls="icon-remove" plain="true" onclick="closeWindow('cancel')">取消</a>
        <br/>
        <iframe id="editor" src="../ide/editor.html" style="border: 1px solid grey;width: 100%;height: 500px">

        </iframe>
    </div>
</div>
</body>
</html>
<script type="text/javascript">

    function init(mode, data, isServer) {
        if (mode.indexOf("javascript") != -1 || mode.indexOf("js") != -1) {
            mode = "javascript";
        } else if (mode.indexOf("groovy") != -1) {
            mode = "groovy";
            isServer=true;
        } else if (mode.indexOf("java") != -1) {
            mode = "java";
            isServer=true;
        }else if (mode.indexOf("json") != -1) {
            mode = "json";
            isServer=false;
        }else if (mode.indexOf("html") != -1) {
            mode = "html";
            isServer=false;
        }else if (mode.indexOf("css") != -1) {
            mode = "css";
            isServer=false;
        }
        var editor = document.getElementById("editor");
        $(editor).on("load", function () {
            var win = editor.contentWindow;
            if (win.init) {
                win.init(mode, data, isServer);
                window.ok = function () {
                    var script = win.getScript();
                    closeWindow(script);
                }
            }
        });
    }
    window.init = init;
</script>