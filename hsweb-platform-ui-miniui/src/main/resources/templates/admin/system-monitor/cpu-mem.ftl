<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importWebsocket/>
<@global.importPlugin "echarts/echarts.min.js"/>
    <style type="text/css">
        #cpu {
            width: 100%;
            height: 300px;;
        }

        #jvmMem {
            width: 48%;
            height: 600px;
            float: left;
        }

        #systemMem {
            width: 48%;
            height: 600px;;
            float: left;
        }
    </style>
</head>
<body>
<div id="cpu"></div>
<div id="jvmMem"></div>
<div id="systemMem"></div>
</body>
</html>
<script type="text/javascript">
    var cpuOption = {
        title: {
            text: "CPU使用率",
            subtext: ""
        },
        tooltip: {
            trigger: "axis"
        },
        toolbox: {
        },
        calculable: false,
        xAxis: [
            {
                type: "category",
                boundaryGap: false,
                data: [],
                splitLine: {
                    show: false
                }
            }
        ],
        yAxis: [
            {
                type: "value",
                name: "%",
                position: "left",
                max:100,
                splitLine: {
                    show: true
                }
            }
        ],
        series: [
            {
                name: "使用率",
                type: "line",
                detail: {formatter: '{value}%'},
                data: [],
                smooth: true,
                areaStyle: {
                    normal: {
                        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                            offset: 0,
                            color: 'rgb(255, 12, 0)'
                        }, {
                            offset: 1,
                            color: 'rgb(112, 255, 0)'
                        }])
                    }
                }
            }
        ]
    };
    for (var i = 0; i < 50; i++) {
        cpuOption.xAxis[0].data.push("");
        cpuOption.series[0].data.push(0);
    }

    var jvmMem = {
        tooltip: {
            formatter: "{a} <br/>{b} : {c}%"
        },
        toolbox: {},
        series: [
            {
                name: '内存使用率',
                type: 'gauge',
                detail: {formatter: '{value}%'},
                data: [{value: 0, name: 'jvm内存使用率'}]
            }
        ]
    };

    var sysMem = {
        tooltip: {
            formatter: "{a} <br/>{b} : {c}%"
        },
        toolbox: {},
        series: [
            {
                name: '系统内存',
                type: 'gauge',
                detail: {formatter: '{value}%'},
                data: [{value: 0, name: '系统内存'}]
            }
        ]
    };
    var cpuChart = echarts.init(document.getElementById('cpu'));
    var jvmMemChart = echarts.init(document.getElementById('jvmMem'));
    var systemMemChart = echarts.init(document.getElementById('systemMem'));
    jvmMemChart.setOption(jvmMem);
    cpuChart.setOption(cpuOption);
    systemMemChart.setOption(sysMem);

    Socket.open(function (socket) {
        window.onunload = function (e) {
            socket.sub("system-monitor", {type: "cancel"});
        }
        socket.sub("system-monitor", {type: "cpu"}, "cpuRender");
        socket.sub("system-monitor", {type: "mem"}, "memRender");
        socket.on("cpuRender", function (obj) {
            cpuOption.xAxis[0].data.shift();
            cpuOption.series[0].data.shift();
            var date = new Date();
            var cb = 0;
            for (var i = 0; i < obj.length; i++) {
                var cpuInfo = obj[i];
                cb += cpuInfo.perc.combined;
            }
            cpuOption.xAxis[0].data.push(date.getMinutes() + "-" + date.getSeconds());
            cpuOption.series[0].data.push(((cb / 4) * 100).toFixed(2) - 0);
            cpuChart.setOption(cpuOption, true);
        });
        socket.on("memRender", function (obj) {
            var total = (obj['jvmTotal'] - obj['jvmFree']) / obj['jvmTotal'];
            total = total * 100;
            jvmMem.series[0].data[0].value = (total).toFixed(2) - 0;
            jvmMem.series[0].data[0].name ="jvm内存("+ bytesToSize(obj['jvmTotal'])+")";
            jvmMemChart.setOption(jvmMem, true);

            total = parseFloat(obj['UsedPercent']);
            sysMem.series[0].data[0].value = (total).toFixed(2) - 0;
            sysMem.series[0].data[0].name="系统内存("+ bytesToSize(parseInt(obj['Total']))+")";
            systemMemChart.setOption(sysMem, true);
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
</script>