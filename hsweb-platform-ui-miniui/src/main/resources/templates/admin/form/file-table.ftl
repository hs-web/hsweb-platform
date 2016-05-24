<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importFontIcon/>
    <style>
        html, body {
            width: 100%;
            height: 100%;
            border: 0;
            margin: 0;
            padding: 0;
            overflow: hidden;
        }

        .action-edit {
            color: green;
            cursor: pointer;
        }

        .action-remove {
            color: red;
            cursor: pointer;
        }

        .action-enable {
            color: green;
            cursor: pointer;
        }

        .action-icon {
            width: 16px;
            height: 16px;
            display: inline-block;
            background-position: 50% 50%;
            cursor: pointer;
            line-height: 16px;
        }

        .action-span {
            font-size: 16px;
            cursor: pointer;
            display: inline-block;
            line-height: 16px;
        }
    </style>
</head>
<body>
<div class="mini-fit" style="height:100px;">
    <a class="mini-button" iconCls="icon-add" plain="true" style="display: none" id="addButton" onclick="uploadFile()"></a>

    <div id="grid" class="mini-datagrid" style="width:100%;height:80%;" showPager="false" allowCellEdit="true"
         allowCellSelect="true">
        <div property="columns"></div>
    </div>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    mini.parse();
    var grid = mini.get('grid');
    var defaultConfig = {
        headerAlign: "center", align: "center"
    };
    var meta;
    var data;
    var defaultColumns = [
        {field: "name", header: "文件名", editor: {type: "textbox"}}
    ];
    grid.set({
        columns: defaultColumns
    });
    document.oncontextmenu=function(){return false;};
    window.getData = function () {
        var newData=[];
        var data= grid.getData();
        $(data).each(function(i,e){
            var d={};
            for(var f in e){
                if(f!="_id"&&f!="_uid"){
                    d[f]=e[f];
                }
            }
            newData.push(d);
        });
        return newData;
    }
    window.setData = function (data) {
        grid.setData(data);
    }
    window.init = function (m, d) {
        meta = mini.clone(m);
        data = d;
        if (meta.canAddRow + "" == 'true') {
            $('#addButton').show();
        } else {
            grid.setHeight("100%");
        }
        grid.set({
            columns: parseColumns(mini.decode(meta.columns))
        });
        initData();
    }
    function initData() {
        if (!data) {
            var dft = mini.decode(meta.defaultTableData);
            data = [];
            $(dft).each(function (i, e) {
                data.push(mini.decode(e.data));
            });
        }
        grid.setData(data);
    }
    function parseColumns(columns) {
        var newData = [];
        $(columns).each(function (i, e) {
            var column = e;
            for (var def in defaultConfig) {
                if (!column[def])column[def] = defaultConfig[def];
            }
            if (column['property']) {
                var properties = mini.decode(column['property']);
                for (var prop in properties) {
                    column[prop] = properties[prop];
                }
                delete column['property'];
            }
            newData.push(column);
        });
        newData.push({header: "状态", width: 20, renderer: renderStatus, headerAlign: "center", align: "center"});
        newData.push({header: "操作", width: 20, renderer: renderAction, headerAlign: "center", align: "center"});
        return newData;
    }
    function createActionButton(text, action, icon) {
        return '<span class="action-span" title="' + text + '" onclick="' + action + '">' +
                '<i class="action-icon ' + icon + '"></i>' + "" //text
                + '</span>&nbsp;';
    }
    function renderStatus(e){
        var row = e.record;
        if(row&&row.fileList&&row.fileList.length>0){
            return "已上传,文件数量:"+row.fileList.length;
        }else{
            return "未上传";
        }
    }
    function renderAction(e) {
        var html = "";
        html += createActionButton("上传文件", "uploadFile(" + e.record._id + ")", "icon-upload");
        if (meta.canRemoveRow + "" == 'true') {
            html += createActionButton("删除本行", "removeRow(" + e.record._id + ")", "icon-remove");
        }
        return html;
    }
    function uploadFile(_id) {
        openFileUploader("*/*", "上传文件", function (e) {
            if (_id) {
                if (e.length > 0) {
                    var row = grid.findRow(function (row) {
                        if (row._id == _id)return true;
                    });
                    if (row) {
                        row.fileList = e;
                        grid.updateRow(row);
                    }
                }
            }else{
                grid.addRow({fileList:e});
            }
        });
    }
    function removeRow(_id) {
        var row = grid.findRow(function (row) {
            if (row._id == _id)return true;
        });
        grid.removeRow(row, true);
    }
</script>
