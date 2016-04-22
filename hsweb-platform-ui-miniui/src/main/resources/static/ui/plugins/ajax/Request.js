/**
 * Created by zhouhao on 16-4-21.
 */
var Request = {
    BASH_PATH: "",
    get: function (uri, data, callback) {
        Request.doAjax(Request.BASH_PATH + uri, data, "GET", callback, false, false);
    },
    post: function (uri, data, callback) {
        Request.doAjax(Request.BASH_PATH + uri, data, "POST", callback, false, true);
    },
    put: function (uri, data, callback) {
        Request.doAjax(Request.BASH_PATH + uri, data, "PUT", callback, false, true);
    },
    delete: function (uri, data, callback) {
        Request.doAjax(Request.BASH_PATH + uri, data, "DELETE", callback, false, false);
    },
    doAjax: function (url, data, method, callback, syc, requestBody) {
        if (requestBody == true) {
            data = JSON.stringify(data);
        }
        var param = {
            type: method,
            url: url,
            data: data,
            cache: false,
            async: syc == true,
            success: callback,
            dataType: 'json'
        };
        if (requestBody == true) {
            param.contentType = "application/json";
        }
        $.ajax(param);
    }
}