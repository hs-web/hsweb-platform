/**
 * Created by zhouhao on 16-5-6.
 */

function showTips(msg, state) {
    mini.showTips({
        content: msg,
        state: state || 'success',
        x: 'center',
        y: 'top',
        timeout: 3000
    });
}

function openWindow(url, title, width, height, ondestroy) {
    mini.open({
        url: url,
        showMaxButton: true,
        title: title,
        width: width,
        height: height,
        ondestroy: ondestroy
    });
}
function closeWindow(action) {
    if (window.CloseOwnerWindow) return window.CloseOwnerWindow(action);
    else window.close();
}