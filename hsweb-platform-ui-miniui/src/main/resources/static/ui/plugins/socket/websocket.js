/**
 * Created by zhouhao on 16-5-29.
 */

var Socket = {};
Socket.URL = "ws://" + window.location.host + "/socket";
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
Socket.createNewSocket = function (func) {
    var this_ = this;
    this_.callbacks = {};
    this.reConnection = function (f) {
        Socket.createNewSocket(function (s) {
            this_.socket = s.socket;
            f(s);
        });
    }
    this.sub = function (cmd, params, callback) {
        if (this_.socket.readyState != 1) {
            if (this_.socket.readyState == 0) {
                setTimeout(function(){
                    this_.sub(cmd, params, callback);
                },100);
            } else {
                this_.reConnection(function () {
                    this_.sub(cmd, params, callback);
                });
            }
            return;
        }
        var tmp = {cmd: cmd, params: params};
        if (typeof (callback) == 'string') {
            params.callback = callback;
        } else if (callback) {
            params.callback = randomChar(16);
        }
        this_.socket.send(JSON.stringify(tmp));
    };
    this.on = function (call, action) {
        Socket.callbacks[call] = action;
    }
    try {
        if (window.WebSocket)
            this_.socket = new WebSocket(Socket.URL);
        else if (window.SockJS)
            this_.socket = new SockJS((Socket.URL + "/js").replace("ws", "http"), undefined, {protocols_whitelist: []});
        else {
            return null;
        }
        this_.socket.onopen = function () {
            if (func)func(this_);
        };
        this_.socket.onerror = function (msg) {
            //  console.log(msg);
        };
        this_.socket.onclose = function (msg) {
            //  console.log(msg);
        };
        this_.socket.onmessage = function (msg) {
            var data = msg.data;
            if (data) {
                data = JSON.parse(data);
                if (data.callBack && this_.callbacks[data.callBack]) {
                    this_.callbacks[data.callBack](data.content);
                }
            }
        }
        return this_;
    } catch (e) {
        if (window.console)
            console.log(e);
        return null;
    }

}
Socket.open = function (func) {
    var proxy = getSocket(window);
    if (!proxy) {
        window.__Socket = Socket.createNewSocket();
        if (func)func(window.__Socket);
    } else {
        window.__Socket = proxy;
        if (func)func(proxy);
        return proxy;
    }
    return Socket;
}

function getSocket(win) {
    if (win.__Socket) {
        return win.__Socket;
    } else {
        if (win.parent != win) {
            return getSocket(win.parent)
        }
    }
    return null;
}