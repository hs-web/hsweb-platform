package org.hsweb.platform.ui.controller;

import org.hsweb.web.core.authorize.annotation.Authorize;
import org.hsweb.web.core.message.ResponseMessage;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.webbuilder.utils.file.FileUtils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by zhouhao on 16-5-13.
 */
@RestController
@RequestMapping("/icon-list")
@Authorize
public class IconController {

    @RequestMapping
    public ResponseMessage iconList() throws IOException {
        Reader reader = FileUtils.getResourceAsReader("static/ui/plugins/miniui/themes/icons.css");
        BufferedReader br = new BufferedReader(reader);
        List<String> icons = new ArrayList<>();
        while (br.ready()) {
            String line = br.readLine();
            if (line.startsWith(".icon-")) {
                icons.add(line.substring(1));
            }
        }
        return ResponseMessage.ok(icons).onlyData();
    }
}
