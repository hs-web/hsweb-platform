// var key = "";
var defaultQueryParam = {};
var grid;
var includes = ["u_id"];
var queryTypeMapper = {
    "=": {value: "eq"},
    ">=": {value: "gt"},
    "<=": {value: "lt"},
    "like": {
        value: "like"
    },
    "like%": {
        value: "like", helper: function (v) {
            return v + "%";
        }
    }, "%like": {
        value: "like", helper: function (v) {
            return "%" + v;
        }
    }, "%like%": {
        value: "like", helper: function (v) {
            return "%" + v + "%";
        }
    }, "in": {
        value: "in"
    }, "notin": {
        value: "notin"
    }
}
var ListPageParser = function (key, pageConfig) {
    if (!pageConfig) {
        pageConfig = {};
    }
    var localStoreEnable = typeof(store) != 'undefined';
    var tmp = {};
    var events = {};

    function getMetaCacheKey(key) {
        return "module-meta:" + key;
    }

    function getFormCacheKey(name, version) {
        return "form:" + name + ":" + version;
    }

    function checkFormCached(name, version, cbk) {
        var cacheKey = getFormCacheKey(name, version);
        if (localStoreEnable) {
            var cache = store.get(cacheKey);
            if (cache) {
                Request.get("form/" + name + "/version", function (res) {
                    if (res.success) {
                        if (res.data != cache) {
                            cbk(false);
                        } else {
                            cbk(true);
                        }
                    }
                });
            } else {
                cbk(false);
            }
        } else {
            cbk(false);
        }
    }

    function checkCached(cbk) {
        if (localStoreEnable) {
            var cache = store.get(getMetaCacheKey(key));
            if (cache) {
                //检查版本
                Request.get("module-meta/" + key + "/md5", function (res) {
                    if (res.success) {
                        if (res.data == cache.md5) {
                            checkFormCached(cache.form, cache.ver, cbk);
                        } else {
                            cbk(false);
                        }
                    }
                });
            } else {
                cbk(false);
            }
        } else {
            cbk(false);
        }
    }

    function createSearchHtml(config, formMeta) {
        var html = "<table class='searchForm'><tr>";
        var index = 0;
        var newLineIndex = 3;
        var lineNumber = 1;
        var x = 0;
        var fields = formMeta ? JSON.parse(formMeta.meta) : [];
        var fieldMapping = {};

        function list2Map(list) {
            var map = {};
            $(list).each(function (index, o) {
                map[o.key] = o.value;
            });
            return map;
        }

        for (var i in fields) {
            if (i == 'main')continue;
            var field = fields[i];
            var mapping = list2Map(field);
            mapping.id = i;
            fieldMapping[mapping.name] = mapping;
            if (mapping.domProperty)
                mapping.domProperty = list2Map(JSON.parse(mapping.domProperty));
        }
        var fieldConfig = {};

        $(config).each(function (i, e) {
            if (e.field) {
                var id = "f_" + randomChar(4);
                fieldConfig[id] = {field: e.field, queryType: e.queryType};
                var fieldHtml = e.customHtml;
                var customAttr = e.customAttr ? JSON.parse(e.customAttr) : {};
                if (fieldHtml && fieldHtml != "") {
                    fieldHtml = $(fieldHtml).attr(customAttr)[0].outerHTML;
                } else {
                    //从表单定义里获取
                    if (formMeta) {
                        var fieldCfg = fieldMapping[e.field];
                        if (fieldCfg) {
                            delete fieldCfg.domProperty.onvaluechanged;
                            var tmp = $("<input>");
                            tmp.attr("class", fieldCfg['class'] == 'mini-buttonedit' || fieldCfg['class'] == 'mini-textarea' ? "mini-textbox" : fieldCfg['class']);
                            tmp.attr(fieldCfg.domProperty);
                            fieldHtml = tmp[0].outerHTML;
                        }
                    }
                }
                if (!fieldHtml) {
                    fieldHtml = "<input class='mini-textbox' />";
                }

                fieldHtml = $(fieldHtml).attr("name", id)[0].outerHTML;
                x++;
                if (index != 0 && index % newLineIndex == 0) {
                    lineNumber++;
                    html += "</tr><tr>";
                }
                index++;
                html += "<td class='title font' >";
                html += e.title + ":";
                html += "</td>";
                html += "<td class='html'>";
                html += fieldHtml;
                html += "</td>";
            }
        });
        if (x > newLineIndex) {
            x = 6;
        } else {
            x = x * 2;
        }
        html += "<tr/><tr>";
        html += "<td class='searchTd' colspan='" + x + "' align='center'></td>";
        html += "</tr></table>"
        var jqHtml = $(html);
        jqHtml.find("input").css("width", "95%").attr({
            "required": false,
            "showNullItem": true,
            "onenter": "search", "value": ""
        }).removeAttr("readOnly");
        $("<a class='mini-button' iconCls='icon-search' plain='true' onclick='search()'>查询</a>" +
            "<a class='mini-button' iconCls='icon-arrow-rotate-clockwise' plain='true' onclick='new mini.Form(\"#searchForm\").reset();search()'>重置条件</a>")
            .appendTo(jqHtml.find(".searchTd"));
        return {html: jqHtml[0].outerHTML, config: fieldConfig};
    }

    function createGridConfig(config, meta) {
        var cache = {};
        var scripts = {};
        var columns = [{type: 'indexcolumn', header: "序号", headerAlign: 'center'}];
        $(config).each(function () {
            var custom = this;
            if (custom.renderer && custom != '') {
                var script = "(function(){return function(e){" +
                    "var row = e.record;var value=e.value;try{" +
                    custom.renderer +
                    "}catch(e){if(window.console){window.console.error(e);}return value;}}})();";
                var scriptId = randomChar(5);
                scripts[scriptId] = script;
                custom.renderer = scriptId;
            }
            if (custom.properties && custom.properties != '') {
                var properties = JSON.parse(custom.properties);
                for (var p in properties) {
                    this[p] = properties[p];
                }
            }
            delete custom.properties;
            for (var i in custom) {
                if (custom[i] == 'true')custom[i] = true;
                if (custom[i] == 'false')custom[i] = false;
            }
            columns.push(this);
        });
        columns.push({"width": 100, "visible": true, "align": "center", "headerAlign": "center", "header": "操作", "renderer": "parser.renderActionButton"});
        cache.columns = columns;
        cache.scripts = scripts;
        cache.actions = meta.actionConfig;
        return cache;
    }

    function createToolBar(toolbar) {
        var caches = [];
        $(toolbar).each(function () {
            var cache = {};
            if (this.type == 'separator' || this['class'] == 'separator') {
                cache.html = '<span class="separator"></span>';
            } else {
                var script;
                if (typeof(this.onclick) == 'function') {
                    script = this.onclick.toString();
                } else {
                    script = this.onclick;
                }
                if (this.child) {
                    cache.child = createToolBar(this.child);
                    this['class'] = "mini-menubutton";
                }
                cache.action = this.action;
                cache.module = this.module;
                delete this.action;
                delete this.module;
                delete this.child;
                delete this.onclick;
                var htmlText = this.el ? this.el : "<a>";
                var html = $(htmlText);
                html.attr("plain", true).attr({"class": "mini-button"}).attr(this).text(this.text);
                cache.html = html[0].outerHTML;
                if (script)
                    cache.onclick = script;
            }
            caches.push(cache);
        });
        return caches;
    }

    window.exportAllColumnExcel = function (formName) {
        var param = mini.clone(grid.getLoadParams());
        delete param.includes;
        if (param.excludes) {
            param.excludes += ",u_id";
        } else {
            param.excludes = "u_id";
        }
        openWindow("admin/dyn-form/exportExcel.html?name=" + formName, "自定义导出", "600px", "70%", function (e) {
        }, function () {
            var iframe = this.getIFrameEl();
            var win = iframe.contentWindow;

            function initWin() {
                win.setParam(param);
            }

            $(iframe).on("load", initWin)
            initWin();
        });
    }

    window.customSearch = function (formName) {
        openWindow("admin/plan/query-plan.html?name=" + formName, "自定义查询", "700px", "400px", function (e) {
        }, function () {
            var iframe = this.getIFrameEl();
            var win = iframe.contentWindow;

            function initWin() {
                win.onsearch = function (e) {
                    e.includes = includes + "";
                    grid.load(e);
                }
            }

            $(iframe).on("load", initWin)
            initWin();
        });
    }

    function getToolBarConfig(meta, metaConf, formMeta) {
        var createUrl = metaConf.create_page;
        createUrl = createUrl.replace("{id}").replace("{metaId}", meta.id);
        function createActionClick(type) {
            var func = function () {
                var iframe = this.getIFrameEl();
                var win = iframe.contentWindow;

                function init() {
                    parser.on("toolBarClick")({parser: parser, window: win, action: "{type}"});
                }

                $(iframe).on("load", init);
                init();
            };
            var script = (func + "").replace("{type}", type).replace("\n", "").replace(/\s+/g, ' ').replace("\'", "\\'");
            return script;
        }

        var toolbar = [
            {
                text: "新建", action: "C", iconCls: "icon-add", onclick: eval("(function(){return " +
                '\'openWindow(Request.BASH_PATH + "' + createUrl + '", "新建' + formMeta.remark + '", "80%", "80%", function (e) {grid.reload();},' + createActionClick('C') + ');\'})()')
            },
            {
                type: "separator"
            }
            ,
            {
                text: "导入excel", action: "import", iconCls: "icon-upload", onclick: eval("(function(){return " +
                '\'openWindow(Request.BASH_PATH + "admin/dyn-form/importExcel.html?name='
                + metaConf.dynForm + '", "导入excel", "600px", "70%", function (e) {grid.reload();},' + createActionClick('import') + ');\'})()')
            },
            {
                text: "导出excel", action: "export", iconCls: "icon-download", child: [
                {
                    el: "<li>", text: "导出本页数据", iconCls: "icon-download", onclick: eval("(function(){return " +
                    '\'downloadGridExcel(grid, "' + formMeta.remark + '");\'' +
                    "})()")
                },
                {
                    el: "<li>", text: "自定义导出", iconCls: "icon-download", onclick: eval("(function(){return " +
                    '\'window.exportAllColumnExcel("' + metaConf.dynForm + '");\'' +
                    "})()")
                }
            ]
            },
            {
                type: "separator"
            }, {
                text: "刷新", iconCls: "icon-reload", onclick: "grid.reload()"
            }, {
                text: "自定义查询", iconCls: "icon-application-view-list", onclick: "window.customSearch('" + metaConf.dynForm + "')"
            }
        ]
        return toolbar;
    }

    function on(event, callback) {
        if (!events[event]) {
            events[event] = [];
        }
        if (!callback) {
            return function (args) {
                if (events[event]) {
                    $(events[event]).each(function () {
                        this(args);
                    });
                }
            }
        } else {
            events[event].push(callback);
        }
    }

    tmp.on = on;
    function parsePage(cfg) {
        var user = getUser();
        try {
            if (cfg.script && $.trim(cfg.script) != "") {
                eval("(function(){return function(parser,user,config){" + cfg.script + "}})()")(tmp, user, pageConfig);
            }
        } catch (e) {
            if (window.console) {
                console.log(e);
            }
        }
        //创建toolbar
        var toolbarHtml = $("<div>");
        var toolBar = cfg.toolBar;
        if (pageConfig.getToolBar) {
            toolBar = pageConfig.getToolBar(toolBar);
        }
        $(toolBar).each(function () {
            function createButton(button) {
                if (button.action) {
                    if (!user.hasAccessModule(button.module ? button.module : key, button.action))return;
                }
                var bt = $(button.html);
                if (button.onclick) {
                    if (typeof(button.onclick) == 'function') {
                        bt.attr("onclick", button.onclick);
                    } else {
                        var scriptId = randomChar(5);
                        window[scriptId] = eval("(function(){return function(){" + button.onclick + "}})()");
                        bt.attr("onclick", "window." + scriptId + "()");
                    }
                }
                if (button.child) {
                    var menuId = "m_" + randomChar(4);
                    bt.attr("menu", "#" + menuId);
                    var menuHTML = $("<ul class='mini-menu' style='display: none'></ul>").attr("id", menuId);
                    $(button.child).each(function () {
                        menuHTML.append(createButton(this));
                    });

                    $(document.body).append(menuHTML);
                }
                return bt;
            }

            toolbarHtml.append(createButton(this));
        });
        $("#toolbar").html("");
        $("#searchForm").html("");
        $("#toolbar").append(toolbarHtml);
        if (pageConfig.enableSearch != false) {
            $("#searchForm").html(cfg.search.html);
        }
        for (var script in cfg.grid.scripts) {
            window[script] = eval(cfg.grid.scripts[script]);
        }
        tmp.renderActionButton = function (e) {
            var html = "";
            $(cfg.grid.actions).each(function () {
                var click = this.onclick;
                if (this.moduleAction) {
                    if (!user.hasAccessModule(this.module ? this.module : key, this.moduleAction))return;
                }
                if (this.condition) {
                    var script = "(function(){return function(row,data,id){" +
                        "try{" + this.condition + "}catch(e){if(window.console){console.error(e)}return false;}" +
                        "}})()";
                    var show = eval(script)(e.record, e.record, e.record.u_id);
                    if (!show)return;
                }
                var scriptId = "ab_" + randomChar(5);
                window[scriptId] = function (id) {
                    var row = getRow(grid, id);
                    return eval("(function(){return function(row,id,data){" + click + "}})()")(row, row.u_id, row);
                };
                html += createActionButton(this.title, "window." + scriptId + "('" + (e.record._id) + "')", this.icon);
            });
            return html;
        }
        window.editData = function (e) {
            var saveUrl = cfg.save_page;
            saveUrl = saveUrl.replace("{id}", e).replace("{metaId}", cfg.id);
            if (saveUrl) {
                openWindow(Request.BASH_PATH + saveUrl, "编辑", "80%", "80%", function (e) {
                    grid.reload()
                });
            }
        }
        window.infoData = function infoData(e) {
            var url = cfg.info_page;
            url = url.replace("{id}", e).replace("{metaId}", cfg.id);
            if (url) {
                openWindow(Request.BASH_PATH + url, "查看", "80%", "80%", function (e) {
                    grid.reload()
                });
            }
        }
        $(cfg.grid.columns).each(function () {
            var field = this.field;
            if (field)
                includes.push(field);
        });
        tmp.search = window.search = function () {
            var formData = new mini.Form("#searchForm").getData();
            for (var i in defaultQueryParam) {
                formData[i] = defaultQueryParam[i];
            }
            var param = {};
            var index = 0;
            for (var f in formData) {
                var value = formData[f];
                if (!value || value == '') {
                    continue;
                }
                if (typeof (value) == 'object') {
                    if (mini.getbyName(f) && mini.getbyName(f).getFormValue)
                        formData[f] = mini.getbyName(f).getFormValue();
                    else  continue;
                }
                var fieldCfg = cfg.search.config[f];
                if (!fieldCfg) {
                    param['terms[' + index + '].column'] = f;
                    param['terms[' + index + '].value'] = value;
                    continue;
                }
                var field = fieldCfg.field;
                param['terms[' + index + '].column'] = field;
                var mapping = queryTypeMapper[fieldCfg.queryType];
                if (mapping) {
                    param['terms[' + index + '].termType'] = mapping.value;
                    if (mapping.helper) {
                        value = mapping.helper(value);
                    }
                } else {
                    param['terms[' + index + '].termType'] = fieldCfg.queryType;
                }
                param['terms[' + index + '].value'] = value;
                index++;
            }
            param.includes = includes + "";
            grid.load(param);
        };
        mini.parse();
        if (!grid) {
            grid = mini.get('grid');
            bindDefaultAction(grid);
            grid.on("load", function (data) {
                mini.showTips({
                    content: "成功加载" + data.data.length + "条数据",
                    state: 'success',
                    x: 'right',
                    y: 'top',
                    timeout: 2000
                });
            });
        }
        grid.setUrl(Request.BASH_PATH + cfg.api);
        grid.setColumns(cfg.grid.columns);
        if (includes.indexOf("area_id") != -1) {
            grid.setSortField("area_id");
        }
        on("beforeLoad")({grid: grid, param: defaultQueryParam, parser: tmp});
        if (pageConfig.autoLoad != false) {
            search();
        }
    }

    function initFromServer() {
        function initCache(moduleMeta, formMeta) {
            var cache = {};
            var meta = JSON.parse(moduleMeta.meta);

            var searchConfig = createSearchHtml(meta.queryPlanConfig, formMeta);
            cache.id = moduleMeta.id;
            cache.module = moduleMeta.moduleId;
            cache.api = meta.table_api;
            cache.info_page = meta.info_page;
            cache.save_page = meta.save_page;
            cache.search = searchConfig;
            cache.grid = createGridConfig(meta.queryTableConfig, meta);
            cache.script = meta.script;
            cache.toolBar = createToolBar(getToolBarConfig(moduleMeta, meta, formMeta));
            parsePage(cache);
            if (localStoreEnable) {
                store.set("meta-cache:" + key, cache);
            }
            //$('#searchForm').html(searchFormHtml);
            // console.log(searchFormHtml);
        }

        Request.get("module-meta/" + key + "/single", function (res) {
            if (res.success) {
                var moduleMeta = JSON.parse(res.data.meta);
                console.log(moduleMeta);
                var name = moduleMeta.dynForm;
                var version = moduleMeta.dynFormVersion;
                if (localStoreEnable)
                    store.set(getMetaCacheKey(key), {form: name, ver: version, md5: res.data.md5});
                if (name) {
                    var url = "dyn-form/" + (version == 0 ? "deployed" : version) + "/" + name + "/";
                    Request.get(url, function (res2) {
                        if (res2.success) {
                            if (localStoreEnable)
                                store.set(getFormCacheKey(key, version), res2.data.release);
                            initCache(res.data, res2.data);
                        } else {
                            showTips(res.message, "danger");
                        }
                    });
                } else {
                    initCache(res.data, null);
                }
            }
        });
    }

    function initFromCache() {
        var cache;
        if (localStoreEnable)
            cache = store.get("meta-cache:" + key);
        if (!cache) {
            initFromServer();
        } else {
            parsePage(cache)
        }
    }

    tmp.init = function () {
        checkCached(function (cached) {
            if (!cached)initFromServer();
            else  initFromCache();
        });
    }
    return tmp;
};