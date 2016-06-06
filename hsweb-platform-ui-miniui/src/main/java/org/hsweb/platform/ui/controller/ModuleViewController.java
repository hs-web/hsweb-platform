package org.hsweb.platform.ui.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import org.hsweb.ezorm.param.Term;
import org.hsweb.platform.ui.service.ModuleMetaParserService;
import org.hsweb.web.bean.common.QueryParam;
import org.hsweb.web.bean.po.module.ModuleMeta;
import org.hsweb.web.bean.po.user.User;
import org.hsweb.web.core.authorize.annotation.Authorize;
import org.hsweb.web.core.exception.NotFoundException;
import org.hsweb.web.core.message.ResponseMessage;
import org.hsweb.web.core.utils.WebUtil;
import org.hsweb.web.service.module.ModuleMetaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;
import org.webbuilder.utils.common.StringUtils;

import javax.annotation.Resource;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Created by zhouhao on 16-5-11.
 */
@Controller
@RequestMapping("/module-view")
public class ModuleViewController {

    @Resource
    private ModuleMetaService moduleMetaService;

    @Autowired
    private ModuleMetaParserService moduleMetaParserService;

    @RequestMapping("/{key}/list.html")
    @Authorize
    public ModelAndView listPage(@PathVariable("key") String key, String metaId) throws Exception {
        User user = WebUtil.getLoginUser();
        List<String> roleId = user.getUserRoles().stream()
                .map(userRole -> userRole.getRoleId())
                .collect(Collectors.toList());
        ModuleMeta moduleMeta;
        if (StringUtils.isNullOrEmpty(metaId)) {
            QueryParam param = new QueryParam();
            param.nest().and("key", key).or("module_id", key);
            Term term = param.nest();
            roleId.forEach(id -> term.or("roleId$LIKE", "%," + id + ",%"));
            term.or("roleId$ISNULL", true).or("roleId$EMPTY", true);
            moduleMeta = moduleMetaService.selectSingle(param);
        } else {
            moduleMeta = moduleMetaService.selectByPk(metaId);
        }
        if (moduleMeta == null) throw new NotFoundException("方案未找到!");
        JSONObject meta = JSON.parseObject(moduleMeta.getMeta());
        String queryPlanHtml = moduleMetaParserService.getQueryFormHtml(meta.getString("dynForm"), (List) meta.getJSONArray("queryPlanConfig"));

        ModelAndView modelAndView = new ModelAndView("admin/module-view/list");
        modelAndView.addObject("meta", moduleMeta);
        modelAndView.addObject("queryPlanConfig", queryPlanHtml);
        return modelAndView;
    }

    @RequestMapping(value = "/create", method = RequestMethod.POST)
    @ResponseBody
    public ResponseMessage autoCreate(@RequestBody String formId) throws Exception {
        String id = moduleMetaParserService.autoCreateModule(formId);
        return ResponseMessage.ok(id);
    }

}
