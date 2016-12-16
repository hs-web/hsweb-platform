<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="zh-cn">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>Editor</title>
    <style type="text/css" media="screen">
        body {
            overflow: hidden;
        }

        #editor {
            margin: 0;
            position: absolute;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            font-size: 18px;
        }

        .ace_autocomplete {
            width: 400px;
        }
    </style>
</head>
<body>
<pre id="editor"></pre>
</body>
</html>
<@global.importPlugin "ace/ace.js","ace/ext-language_tools.js"/>
<@global.importJquery/>
<@global.importRequest/>
<script type="text/javascript">
    var langTools = ace.require("ace/ext/language_tools");
    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/eclipse");
    window.getSelection = function () {
        return editor.getSelectedText();
    }

    var complateData;

    //由父页面调用
    window.init = function (lang, script, isServer) {
        editor.getSession().setMode("ace/mode/" + lang);
        editor.setValue(script, -1);
        editor.$blockScrolling = Infinity;
        editor.setOptions({
            enableBasicAutocompletion: true,
            enableSnippets: true,
            enableLiveAutocompletion: true
        });
        //如果是服务端脚本，应该调用服务器获取自动补全数据
        if (isServer) {
            if (!complateData) {
                Request.get("ide/auto-complete-data", function (e) {
                    if (e.success) {
                        setCompleteData(complateData = e.data);
                    }
                });
            } else {
                setCompleteData(complateData);
            }
        } else {
            if (lang == "javascript") {
            }
        }
    }
    window.getScript = function () {
        return editor.getValue();
    }
    window.setScript = function (script) {
        editor.setValue(script, -1);
    }
    //自定义自动补全数据
    var setCompleteData = function (data) {
        langTools.addCompleter({
            getCompletions: function (editor, session, pos, prefix, callback) {
                if (prefix.length === 0) {
                    return callback(null, []);
                } else {
                    return callback(null, data);
                }
            }
        });
    }
    window.setCompleteData = setCompleteData;
</script>