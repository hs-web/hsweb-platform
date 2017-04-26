package org.hsweb.platform.ui.controller;

import com.baidu.ueditor.ActionEnter;
import com.baidu.ueditor.Context;
import com.baidu.ueditor.define.BaseState;
import com.baidu.ueditor.define.State;
import org.hsweb.commons.StringUtils;
import org.hsweb.web.bean.po.resource.Resources;
import org.hsweb.web.service.resource.FileService;
import org.hsweb.web.service.resource.ResourcesService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

/**
 * Created by zhouhao on 16-6-18.
 */
@RestController
@RequestMapping("/ueditor")
public class UeditorController {

    @Resource
    private FileService fileService;

    @Resource
    private ResourcesService resourcesService;

    @PostConstruct
    public void init() {
        Context.FILE_SERVICE = fileService;
        Context.RESOURCES_SERVICE = resourcesService;
    }

    public String getDownloadPath(HttpServletRequest request) {
        String contextPath = request.getContextPath();

        return (StringUtils.isNullOrEmpty(contextPath) || contextPath.equals("/") ? "/" : (contextPath.startsWith("/") ? contextPath : "/" + contextPath) + "/");
    }

    @RequestMapping(method = RequestMethod.POST)
    public String postRun(HttpServletRequest request) throws Exception {
        return new ActionEnter(request, getDownloadPath(request)).exec();
    }

    /**
     * ueditor上传文件
     *
     * @param files   文件列表
     * @param request {@link HttpServletRequest}
     * @return 上传结果
     * @throws IOException 文件上传错误
     */
    @RequestMapping(method = RequestMethod.POST, consumes = "multipart/form-data")
    public String upload(@RequestParam(value = "upfile", required = false) MultipartFile[] files,
                         HttpServletRequest request) throws IOException {
        if (files != null && files.length > 0) {
            for (MultipartFile file : files) {
                Resources resources = fileService.saveFile(file.getInputStream(), file.getOriginalFilename());
                State state = new BaseState(true);
                state.putInfo("size", 0);
                state.putInfo("title", resources.getName());
                state.putInfo("url", getDownloadPath(request) + "file/download/" + resources.getId() + "/" + resources.getName());
                state.putInfo("type", resources.getSuffix());
                state.putInfo("original", resources.getName());
                return state.toJSONString();
            }
        }
        return new ActionEnter(request, getDownloadPath(request)).exec();
    }

    @RequestMapping(method = RequestMethod.GET)
    public String run(HttpServletRequest request) throws Exception {
        return new ActionEnter(request, getDownloadPath(request)).exec();
    }

}
