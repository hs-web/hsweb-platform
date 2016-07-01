package org.hsweb.platform.ui.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import org.hsweb.commons.StringUtils;
import org.hsweb.ezorm.param.Term;
import org.hsweb.platform.ui.service.ModuleMetaParserService;
import org.hsweb.web.bean.common.QueryParam;
import org.hsweb.web.bean.po.module.ModuleMeta;
import org.hsweb.web.bean.po.role.UserRole;
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
                .map(UserRole::getRoleId)
                .collect(Collectors.toList());
        ModuleMeta moduleMeta;
        if (StringUtils.isNullOrEmpty(metaId)) {
            QueryParam param = QueryParam.build();
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

    @RequestMapping("/{metaId}/{type}.html")
    @Authorize
    public ModelAndView savePage(@PathVariable("metaId") String metaId,
                                 @PathVariable("type") String type,
                                 @RequestParam(value = "id",defaultValue = "") String id) throws Exception {
        User user = WebUtil.getLoginUser();
        List<String> roleId = user.getUserRoles().stream()
                .map(userRole -> userRole.getRoleId())
                .collect(Collectors.toList());
        QueryParam param = new QueryParam();
        param.nest().and("id", metaId);
        Term term = param.nest();
        roleId.forEach(rId -> term.or("roleId$LIKE", "%," + rId + ",%"));
        term.or("roleId$ISNULL", true).or("roleId$EMPTY", true);
        ModuleMeta moduleMeta = moduleMetaService.selectSingle(param);
        if (moduleMeta == null) {
            throw new NotFoundException("模块不存在或者无访问权限!");
        }
        JSONObject jsonObject = JSON.parseObject(moduleMeta.getMeta());
        String formName = jsonObject.getString("dynForm");
        Object version = jsonObject.getOrDefault("dynFormVersion", 0);
        ModelAndView modelAndView = new ModelAndView("admin/dyn-form/" + type);
        modelAndView.addObject("name", formName);
        modelAndView.addObject("version", version);
        modelAndView.addObject("id", id);
        return modelAndView;
    }

    @RequestMapping(value = "/create", method = RequestMethod.POST)
    @ResponseBody
    public ResponseMessage autoCreate(@RequestBody String formId) throws Exception {
        String id = moduleMetaParserService.autoCreateModule(formId);
        return ResponseMessage.ok(id);
    }

}
