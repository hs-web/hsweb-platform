package org.hsweb.platform.ui.controller;

import org.hsweb.commons.StringUtils;
import org.hsweb.web.bean.po.user.User;
import org.hsweb.web.core.authorize.ExpressionScopeBean;
import org.hsweb.web.core.authorize.annotation.Authorize;
import org.hsweb.web.core.logger.annotation.AccessLogger;
import org.hsweb.web.core.message.ResponseMessage;
import org.hsweb.web.service.config.ConfigService;
import org.slf4j.Logger;
import org.springframework.aop.aspectj.AspectJAdviceParameterNameDiscoverer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.DefaultParameterNameDiscoverer;
import org.springframework.core.MethodParameter;
import org.springframework.util.ClassUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.PostConstruct;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.*;
import java.util.function.Supplier;
import java.util.stream.Collectors;

import static org.hsweb.web.core.message.ResponseMessage.ok;

/**
 * @author zhouhao
 */
@RestController
@AccessLogger("ide")
@RequestMapping("/ide")
public class IdeController {
    Object autoCompleteData;

    @Autowired(required = false)
    protected Map<String, ExpressionScopeBean> expressionScopeBeanMap;

    private List<Map<String, Object>> getClassCompleteData(String name, Class clazz) {
        List<Map<String, Object>> completeData = new ArrayList<>();
        if (clazz == null) return completeData;
        Method[] methods = clazz.getDeclaredMethods();
        for (Class aClass : clazz.getInterfaces()) {
            completeData.addAll(getClassCompleteData(name, aClass));
        }
        Class superClass = clazz.getSuperclass();
        if (superClass != null && superClass != Object.class) {
            superClass=ClassUtils.getUserClass(superClass);
            completeData.addAll(getClassCompleteData(name, superClass));
        }
        for (Method method : methods) {
            if (!Modifier.isPublic(method.getModifiers()) && !method.isDefault()) continue;
            Map<String, Object> data = new LinkedHashMap<>();
            StringBuilder value = new StringBuilder();
            StringBuilder caption = new StringBuilder();
            value.append(name).append(".").append(method.getName()).append("(");
            caption.append(name).append(".").append(method.getName()).append("(");
            for (int i = 0, count = method.getParameterCount(); i < count; i++) {
                MethodParameter methodParameter = new MethodParameter(method, i);
                methodParameter.initParameterNameDiscovery(new DefaultParameterNameDiscoverer());
                if (i > 0) {
                    value.append(",");
                    caption.append(",");
                }
                String paramName = methodParameter.getParameterName();
                if (paramName == null) {
                    paramName = StringUtils.toLowerCaseFirstOne(methodParameter.getParameterType().getSimpleName());
                }
                value.append(paramName);
                caption.append(methodParameter.getParameterType().getSimpleName())
                        .append(" ")
                        .append(paramName);
            }
            value.append(");");
            caption.append(")");
            data.put("caption", caption.toString());
            data.put("value", value.toString());
            data.put("meta", method.getReturnType().getSimpleName());
            completeData.add(data);
        }
        return completeData;
    }

    @PostConstruct
    public void init() {
        Set<Map<String, Object>> completeData = expressionScopeBeanMap.entrySet().stream().map(entry -> {
            Class clazz = ClassUtils.getUserClass(entry.getValue());
            return getClassCompleteData(entry.getKey(), clazz);
        }).flatMap(List::stream).collect(Collectors.toSet());
        completeData.addAll(getClassCompleteData("logger", Logger.class));
        completeData.addAll(getClassCompleteData("GetLoginUser", ((Supplier<User>) () -> null).getClass()));

        autoCompleteData = completeData;
    }

    @RequestMapping(value = "/auto-complete-data", method = RequestMethod.GET)
    @AccessLogger("获取自动补全数据")
    @Authorize(module = "ide")
    public ResponseMessage autoCompleteData() {
        return ok(autoCompleteData);
    }
}
