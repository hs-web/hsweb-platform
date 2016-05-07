package org.hsweb.platform.ui;

import org.hsweb.web.core.authorize.ExpressionScopeBean;
import org.hsweb.web.core.authorize.annotation.Authorize;
import org.hsweb.web.core.utils.WebUtil;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-8.
 */
@Controller
public class PageViewController implements ExpressionScopeBean {

    @RequestMapping(value = "/admin/login.html", method = RequestMethod.GET)
    public ModelAndView login() {
        return  new ModelAndView("admin/login");
    }

    @RequestMapping(value = "/admin/**/*.html", method = RequestMethod.GET)
    @Authorize(expression = "#user.username=='admin'||#user.getModuleByUri(#pageViewController.getUri(#request))!=null")
    public ModelAndView view(HttpServletRequest request,
                             @RequestParam(required = false) Map<String, Object> param) {
        String path = getUri(request);
        if (path.contains("."))
            path = path.split("[.]")[0];
        ModelAndView modelAndView = new ModelAndView(path);
        modelAndView.addObject("param", param);
        modelAndView.addObject("absPath", WebUtil.getBasePath(request));
        return modelAndView;
    }

    public String getUri(HttpServletRequest request) {
        String path = request.getRequestURI();
        String content = request.getContextPath();
        if (path.startsWith(content)) {
            path = path.substring(content.length() + 1);
        }
        return path;
    }
}
