package org.hsweb.platform.ui.controller;

import org.hsweb.commons.MD5;
import org.hsweb.web.core.authorize.annotation.Authorize;
import org.hsweb.web.core.utils.WebUtil;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-8.
 */
@Controller
public class PageViewController {

    @RequestMapping(value = "/admin/login.html", method = RequestMethod.GET)
    public ModelAndView login(String uri) throws UnsupportedEncodingException {
        ModelAndView modelAndView = new ModelAndView("admin/login");
        if (uri != null)
            modelAndView.addObject("uri", uri);
        modelAndView.addObject("absPath", WebUtil.getBasePath(WebUtil.getHttpServletRequest()));
        return modelAndView;
    }

    @RequestMapping(value = "/admin/**/*.html", method = RequestMethod.GET)
    @Authorize
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
