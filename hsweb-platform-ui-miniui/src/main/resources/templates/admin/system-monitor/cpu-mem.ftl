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
                boundaryGap: [0, '100%'],
                splitLine: {
                    show: false
                }
            }
        ],
        series: [
            {
                name: "使用率",
                type: "line",
                detail: {formatter: '{value}%'},
                data: [],
                smooth: false,
                areaStyle: {
                    normal: {
                        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                            offset: 0,
                            color: 'rgb(255, 158, 68)'
                        }, {
                            offset: 1,
                            color: 'rgb(255, 70, 131)'
                        }])
                    }
                },
            }
        ]
    };
    for (var i = 0; i < 100; i++) {
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
                name: '内存使用率',
                type: 'gauge',
                detail: {formatter: '{value}%'},
                data: [{value: 0, name: '系统内存使用率'}]
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
            cpuOption.series[0].data.push((cb / 4 * 100).toFixed(2) - 0);
            cpuChart.setOption(cpuOption, true);
        });
        socket.on("memRender", function (obj) {
            var total = (obj['jvmTotal'] - obj['jvmFree']) / obj['jvmTotal'];
            total = total * 100;
            jvmMem.series[0].data[0].value = (total).toFixed(2) - 0;
            jvmMemChart.setOption(jvmMem, true);

            total = parseFloat(obj['UsedPercent']);
            sysMem.series[0].data[0].value = (total).toFixed(2) - 0;
            systemMemChart.setOption(sysMem, true);
        });
    });
</script>