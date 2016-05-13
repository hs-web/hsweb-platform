/**
 * Created by zhouhao on 16-4-21.
 */
var Request = {
    BASH_PATH: "",
    encodeParam:function(data){
        var queryParam = {};
        var index=0;
        for (var f in data) {
            if(data[f]=="")continue;
            if (f.indexOf('$LIKE') != -1 && data[f].indexOf('%') == -1)data[f] = "%" + data[f] + "%";
            if (f.indexOf('$START') != -1)data[f] = "%" + data[f];
            if (f.indexOf('$END') != -1)data[f] =  data[f]+"%";
            queryParam["terms["+(index)+"].field"]=f;
            queryParam["terms["+(index)+"].value"]=data[f];
            index++;
        }
        return queryParam;
    },
    createQuery: function (api) {
        var query = {};
        query.param = {};
        query.terms = [];
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
            return query.nest(k,v,true);
        };
        query.nest = function (k, v,isOr) {
            var nest = {field: k, value: v,type:isOr?'or':'and'};
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
            var tmp=buildParam( query.terms);
            for(var f in tmp){
                query.param[f]=tmp[f];
            }
            return Request.get(api, query.param, callback);
        };
        return query;
    },
    get: function (uri, data, callback) {
        Request.doAjax(Request.BASH_PATH + uri, data, "GET", callback, true, false);
    },
    post: function (uri, data, callback) {
        Request.doAjax(Request.BASH_PATH + uri, data, "POST", callback, true, true);
    },
    put: function (uri, data, callback) {
        Request.doAjax(Request.BASH_PATH + uri, data, "PUT", callback, true, true);
    },
    "delete": function (uri, data, callback) {
        Request.doAjax(Request.BASH_PATH + uri, data, "DELETE", callback, true, false);
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
            error: function (e) {
                if (e.responseJSON)
                    callback(e.responseJSON);
                else
                    callback({code: e.status, data: e.statusText, success: false});
            },
            dataType: 'json'
        };
        if (requestBody == true) {
            param.contentType = "application/json";
        }
        $.ajax(param);
    }
}