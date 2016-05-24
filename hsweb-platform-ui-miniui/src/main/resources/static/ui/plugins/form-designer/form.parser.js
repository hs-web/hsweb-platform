/**
 * Created by zhouhao on 16-5-24.
 */
var FormParser = function (conf) {
    var tmp = this;
    this.mode = "new";
    this.helper = {};
    this.load = function () {
        var api = conf.name == "" ? "form/" + conf.id : "dyn-form/deployed/" + conf.name;
        Request.get(api, {}, function (e) {
            if (e.success) {
                e.data.meta = mini.decode(e.data.meta);
                tmp.data = e.data;
                tmp.layout();
                if (tmp.onload)tmp.onload();
            } else {
                showTips("加载数据失败:" + e.message, "danger");
            }
        });
    };
    this.getData=function(){
        var form=new mini.Form(conf.target);
        form.validate();
        if (form.isValid() == false) return;
        var data=form.getData();
        for(var hp in tmp.helper){
            data[hp]=mini.encode(tmp.helper[hp].getValue());
        }
        return data;
    }
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
    this.parser = function (meta, html) {
        if (meta["_meta"] == 'table'||meta["_meta"] == 'file') {
            var tableViewUri = Request.BASH_PATH + meta.customPage;
            var table = $("<iframe style='width: 100%;height:100%; border: 0px;' src='" + tableViewUri + "' ></iframe>");
            table.addClass("form-table");
            table.attr("form-name", meta["name"]);
            table.on("load", function () {
                var win = this.contentWindow;
                if (win.init)
                    win.init(meta);
                if (win.getData) {
                    tmp.helper[meta.name] = {};
                    tmp.helper[meta.name].getValue = win.getData;
                    tmp.helper[meta.name].setValue = win.setData;
                }
            });
            $(html).parent().append(table);
            $(html).hide();
        }
        return true;
    }
    return this;
}