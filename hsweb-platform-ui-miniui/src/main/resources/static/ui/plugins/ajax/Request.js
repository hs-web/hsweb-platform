/**
 * Created by zhouhao on 16-4-21.
 */
var Request = {
    BASH_PATH: "",
    encodeParam: function (data) {
        var queryParam = {};
        var index = 0;
        for (var f in data) {
            if (data[f] == "")continue;
            if (f.indexOf('$LIKE') != -1 && data[f].indexOf('%') == -1)data[f] = "%" + data[f] + "%";
            if (f.indexOf('$START') != -1)data[f] = "%" + data[f];
            if (f.indexOf('$END') != -1)data[f] = data[f] + "%";
            queryParam["terms[" + (index) + "].field"] = f;
            queryParam["terms[" + (index) + "].value"] = data[f];
            index++;
        }
        return queryParam;
    },
    createQuery: function (api) {
        var query = {};
        query.param = {};
        query.terms = [];
        query.getParams = function () {
            var tmp = buildParam(query.terms);
            for (var f in tmp) {
                query.param[f] = tmp[f];
            }
            return query.param;
        };
        query.select = function (fields) {
            query.param.includes = fields + "";
            return query;
        };
        query.excludes = function (fields) {
            query.param.excludes = fields + "";
            return query;
        };
        query.where = function (k, v) {
            query.and(k, v);
            return query;
        };
        query.and = function (k, v) {
            query.terms.push({field: k, value: v});
            return query;
        };
        query.orNest = function (k, v) {
            return query.nest(k, v, true);
        };
        query.nest = function (k, v, isOr) {
            var nest = {field: k, value: v, type: isOr ? 'or' : 'and'};
            var func = {};
            nest.terms = [];
            func.and = function (k, v) {
                nest.terms.push({field: k, value: v});
                return func;
            };
            func.or = function (k, v) {
                nest.terms.push({field: k, value: v, type: 'or'});
                return func;
            };
            func.exec = query.exec;
            func.nest = query.nest;
            query.terms.push(nest);
            return func;
        };
        query.or = function (k, v) {
            query.terms.push({field: k, value: v, type: 'or'});
            return query;
        };
        query.orderBy = function (f) {
            query.param.sortField = f;
            return query;
        };
        query.desc = function () {
            query.param.sortOrder = 'desc';
            return query;
        };
        query.asc = function () {
            query.param.sortOrder = 'asc';
            return query;
        };
        query.noPaging = function () {
            query.param.paging = 'false';
            return query;
        };
        query.limit = function (pageIndex, pageSize) {
            query.param.pageIndex = start;
            if (pageSize)
                query.param.pageSize = pageSize;
            return query;
        };
        function buildParam(terms) {
            var tmp = {};
            $(terms).each(function (i, e) {
                for (var f in e) {
                    if (f != 'terms')
                        tmp["terms[" + i + "]." + f] = e[f];
                    else {
                        var tmpTerms = buildParam(e[f]);
                        for (var f2 in tmpTerms) {
                            tmp["terms[" + i + "]." + f2] = tmpTerms[f2];
                        }
                    }
                }
            });
            return tmp
        }

        query.exec = function (callback) {
            var tmp = buildParam(query.terms);
            for (var f in tmp) {
                query.param[f] = tmp[f];
            }
            return Request.get(api, query.param, callback);
        };
        return query;
    },
    get: function (uri, data, callback) {
        var data_ = data, callback_=callback;
        if (typeof(data) == 'undefined')data_ = {};
        if (typeof(callback) == 'object')data_ = callback;
        if (typeof(data) == 'function')callback_ = data;
        return Request.doAjax(Request.BASH_PATH + uri, data_, "GET", callback_, typeof(callback_) != 'undefined', false);
    },
    post: function (uri, data, callback, requestBody) {
        if (requestBody != false)requestBody = true;
        Request.doAjax(Request.BASH_PATH + uri, data, "POST", callback, true, requestBody);
    },
    put: function (uri, data, callback, requestBody) {
        if (requestBody != false)requestBody = true;
        Request.doAjax(Request.BASH_PATH + uri, data, "PUT", callback, true, requestBody);
    },
    patch: function (uri, data, callback, requestBody) {
        if (requestBody != false)requestBody = true;
        Request.doAjax(Request.BASH_PATH + uri, data, "PATCH", callback, true, requestBody);
    },
    "delete": function (uri, data, callback) {
        var data_ = data, callback_=callback;
        if (typeof(data) == 'undefined')data_ = {};
        if (typeof(callback) == 'object')data_ = callback;
        if (typeof(data) == 'function')callback_ = data;
        return Request.doAjax(Request.BASH_PATH + uri, data_, "DELETE", callback_, typeof(callback_) != 'undefined', false);
    },
    doAjax: function (url, data, method, callback, syc, requestBody) {
        var data_tmp = data;
        if (requestBody == true) {
            if (typeof(data) != 'string') {
                data = JSON.stringify(data);
            }
        }
        var param = {
            type: method,
            url: url,
            data: data,
            cache: false,
            async: syc == true,
            success: callback,
            error: function (e) {
                var msg = {};
                if (e.responseJSON) {
                    msg = e.responseJSON;
                } else {
                    msg = {code: e.status, data: e.statusText, success: false};
                }
                if (msg.code == 401) {
                    doLogin(function () {
                        Request.doAjax(url, data_tmp, method, callback, syc, requestBody);
                    });
                } else {
                    if (callback)
                        callback(msg);
                }
            },
            dataType: 'json'
        };
        if (requestBody == true) {
            param.contentType = "application/json";
        }
        return $.ajax(param).responseJSON;
    }
}