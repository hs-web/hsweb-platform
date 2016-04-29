package org.hsweb.platform.controller;

import org.hsweb.web.bean.common.QueryParam;
import org.hsweb.web.bean.po.module.Module;
import org.hsweb.web.controller.GenericController;
import org.hsweb.web.message.ResponseMessage;
import org.hsweb.web.mybatis.plgins.pager.PagerInterceptor;
import org.hsweb.web.service.module.ModuleService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

/**
 * Created by zhouhao on 16-4-13.
 */
@RestController
@RequestMapping("/userModule")
public class UserModuleController {
    @Resource
    public ModuleService moduleService;

    @RequestMapping
    public ResponseMessage userModule() throws Exception {
        String[] includes = {
                "name", "u_id", "p_id"
        };
        return ResponseMessage.ok(
                moduleService.select(new QueryParam().includes(includes).orderBy("sort_index"))
        ).include(Module.class, includes).onlyData();
    }
}
