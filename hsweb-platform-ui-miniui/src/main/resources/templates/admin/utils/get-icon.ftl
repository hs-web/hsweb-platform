<#import "../../global.ftl" as global />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
<@global.importMiniui/>
</head>
<body>
<div id="icon-list" style="width: 80%;margin: auto;text-align: center;height: 280px">

</div>
<div  style="width: 80%;margin: auto;text-align: center">
    <a href="javascript:void(0)" onclick="layout(--nowPage)">上一页</a>
    &nbsp;&nbsp;&nbsp;
    <a  href="javascript:void(0)" onclick="layout(++nowPage)">下一页</a>
</div>
</body>
</html>
<@global.importRequest/>
<script type="text/javascript">
    var iconList = [];
    loadIcon();
    var nowPage=0;
    function loadIcon() {
        Request.get("icon-list", {}, function (e) {
            if (e) {
                iconList = e
            }
            layout(0);
        });
    }
    function layout(page) {
        var html = "";
        var newLineIndex = 15;
        var pageSize = 15 * 10 - 1;
        var index=0;
        if(page<0)page=nowPage=Math.ceil(iconList.length/pageSize)-1;

        if(Math.ceil(iconList.length/pageSize)<=page){
           // showTips("没有更多图标了!")
            page= nowPage=0;
        }
        for (var i = page*pageSize; i < iconList.length; i++) {
            var e = iconList[i];
            if (i >  page*pageSize+pageSize)break;
            if (index != 0 && index % newLineIndex == 0)html += "<br/>";
            html += "<a class='mini-button' iconCls='"+ e +"' plain='true' onclick=\"closeWindow('"+e+"')\"> </a>";
            html += "&nbsp;";
            index++;
        }
        $("#icon-list").html(html);
        mini.parse();
    }

</script>
