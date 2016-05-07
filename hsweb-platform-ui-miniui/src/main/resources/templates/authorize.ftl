<#function role role>
    <#return user??&&user.hasAccessRole(role)/>
</#function>

<#function module module action...>
    <#return user??&&user.hasAccessModuleAction(module,action)/>
</#function>