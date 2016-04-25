<#macro basePath>/</#macro>
<#--插件-->
<#macro importPlugin(pathList...)>
    <#list pathList as path>
        <#if path?ends_with('js')>
        <script src="<@basePath/>ui/plugins/${path}" type="text/javascript"></script>
        </#if>
        <#if path?ends_with('css')>
        <link href="<@basePath/>ui/plugins/${path}" rel="stylesheet" type="text/css"></link>
        </#if>
    </#list>
</#macro>

<#--资源文件-->
<#macro importRequest()>
    <@importPlugin "ajax/Request.js" />
<script type="text/javascript">Request.BASH_PATH = "/";</script>
</#macro>
<#macro importFontIcon>
    <@resources "icons/css/font-awesome.min.css"/>
</#macro>
<#--资源文件-->
<#macro resources(paths...)>
    <#list paths as path>
        <#if path?ends_with('js')>
        <script src="<@basePath/>ui/resources/${path}" type="text/javascript"></script>
        </#if>
        <#if path?ends_with('css')>
        <link href="<@basePath/>ui/resources/${path}" rel="stylesheet" type="text/css"></link>
        </#if>
    </#list>
</#macro>
<#--jquery-cdn-->
<#macro importJquery>
<#--http://code.jquery.com/jquery-1.12.3.min.js-->
<script src="http://libs.baidu.com/jquery/1.11.1/jquery.min.js"></script>
</#macro>
<#--miniui-->
<#macro importMiniui themes...>
    <@importJquery />
    <@importPlugin "miniui/miniui.js","miniui/themes/default/miniui.css","miniui/themes/icons.css" />
    <#list themes as thme >
        <@importPlugin "miniui/themes/"+thme+"/skin.css"/>
    </#list>
</#macro>
<#--ueditor-->
<#macro importUeditor>
<script type="text/javascript" charset="utf-8">
    window.UEDITOR_HOME_URL = location.protocol + '//' + document.domain + (location.port ? (":" + location.port) : "") + "/ui/plugins/ueditor/";
</script>
    <@importPlugin "ueditor/ueditor.config.js"
    ,"ueditor/ueditor.all.min.js"
    , "ueditor/themes/default/css/ueditor.min.css"
    , "ueditor/lang/zh-cn/zh-cn.js"
    />
</#macro>

<#macro importUeditorParser>
<script type="text/javascript" charset="utf-8">
    window.UEDITOR_HOME_URL = "<@basePath/>ui/plugins/ueditor/";
</script>
    <@importPlugin "ueditor/ueditor.parse.js"
    ,"ueditor/themes/default/dialogbase.css"
    />
</#macro>

<#macro pluginUrl(uri)>
    <@basePath/>ui/plugins/${uri}
</#macro>

<#macro api(uri)>
    <@basePath/>${uri}
</#macro>