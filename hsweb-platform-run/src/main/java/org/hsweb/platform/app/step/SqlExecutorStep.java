package org.hsweb.platform.app.step;

import org.hsweb.platform.core.ApplicationProcess;
import org.hsweb.platform.core.Step;
import org.webbuilder.sql.support.common.CommonSql;
import org.webbuilder.sql.support.executor.HashMapWrapper;
import org.webbuilder.sql.support.executor.ObjectWrapper;
import org.webbuilder.sql.support.executor.SqlExecutor;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by zhouhao on 16-4-14.
 */
public class SqlExecutorStep implements Step {

    private SqlExecutor sqlExecutor;

    private ObjectWrapper wrapper = new HashMapWrapper();

    private String sql;

    public SqlExecutorStep(String sql, SqlExecutor sqlExecutor) {
        this.sql = sql;
        this.sqlExecutor = sqlExecutor;
    }

    @Override
    public Object execute(ApplicationProcess process) {
        Map<String, Object> param = process.getVar("params").toMap();
        if (param == null) param = process.getParameters().toMap();
        if (param == null) param = new HashMap<>();
        CommonSql sqlObj = new CommonSql();
        sqlObj.setParams(param);
        sqlObj.setSql(sql);
        Object result = null;
        try {
            if (sql.startsWith("select") || sql.startsWith("SELECT")) {
                result = sqlExecutor.list(sqlObj, wrapper);
            } else if (sql.startsWith("update") || sql.startsWith("UPDATE")) {
                result = sqlExecutor.update(sqlObj);
            } else if (sql.startsWith("delete") || sql.startsWith("DELETE")) {
                result = sqlExecutor.delete(sqlObj);
            } else if (sql.startsWith("insert") || sql.startsWith("INSERT")) {
                result = sqlExecutor.insert(sqlObj);
            } else {
                sqlExecutor.exec(sqlObj);
            }
        } catch (Exception e) {
            process.error(e);
        }
        return result;
    }

    public void setWrapper(ObjectWrapper wrapper) {
        this.wrapper = wrapper;
    }
}
