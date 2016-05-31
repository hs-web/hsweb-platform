/**
 * Created by zhouhao on 16-5-29.
 */

var Socket = {};
Socket.URL = "ws://"+window.location.host+"/socket";
function randomChar(len) {
    len = len || 32;
    var $chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz';
    var maxPos = $chars.length;
    var pwd = '';
    for (var i = 0; i < len; i++) {
        pwd += $chars.charAt(Math.floor(Math.random() * maxPos));
    }
    return pwd;
}
Socket.open = function (func) {
    var proxy = getSocket(window);
    if (!proxy) {
        try {
            if (window.WebSocket)
                proxy = new WebSocket(Socket.URL);
            else
            if (window.SockJS)
                proxy = new SockJS((Socket.URL+"/js").replace("ws","http"), undefined, {protocols_whitelist: []});
            else {
                return null;
            }
        } catch (e) {
            if (window.console)
                console.log(e);
            return null;
        }
        window.__Socket=Socket;
        Socket.callbacks = {};
        Socket.__proxy = proxy;
        proxy.onopen = function () {
            if (func)func(Socket);
        };
        Socket.__proxy.onerror = function (msg) {
            Socket.closed=true;
            console.log(msg);
        };
        Socket.__proxy.onclose = function (msg) {
            console.log(msg);
        };
        Socket.__proxy.onmessage = function (msg) {
            var data = msg.data;
            if (data) {
                data = JSON.parse(data);
                if (data.callBack && Socket.callbacks[data.callBack]) {
                    Socket.callbacks[data.callBack](data.content);
                }
            }
        }
        Socket.sub = function (cmd, params, callback) {
            var tmp = {cmd: cmd, params: params};
            if (typeof (callback) == 'string') {
                params.callback = callback;
            } else if (callback) {
                params.callback = randomChar(16);
            }
            Socket.__proxy.send(JSON.stringify(tmp));
        };
        Socket.on=function(call,action){
            Socket.callbacks[call]=action;
        }
    } else {
        window.__Socket=proxy;
        if (func)func(proxy);
        return proxy;
    }
    return Socket;
}

function getSocket(win) {
    if (win.__Socket) {
        if(win.__Socket.closed)return null;
        return win.__Socket;
    } else {
        if (win.parent != win) {
            return getSocket(win.parent)
        }
    }
    return null;
}