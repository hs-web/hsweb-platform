/**
 * Created by zhouhao on 16-5-24.
 */
var FormParser = function (conf) {
    var tmp = this;
    this.helper = {};

    this.load = function (formData) {
        if (formData)tmp.formData = formData;
        var api = "";
        if (conf.name && conf.name != "") {
            if (conf.version && conf.version != '0') {
                api = "dyn-form/" + conf.name + "/v/" + conf.version;
            } else {
                api = "dyn-form/deployed/" + conf.name;
            }
        } else {
            api = "form/" + conf.id;
        }
        Request.get(api, {}, function (e) {
            if (e.success) {
                e.data.meta = mini.decode(e.data.meta);
                tmp.data = e.data;
                tmp.layout();
                if (tmp.onload)tmp.onload();
                if (tmp.formData)
                    tmp.setData(tmp.formData);
                if (conf.readOnly) {
                    setReadonly();
                }
            } else {
                showTips("加载数据失败:" + e.message, "danger");
            }
        });
        function setReadonly() {
            var fields = new mini.Form(conf.target).getFields();
            for (var i = 0, l = fields.length; i < l; i++) {
                var c = fields[i];
                if (c.setReadOnly) c.setReadOnly(true);     //只读
                if (c.setIsValid) c.setIsValid(true);      //去除错误提示
                if (c.addCls) c.addCls("asLabel");          //增加asLabel外观
            }
        }
    };
    this.setData = function (data) {
        var form = new mini.Form(conf.target);
        form.setData(data);
        for (var hp in tmp.helper) {
            tmp.helper[hp].setValue(mini.decode(data[hp]), data)
        }
    };
    this.getData = function (validate) {
        var form = new mini.Form(conf.target);
        if (validate) {
            form.validate();
            if (form.isValid() == false) return;
        }
        var data = form.getData();
        for (var hp in tmp.helper) {
            data[hp] = mini.encode(tmp.helper[hp].getValue());
        }
        return data;
    };
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

        for (var id in meta) {
            var el = html.find("[field-id='" + id + "']");
            var el_meta = list2Map(meta[id]);
            var domProperty = list2Map(mini.decode(el_meta.domProperty));
            el.addClass(el_meta['class']);
            el.attr("name", el_meta.name);
            for (var property in domProperty) {
                el.attr(property, domProperty[property]);
            }
            tmp.parser(el_meta, el);
        }
        $(conf.target).html(html);
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
            var tableViewUri = Request.BASH_PATH + (meta["_meta"] == 'tabs' ? 'admin/form/tabs.html' : meta.customPage);
            var domProperty = list2Map(mini.decode(meta["domProperty"]));
            var style = domProperty["style"] ? domProperty["style"] + ";border: 0px none;" : "width: 100%;height:100%; border: 0px none;";
            var table = $("<iframe frameborder='0' style='" + style + "' src='" + tableViewUri + "' ></iframe>");
            table.addClass("form-table");
            table.attr("form-name", meta["name"]);
            tmp.loadingFrame[meta["name"]] == true;
            table.on("load", function () {
                var win = this.contentWindow;
                if(meta["_meta"] == 'tabs')
                if (conf.readOnly && win.setReadOnly) {
                    win.setReadOnly();
                }
                if (win.getData) {
                    tmp.helper[meta.name] = {};
                    tmp.helper[meta.name].getValue = win.getData;
                    tmp.helper[meta.name].setValue = win.setData;
                    if (win.setData && tmp.formData)
                        win.setData(mini.decode(tmp.formData[meta["name"]]), tmp.formData);
                }
                if (win.init)
                    win.init(meta);
            });
            $(html).parent().append(table);
            $(html).hide();
        }
        return true;
    }
    return this;
}