package org.hsweb.platform.app.development.step.processer;

import org.hsweb.platform.app.step.SqlExecutorStep;
import org.hsweb.platform.core.ApplicationProcess;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.webbuilder.sql.support.executor.SqlExecutor;

/**
 * Created by zhouhao on 16-4-14.
 */
@Component
public class ListMenu extends SqlExecutorStep implements DevelopmentStepProcessor {

    @Autowired
    public ListMenu(SqlExecutor sqlExecutor) {
        super("select u_id,name,p_id from s_modules where p_id=#{pid}", sqlExecutor);
    }

    @Override
    public String getType() {
        return "list-menu";
    }
}
