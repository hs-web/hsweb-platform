<#--插件-->
<#macro plugins(path)>
    <#if path?ends_with('js')>
    <script src="/ui/plugins/${path}" type="text/javascript"></script>
    </#if>
    <#if path?ends_with('css')>
    <link href="/ui/plugins/${path}"  rel="stylesheet" type="text/css" ></link>
    </#if>
</#macro>
<#--资源文件-->
<#macro resources(path)>
<script src="/ui/resources/${path}"></script>
</#macro>
<#--jquery-cdn-->
<#macro jquery>
<script src="http://code.jquery.com/jquery-1.12.3.min.js" integrity="sha256-aaODHAgvwQW1bFOGXMeX+pC4PZIPsvn2h1sArYOhgXQ=" crossorigin="anonymous"></script>
</#macro>
<#--miniui-->
<#macro miniui>
    <@jquery />
    <@plugins "miniui/miniui.js" />
    <@plugins "miniui/themes/default/miniui.css" />
    <@plugins "miniui/themes/icons.css" />
</#macro>
