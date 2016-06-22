<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
<@global.importPlugin "webuploader/webuploader.css"/>
<@global.importPlugin "webuploader/webuploader.min.js"/>
</head>
<body>
<div style="width: 80%;height: 300px;margin: auto;">
    <a id="addFile">添加文件</a>
    <a id="start" class="webuploader-pick" onclick="startUpload()">开始上传</a>
    <a id="help" class="webuploader-pick" onclick="mini.alert('文件支持秒传,拖拽,粘贴！')">查看帮助</a>

    <div id="grid" class="mini-datagrid" style="width:100%;height:100%;"
         allowCellEdit="true" allowCellSelect="true" idField="id" allowResize="false" showPager="false">
        <div property="columns">
            <div type="indexcolumn"></div>
            <div field="name" width="120" headerAlign="center" align="center">文件名
                <input property="editor" class="mini-textbox"/>
            </div>
            <div field="size" width="80" headerAlign="center" align="center">大小</div>
            <div field="status" width="80" headerAlign="center" align="center">状态</div>
            <div field="action" width="80" headerAlign="center" renderer="renderAction" align="center">操作</div>
        </div>
    </div>
</div>
<br/><br/>

<div style="width: 180px;margin: auto">
    <a class="mini-button" iconCls="icon-ok" onclick="ok()" plain="true">确定</a>
    <a class="mini-button" iconCls="icon-remove" onclick="closeWindow([])" plain="true">返回</a>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    if (!WebUploader.Uploader.support()) {
        mini.alert("您的浏览器太旧不支持文件上传!<br/>" +
                "如果你使用的是IE浏览器,请<a href='https://www.baidu.com/s?wd=ie%E6%B5%8F%E8%A7%88%E5%99%A8%E6%9B%B4%E6%96%B0flash%20player' target='_blank'>升级flash版本</a>!");
        throw new Error("");
    }
    mini.parse();
    var accepts = {
        img: {
            title: '图片',
            extensions: 'gif,jpg,jpeg,bmp,png',
            mimeTypes: 'image/*'
        },
        excel: {
            title: 'EXCEL',
            extensions: 'xls,xlsx',
            mimeTypes: 'application/excel'
        },
        word: {
            title: 'word',
            extensions: 'doc,docx',
            mimeTypes: '*/*'
        }, json: {
            title: 'JSON',
            extensions: 'json',
            mimeTypes: 'application/json'
        },
        all: {
            title: '文件',
            extensions: '*',
            mimeTypes: '*/*'
        }
    };
    var accept = "${param.accept!'all'}";
    var maxFileSize = 60 * 1024 * 1024;

    var grid = mini.get('grid');
    var uploader = WebUploader.create({
        swf: Request.BASH_PATH + 'ui/plugins/webuploader/Uploader.swf',
        server: "<@global.api 'file/upload'/>",
        pick: '#addFile',
        compress: false,
        dnd: document.body,
        paste: document.body,
        accept: accepts[accept],
        resize: false
    });
    function getRow(id) {
        return grid.findRow(function (row) {
            if (row.id == id)return true;
        });
    }
    uploader.on('fileQueued', function (file) {
        if (maxFileSize <= file.size) {
            uploader.removeFile(file.id);
            showTips("文件大小不能超过:" + bytesToSize(maxFileSize));
            return;
        }
        grid.addRow({id: file.id, name: file.name, status: "等待上传", size: bytesToSize(file.size)});
        var row = getRow(file.id);
        var md5File = uploader.md5File(file);
        if (md5File)
            md5File
                // 及时显示进度
                    .progress(function (percentage) {
                        var range = ( percentage * 100).toFixed(1);
                        row.status = "检测文件中" + range + "%";
                        grid.updateRow(row);
                    })
                // 完成
                    .then(function (val) {
                        row.md5 = val;
                        Request.get("resources/" + val, {}, function (data) {
                            if (data && data.success) {
                                uploader.removeFile(file.id);
                                row.status = "文件秒传成功";
                                row.resourceId = data.data.id;
                                grid.acceptRecord(row);
                                grid.updateRow(row);
                            } else {
                                row.status = "等待上传";
                                grid.updateRow(row);
                            }
                        });
                    });
    });
    function bytesToSize(bytes) {
        if (bytes === 0) return '0 B';
        if (bytes < 1024)return bytes + 'b';
        var k = 1024, // or 1024
                sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
                i = Math.floor(Math.log(bytes) / Math.log(k));
        return (bytes / Math.pow(k, i)).toPrecision(3) + ' ' + sizes[i];
    }
    function startUpload() {
        uploader.upload();
    }
    uploader.on('uploadProgress', function (file, percentage) {
        var range = ( percentage * 100).toFixed(1);
        var row = getRow(file.id);
        if (percentage < 1) {
            row.status = "上传中" + range + "%";
        } else {
            row.status = "等待服务器回应...";
        }
        grid.updateRow(row);
    });
    uploader.on('uploadSuccess', function (file, message) {
        var row = getRow(file.id);
        console.log(message);
        if (message && message.success && message.data.length > 0) {
            row.status = "上传成功!";
            row.resourceId = message.data[0].id;
            grid.acceptRecord(row);
        } else {
            row.status = "上传失败!";
            grid.updateRow(row);
        }

    });

    uploader.on('uploadError', function (file) {
        var row = getRow(file.id);
        //解决ie下,由于mediaType问题导致文件上传成功,但是抛出异常的问题
        if (row.md5) {
            Request.get("resources/" + row.md5, {}, function (data) {
                if (data && data.success) {
                    uploader.removeFile(file.id);
                    row.status = "上传成功!";
                    row.resourceId = data.data.id;
                    grid.acceptRecord(row);
                    grid.updateRow(row);
                } else {
                    row.status = "上传失败!";
                    grid.updateRow(row);
                }
            });
        } else {
            row.status = "上传失败";
            grid.updateRow(row);
        }
    });

    uploader.on('uploadComplete', function (file) {
    });

    function ok() {
        var data = grid.getData();
        var list = [];
        for (var i = 0; i < data.length; i++) {
            if (!data[i].resourceId) {
                showTips("文件:" + data[i].name + " 还未上传!");
                return;
            }
            list.push({name: data[i].name, id: data[i].resourceId, size: data[i].size});
        }
        closeWindow(list);
    }

    function removeFile(id) {
        var row = getRow(id);
        try {
            uploader.removeFile(id);
        } catch (e) {
        }
        grid.removeRow(row);
    }
    function renderAction(e) {
        return "<a href='javascript:void(0)' onclick=\"removeFile('" + e.record.id + "')\">移除</a>";
    }

</script>