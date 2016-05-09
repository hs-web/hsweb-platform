${code!'999'}:${message!'unknow'}</br>
<#import "global.ftl" as global />
<#if code==401>
    <script type="text/javascript">
        window.location.href="<@global.basePath/>admin/login.html?uri="+encodeURI(window.location.href);
    </script>
</#if>