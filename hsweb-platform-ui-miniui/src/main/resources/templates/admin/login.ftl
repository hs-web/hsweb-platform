<#import "../global.ftl" as global />
<#import "/spring.ftl" as spring/>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>用户登录</title>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>

    <style type="text/css">
        body {
            width: 100%;
            height: 100%;
            margin: 0;
            overflow: hidden;
        }
    </style>
<@global.importMiniui/>
</head>
<body>
<div id="loginWindow" class="mini-window" title="用户登录" style="width:350px;height:165px;"
     showModal="true" showCloseButton="false">

    <div id="loginForm" style="padding:15px;padding-top:10px;">
        <table>
            <tr>
                <td style="width:60px;"><label for="username$text">帐号：</label></td>
                <td>
                    <input id="username" name="username" class="mini-textbox" value="admin" required="true" style="width:150px;"/>
                </td>
            </tr>
            <tr>
                <td style="width:60px;"><label for="pwd$text">密码：</label></td>
                <td>
                    <input id="password" name="password" class="mini-password" value="admin" required="true" requiredErrorText="密码不能为空" required="true" style="width:150px;" onenter="onLoginClick"/>
                </td>
            </tr>
            <tr>
                <td></td>
                <td style="padding-top:5px;">
                    <a onclick="onLoginClick" class="mini-button" style="width:60px;">登录</a>
                    <a onclick="onResetClick" class="mini-button" style="width:60px;">重置</a>
                </td>
            </tr>
        </table>
    </div>
</div>
<@global.importRequest/>
<script type="text/javascript">
    mini.parse();
    var back = "${uri!'index.html'}";
    var loginWindow = mini.get("loginWindow");
    loginWindow.show();
    function onLoginClick() {
        var form = new mini.Form("#loginWindow");
        form.validate();
        if (form.isValid() == false) return;
        var box = mini.loading("登录中...", "登录");
        var data = form.getData();
        Request.post("login", {username: data.username, password: data.password}, function (e) {
            mini.hideMessageBox(box);
            if (e.success) {
                if (back == 'ajax')closeWindow("success");
                else
                    window.location.href = back;
            }
            else mini.alert(e.message);
        },false);
    }
    function onResetClick(e) {
        var form = new mini.Form("#loginWindow");
        form.clear();
    }
    /////////////////////////////////////
    function isEmail(s) {
        if (s.search(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/) != -1)
            return true;
        else
            return false;
    }
    function onUserNameValidation(e) {
        if (e.isValid) {
            if (isEmail(e.value) == false) {
                e.errorText = "必须输入邮件地址";
                e.isValid = false;
            }
        }
    }
    function onPwdValidation(e) {
        if (e.isValid) {
            if (e.value.length < 5) {
                e.errorText = "密码不能少于5个字符";
                e.isValid = false;
            }
        }
    }
</script>

</body>
</html>
