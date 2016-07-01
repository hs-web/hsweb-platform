<#import "../../global.ftl" as global />
<#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importPlugin
'codemirror/lib/codemirror.css'
,'codemirror/addon/fold/foldgutter.css'
,'codemirror/addon/hint/show-hint.css'
,'codemirror/addon/dialog/dialog.css'
,'codemirror/theme/eclipse.css'
,'codemirror/lib/codemirror.js'
,'codemirror/addon/search/searchcursor.js'
,'codemirror/addon/search/search.js'
,'codemirror/addon/dialog/dialog.js'
,'codemirror/addon/edit/matchbrackets.js'
,'codemirror/addon/edit/closebrackets.js'
,'codemirror/addon/wrap/hardwrap.js'
,'codemirror/addon/fold/foldcode.js'
,'codemirror/addon/hint/show-hint.js'
,'codemirror/addon/hint/javascript-hint.js'
,'codemirror/addon/hint/css-hint.js'
,'codemirror/addon/hint/anyword-hint.js'
,'codemirror/mode/javascript/javascript.js'
,'codemirror/mode/groovy/groovy.js'
,'codemirror/mode/htmlmixed/htmlmixed.js'
,'codemirror/mode/xml/xml.js'
,'codemirror/mode/css/css.js'
,'codemirror/keymap/sublime.js'
/>
<@global.importMiniui/>
    <style>
        body {
            margin: 0;
            padding: 0;
            border: 0;
            width: 100%;
            height: 100%;
        }

        .CodeMirror {
            border: 1px solid #D2D6D7;
            font-size: 16px;
            width: 100%;
            margin: auto;
            height: 600px;
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
        <textarea id="code"></textarea>
    </div>
</div>
</body>
</html>
<script type="text/javascript">
    var editor;
    function ok(){
        var script =editor.getValue();
        closeWindow(script);
    }
    function init(mode, data) {
        $("#code").html(data);
        editor = CodeMirror.fromTextArea(document.getElementById("code"), {
            lineNumbers: true,
            matchBrackets: true,
            lineWrapping: true,
            extraKeys: {
                "Alt-/": 'autocomplete'
            },
            foldGutter: true,
            gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"],
            mode: mode
        });
    }
</script>