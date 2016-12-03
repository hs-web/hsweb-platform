package org.hsweb.platform.ui.controller;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.hsweb.commons.StringUtils;
import org.hsweb.platform.generator.Generator;
import org.hsweb.platform.generator.SourceCode;
import org.hsweb.platform.generator.support.freemarker.FreemarkerGenerator;
import org.hsweb.platform.generator.template.SimpleCodeTemplate;
import org.hsweb.platform.generator.template.TemplateInput;
import org.hsweb.platform.generator.template.TemplateOutput;
import org.hsweb.web.core.authorize.annotation.Authorize;
import org.hsweb.web.core.exception.BusinessException;
import org.hsweb.web.core.logger.annotation.AccessLogger;
import org.hsweb.web.core.message.ResponseMessage;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.hsweb.web.core.message.ResponseMessage.ok;

/**
 * @author zhouhao
 */
@RestController
@RequestMapping("/generator")
@AccessLogger("代码生成器")
public class CodeGeneratorController {

    Generator<String> generator = new FreemarkerGenerator();

    @RequestMapping(value = "/write", method = RequestMethod.POST)
    @Authorize(module = "generator")
    @AccessLogger("写出代码")
    public ResponseMessage writeCode(@RequestParam(value = "path") String path, @RequestBody JSONArray codes) {
        for (int i = 0; i < codes.size(); i++) {
            JSONObject file = codes.getJSONObject(i);
            if ("file".equals(file.getString("type"))) {
                String fileName = path + "/" + file.getString("fileName");
                String code = file.getString("code");
                if (StringUtils.isNullOrEmpty(fileName)) continue;
                try {
                    new SourceCode() {
                        @Override
                        public String getFileName() {
                            return fileName;
                        }

                        @Override
                        public InputStream readCode() {
                            return new ByteArrayInputStream(code == null ? new byte[0] : code.getBytes());
                        }

                        @Override
                        public ReplaceMod getReplaceMode() {
                            try {
                                return ReplaceMod.valueOf(file.getString("replaceMod"));
                            } catch (Exception e) {
                                return ReplaceMod.ignore;
                            }
                        }
                    }.write();
                } catch (Exception e) {
                    e.printStackTrace();
                    throw new BusinessException("写出文件失败:" + fileName, e, 500);
                }
            }
        }
        return ok();
    }

    @RequestMapping(method = RequestMethod.POST)
    @Authorize(module = "generator")
    @AccessLogger("生成代码")
    public ResponseMessage generator(@RequestBody JSONObject config) {
        JSONArray fields = config.getJSONArray("fields");
        JSONArray varsArr = config.getJSONArray("vars");
        Map<String, Object> vars = varsArr.stream().map(o -> {
            JSONObject obj = ((JSONObject) o);
            Map<String, Object> var = new HashMap<>();
            if (obj.getString("name") != null)
                var.put(obj.getString("name"), obj.getString("value"));
            return var;
        }).reduce((map, map2) -> {
            map.putAll(map2);
            return map;
        }).get();
        vars.put("fields", fields);
        JSONObject template = config.getJSONObject("template");
        renderTemplateTree(vars, template);
        return ok(template);
    }

    protected void renderTemplateTree(Map<String, Object> vars, JSONObject template) {
        JSONObject code = new JSONObject();
        String type = template.getString("type");
        code.put("name", template.get("name"));
        code.put("type", type);
        if (template.getString("fileName") != null) {
            TemplateInput<String> fileNameIn = () -> template.getString("fileName");
            TemplateOutput fileNameOut = (name) -> template.put("fileName", name);
            try {
                generator.start(new SimpleCodeTemplate<>(vars, fileNameIn, fileNameOut));
            } catch (Exception e) {
                throw new BusinessException("渲染模板" + template.get("name") + "错误" + StringUtils.throwable2String(e), e, 500);
            }
        }
        if ("template".equals(type) && template.getString("template") != null) {
            TemplateInput<String> codeInput = () -> template.getString("template");
            TemplateOutput codeOut = (name) -> template.put("code", name);
            try {
                generator.start(new SimpleCodeTemplate<>(vars, codeInput, codeOut));
            } catch (Exception e) {
                throw new BusinessException("渲染模板" + template.get("name") + "错误:" + StringUtils.throwable2String(e), e, 500);
            }
        }
        JSONArray children = template.getJSONArray("children");
        if (children != null) {
            for (int i = 0; i < children.size(); i++) {
                renderTemplateTree(vars, children.getJSONObject(i));
            }
        }
    }
}
