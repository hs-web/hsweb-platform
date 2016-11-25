var tabs, meta, data, formData;
var readOnly = false;
var helper = {};
var tabSow = true;
function changeTabs() {
    if (tabSow) {
        tabs.setShowBody(false);
        tabSow = false;
        if (window.resizeWindow) {
            window.resizeWindow(100);
        }
    } else {
        tabs.setShowBody(true);
        tabSow = true;
        tabs.getActiveTab().helper.resize();
    }
}
window.get = function (name) {
    return helper[name];
}
window.setReadOnly = function () {
    readOnly = true;
}
window.validate = function () {
    for (var f in helper) {
        if (helper[f].validate && helper[f].validate() == false)return false;
    }
    return true;
}
window.getData = function (formData) {
    for (var f in helper) {
        var data = helper[f].getData ? helper[f].getData() : {};
        formData[f] = data;
    }
    return null;
}
window.setData = function (d, fData) {
    formData = fData;
    data = d;
    for (var e in helper) {
        if (fData[e]) {
            helper[e].setData(fData[e], d);
        }
    }
}
window.init = function (m) {
    mini.parse();
    tabs = mini.get('tabs');
    tabs.on('activechanged', function (e) {
        if (!tabSow) {
            changeTabs();
        }
        var tab = e.tab;
        if (tab.helper && tab.helper.resize) {
            tab.helper.resize();
        }
        if (tab.helper && tab.helper.window && tab.helper.window.search) {
            tab.helper.window.search();
        }
    });
    var tabConfig = m.tabConfig;
    if (tabConfig) {
        tabConfig = mini.decode(tabConfig);
        var showIndex = 0;
        $(tabConfig).each(function (i, e) {
            var show = true;
            if (e.condition) {
                var script = "(function(){return function(data,formData){" + e.condition + "}})()";
                try {
                    script = eval(script);
                    show = script(data, formData);
                } catch (e) {
                    if (console.log) {
                        console.log(e);
                    }
                }
                if (!show)return;
            }
            var scriptText = e.scriptText;

            function createWinInit(tabInfo, tab) {
                return function (e) {
                    var iframe = e.iframe;
                    if (iframe) {
                        var win = iframe.contentWindow;

                        function doInit() {
                            if (win) {
                                var resize;
                                var thisSize = 250;
                                win.resizeWindow = function (height) {
                                    resize = true;
                                    thisSize = height;
                                    if (window.resizeWindow)
                                        window.resizeWindow(height);
                                };
                                if (win.onInit) {
                                    win.onInit(data, formData, scriptText);
                                }
                                if (readOnly && win.setReadOnly) {
                                    win.setReadOnly();
                                }
                                var helper_this = {};
                                if (win.getData) {
                                    helper_this.getData = win.getData;
                                }
                                if (win.setData) {
                                    helper_this.setData = win.setData;
                                }
                                if (win.validate) {
                                    helper_this.validate = win.validate;
                                }
                                helper_this.window = win;
                                var property = tabInfo.field && tabInfo.field != "" ? tabInfo.field : tabInfo.title;
                                helper[property] = helper_this;
                                helper_this.resize = function () {
                                    if (window.resizeWindow)
                                        window.resizeWindow(thisSize);
                                }
                                tab.helper = helper_this;
                                if (formData && formData[property]) {
                                    helper[property].setData(formData[property], data);
                                }
                                window.setTimeout(function () {
                                    if (win.document.body) {
                                        if (!resize && window.resizeWindow) {
                                            thisSize = win.document.body.clientHeight + 50;
                                            window.resizeWindow(thisSize);
                                        }
                                    }
                                }, 500);
                            }
                        }

                        $(iframe).on("load", function () {
                            doInit();
                        });
                        doInit();
                    }
                };
            }

            var tab = {
                title: e.title, url: initUrl(e.url)
            };
            var onload = createWinInit(e, tab);
            tab.onload = onload;

            tabs.addTab(tab);
            if (showIndex == 0) {
                tabs.activeTab(tab);
            }
            showIndex++;
        });
        if (showIndex == 0) {
            if (window.hide) {
                window.hide();
            }
        }
    }
}
function initUrl(url) {
    if (url.indexOf("http") != 0) {
        url = Request.BASH_PATH + url;
    }
    var r = /\{(.+?)}/g;
    var matches = url.match(r);
    $(matches).each(function () {
        var group = this.substring(1, this.length - 1);
        var val = "";
        try {
            val = eval("(function(){return formData." + group + "})()");
        } catch (e) {
        }
        url = url.replace("{" + group + "}", val ? val : "");
    });
    return url;
}