package org.hsweb.platform.ui.controller;

import org.hsweb.web.core.authorize.annotation.Authorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

/**
 * Created by zhouhao on 16-5-12.
 */
@Controller
@RequestMapping("/dyn-form")
public class DynFomViewController {

    @RequestMapping(value = "/{name}/save.html")
    @Authorize
    public ModelAndView save(@PathVariable("name") String name,
                             @RequestParam(value = "id", required = false) String id) throws Exception {
        ModelAndView modelAndView = new ModelAndView("admin/dyn-form/save");
        modelAndView.addObject("name",name);
        modelAndView.addObject("id", id);
        return modelAndView;
    }

    @RequestMapping(value = "/{name}/info.html")
    @Authorize
    public ModelAndView info(@PathVariable("name") String name,
                             @RequestParam(value = "id", required = false) String id) throws Exception {
        ModelAndView modelAndView = new ModelAndView("admin/dyn-form/info");
        modelAndView.addObject("name",name);
        modelAndView.addObject("id", id);
        return modelAndView;
    }
}
