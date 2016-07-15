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
            width: 99%;
            margin: auto;
            height: 100%;
        }
    </style>
</head>
<body>
<div class="mini-fit" style="width: 100%;">
    <textarea id="code"></textarea>
</div>
</body>
</html>
<script type="text/javascript">
    var editor;
    window.getScript = function () {
        return editor.getValue();
    }
    window.initScript = function (mode, data) {
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