package org.hsweb.platform.ui.service.wrapper;

import org.hsweb.web.service.config.ConfigService;
import org.springframework.stereotype.Component;
import org.webbuilder.sql.DataBase;
import org.webbuilder.sql.Table;
import org.webbuilder.sql.support.executor.ObjectWrapper;
import org.webbuilder.sql.support.executor.ObjectWrapperFactory;

import javax.annotation.Resource;
import java.util.Map;

/**
 * Created by zhouhao on 16-5-12.
 */
@Component
public class OptionPushWrapperFactory implements ObjectWrapperFactory<Map<String, Object>> {
    private String suffix = "_cn";
    @Resource
    private ConfigService configService;

    @Override
    public ObjectWrapper<Map<String, Object>> getWrapper(DataBase dataBase, Table table) {
        OptionPushWrapper wrapper=new OptionPushWrapper();
        wrapper.setConfigService(configService);
        wrapper.init(dataBase,table);
        wrapper.setSuffix(suffix);
        return wrapper;
    }
}
