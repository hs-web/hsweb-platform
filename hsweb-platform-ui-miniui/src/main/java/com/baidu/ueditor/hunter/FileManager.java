package com.baidu.ueditor.hunter;

import com.baidu.ueditor.Context;
import com.baidu.ueditor.PathFormat;
import com.baidu.ueditor.define.AppInfo;
import com.baidu.ueditor.define.BaseState;
import com.baidu.ueditor.define.MultiState;
import com.baidu.ueditor.define.State;
import org.apache.commons.io.FileUtils;
import org.hsweb.ezorm.param.Term;
import org.hsweb.web.bean.common.PagerResult;
import org.hsweb.web.bean.common.QueryParam;
import org.hsweb.web.bean.po.resource.Resources;
import org.hsweb.web.bean.po.user.User;
import org.hsweb.web.core.utils.WebUtil;
import org.hsweb.web.service.resource.ResourcesService;

import java.io.File;
import java.util.*;

public class FileManager {

    private String dir = null;
    private String rootPath = null;
    private String[] allowFiles = null;
    private int count = 0;

    public FileManager(Map<String, Object> conf) {

        this.rootPath = (String) conf.get("rootPath");
        this.dir = this.rootPath + (String) conf.get("dir");
        this.allowFiles = this.getAllowFiles(conf.get("allowFiles"));
        this.count = (Integer) conf.get("count");

    }

    public State listFile(int index) {
        ResourcesService resourcesService = Context.RESOURCES_SERVICE;
        User user = WebUtil.getLoginUser();
        PagerResult<Resources> resources;
        try {
            QueryParam param = QueryParam.build()
                    .where("creatorId", user == null ? "1" : user.getId());
            if (allowFiles != null) {
                Term term=param.nest();
                for (String allowFile : allowFiles) {
                    term.or("name$like", "%" + allowFile);
                }
            }
            resources = resourcesService.selectPager(param.doPaging(index, count));
        } catch (Exception e) {
            resources = new PagerResult<>();
        }

        State state = null;

        if (index < 0 || index > resources.getData().size()) {
            state = new MultiState(true);
        } else {
            state = this.getState(resources.getData());
        }

        state.putInfo("start", index);
        state.putInfo("total", resources.getTotal());

        return state;

    }

    private State getState(List<Resources> resources) {

        MultiState state = new MultiState(true);
        BaseState fileState = null;

        for (Resources obj : resources) {
            if (obj == null) {
                break;
            }
            fileState = new BaseState(true);
            fileState.putInfo("url", rootPath + "file/download/" + obj.getId() + "/" + obj.getName());
            state.addState(fileState);
        }

        return state;

    }

    private String getPath(File file) {

        String path = file.getAbsolutePath();
        path = path.replace("\\", "/");
        return path.replace(this.rootPath, "/");

    }

    private String[] getAllowFiles(Object fileExt) {

        String[] exts = null;
        String ext = null;

        if (fileExt == null) {
            return new String[0];
        }

        exts = (String[]) fileExt;

        for (int i = 0, len = exts.length; i < len; i++) {

            ext = exts[i];
            exts[i] = ext.replace(".", "");

        }

        return exts;

    }

    public static void main(String[] args) {
        int n = 13;
        System.out.println(n > 9 ? (char) (n - 10 + 'A') : n);
        System.out.println(n > 9 ? (char) (n - 10 + 'A') : 1);
    }
}
