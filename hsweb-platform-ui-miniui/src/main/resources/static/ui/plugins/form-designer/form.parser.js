/**
 * Created by zhouhao on 16-5-24.
 */
var FormParser = function (conf) {
    var tmp = this;
    this.helper = {};
    this.debug = false;
    this.loadMeta = function (meta, formData) {
        if (formData)tmp.formData = formData;
        tmp.data = meta;
        tmp.data.meta = mini.decode(tmp.data.meta);
        tmp.layout();
        tmp.initScripts();
        if (tmp.onload)tmp.onload();
        if (tmp.formData)
            tmp.setData(tmp.formData);
        if (conf.readOnly) {
            tmp.setReadonly();
        }
        if (tmp.onloadSuccess)tmp.onloadSuccess();
    };
    this.load = function (formData) {
        if (formData)tmp.formData = formData;
        window.formData = formData;
        var api = conf.name == "" ? "form/" + conf.id : "dyn-form/deployed/" + conf.name;
        Request.get(api, {}, function (e) {
            if (e.success) {
                e.data.meta = mini.decode(e.data.meta);
                tmp.data = e.data;
                tmp.layout();
                tmp.initScripts();
                if (tmp.onload)tmp.onload();
                if (tmp.formData)
                    tmp.setData(tmp.formData);
                if (conf.readOnly) {
                    tmp.setReadonly();
                }
                if (tmp.onloadSuccess)tmp.onloadSuccess();
            } else {
                showTips("加载数据失败:" + e.message, "danger");
            }
        });
    };
    this.setReadonly = function () {
        var fields = new mini.Form(conf.target).getFields();
        //$(conf.target + " .mini-button").hide();
        for (var i = 0, l = fields.length; i < l; i++) {
            var c = fields[i];
            if (c.setReadOnly) c.setReadOnly(true);     //只读
            if (c.setIsValid) c.setIsValid(true);      //去除错误提示
            if (c.addCls) c.addCls("asLabel");          //增加asLabel外观
        }
    }
    this.setData = function (data) {
        var form = new mini.Form(conf.target);
        form.setData(data);
        for (var hp in tmp.helper) {
            tmp.helper[hp].setValue(data[hp], data)
        }
        this.doEvent();
    };
    this.getData = function (validate) {
        var form = new mini.Form(conf.target);
        if (validate) {
            form.validate();
            if (form.isValid() == false) return;
        }
        var data = form.getData();
        for (var hp in tmp.helper) {
            data[hp] = tmp.helper[hp].getValue(data);
        }
        return data;
    };
    this.doEvent = function () {
        var fields = new mini.Form(conf.target).getFields();
        for (var i = 0, l = fields.length; i < l; i++) {
            var field = fields[i];
            if (field.getValue() == "")continue;
            if (field.doValueChanged) {
                field.doValueChanged();
            }
        }
    };
    this.initScripts = function () {
        window.formConfig = conf;
        window.BASE_PATH = Request.BASH_PATH;
        var meta = tmp.data.meta;
        var main = list2Map(meta['main']);
        $("<script type='text/javascript' />").attr({
            "src": Request.BASH_PATH + "ui/resources/js/form-boost.js"
        }).appendTo("head");
        if (main.scripts) {
            var scripts = mini.decode(main.scripts);
            $(scripts).each(function (i, e) {
                try {
                    if (e.type == "script") {
                        $("<script type='text/javascript' >" + e.script + "</script>").appendTo("head");
                    } else {
                        if (!(e.script.indexOf('http') == 0)) {
                            e.script = Request.BASH_PATH + e.script;
                        }
                        $("<script type='text/javascript' />").attr({
                            "src": e.script
                        }).appendTo("head");
                    }
                } catch (e) {
                    mini.alert("加载脚本失败!");
                    if (console.log) {
                        console.log(e);
                        throw e;
                    }
                }
            });
        }
        if (main.css) {
            var cssList = mini.decode(main.css);
            $(cssList).each(function (i, e) {
                try {
                    if (e.type == "link") {
                        if (!(e.css.indexOf('http') == 0)) {
                            e.css = Request.BASH_PATH + e.css;
                        }
                        $("<link rel='stylesheet' />").attr("href", e.css).appendTo("head");
                    } else {
                        $("<style type='text/css' >" + e.css + "</style>").appendTo("head");
                    }
                } catch (e) {
                    mini.alert("加载样式失败!");
                    if (console.log) {
                        console.log(e);
                    }
                }
            });
        }
    };
    window.__tmp = {};
    this.layout = function () {
        var meta = tmp.data.meta;
        var html = $(tmp.data.html);

        function list2Map(list) {
            var map = {};
            $(list).each(function (index, o) {
                map[o.key] = o.value;
            });
            return map;
        }

        var index_ = 0;
        var functionList = [];
        for (var id in meta) {
            var el = html.find("[field-id='" + id + "']");
            var el_meta = list2Map(meta[id]);
            var domProperty = list2Map(mini.decode(el_meta.domProperty));
            el.addClass(el_meta['class']);
            if (el_meta.alias && el_meta.alias != '')
                el.attr("name", el_meta.alias);
            else
                el.attr("name", el_meta.name);
            el.removeAttr('field-id');
            for (var property in domProperty) {
                if (property == 'data') {
                    var json = domProperty[property];
                    var data_name = "data_" + (index_++);
                    window.__tmp[data_name] = mini.decode(json);
                    domProperty[property] = "window.__tmp." + data_name;
                }
                if (domProperty[property] != '')
                    el.attr(property, domProperty[property]);
            }
            var show = true;
            if (el_meta['showCondition']) {
                var showCondition = mini.decode(el_meta['showCondition']);
                for (var i = 0; i < showCondition.length; i++) {
                    var e = showCondition[i];
                    var script = "window.__showCondition_" + i + "= function(data){" +
                        e.condition +
                        "}";
                    try {
                        eval(script);
                        show = window["__showCondition_" + i](tmp.formData);
                        if (!show)break;
                    } catch (e) {
                        showTips(el_meta.name + "条件判断失败!");
                    }
                }
            }
            if (show) {
                var func = tmp.parser(el_meta, el);
                if (func && typeof(func) == 'function') {
                    functionList.push(func);
                }
            }
            else {
                $(el).hide();
            }
        }
        //将所有p标签替换为span,以兼容ie8
        html.find("p").each(function () {
            $(this).replaceWith('<span>' + $(this).html() + '</span>');
        });
        $(conf.target).html(html);
        $(functionList).each(function (i, e) {
            e();
        });
        return html;
    };
    this.loadingFrame = {};
    function list2Map(list) {
        var map = {};
        $(list).each(function (index, o) {
            map[o.key] = o.value;
        });
        return map;
    };
    this.parser = function (meta, html) {
        if (meta["_meta"] == 'table' || meta["_meta"] == 'file' || meta["_meta"] == 'tabs') {
            var tableViewUri = (meta["_meta"] == 'tabs' ? 'admin/form/tabs.html' : meta.customPage);
            var domProperty = list2Map(mini.decode(meta["domProperty"]));
            var style = domProperty["style"] ? domProperty["style"] : "width: 90%;height:300px;margin:auto";
            var div = $("<div style='" + style + "'></div>");
            if (tableViewUri.indexOf("http") != 0) {
                tableViewUri = Request.BASH_PATH + tableViewUri;
            }
            var table = $("<iframe frameborder='0' style='width: 100%;height:100%;border: 0px none'></iframe>");
            table.addClass("form-table");
            var helperName = meta.name;
            if (meta.alias && meta.alias != '')
                helperName = meta.alias;
            table.attr("form-name", helperName);
            var onLoad = function () {
                var win = this.contentWindow;
                if (!win)return true;
                if (conf.readOnly && win.setReadOnly) {
                    win.setReadOnly();
                }
                win.hide = function () {
                    $(table).hide();
                }
                if (win.getData) {
                    tmp.helper[helperName] = {};
                    tmp.helper[helperName].getValue = win.getData;
                    tmp.helper[helperName].setValue = win.setData;
                    if (win.setData && tmp.formData) {
                        win.setData(tmp.formData[helperName], tmp.formData);
                    }
                }
                if (win.init)
                    win.init(meta);
            }
            table.on("load", onLoad);
            tmp.loadingFrame[helperName] == true;
            $(html).parent().append(div);
            $(table).appendTo(div);
            $(html).hide();
            table.ready(function () {
                table.attr("src", tableViewUri);
            });
        }
        return true;
    }
    return this;
}