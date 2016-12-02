package org.hsweb.platform.generator.utils;

import org.hsweb.commons.StringUtils;
import org.hsweb.ezorm.rdb.executor.SQL;
import org.hsweb.ezorm.rdb.meta.RDBColumnMetaData;
import org.hsweb.ezorm.rdb.meta.RDBDatabaseMetaData;
import org.hsweb.ezorm.rdb.meta.RDBTableMetaData;
import org.hsweb.ezorm.rdb.render.SqlRender;
import org.hsweb.ezorm.rdb.render.dialect.H2RDBDatabaseMetaData;
import org.hsweb.ezorm.rdb.render.dialect.MysqlRDBDatabaseMetaData;
import org.hsweb.ezorm.rdb.render.dialect.OracleRDBDatabaseMetaData;

import java.sql.JDBCType;
import java.util.List;
import java.util.Map;

public class GeneratorUtils {
    public String getGetter(String name, String javaType) {
        if ("boolean".equals(javaType.toLowerCase())) {
            return "is" + StringUtils.toUpperCaseFirstOne(name);
        }
        return "get" + StringUtils.toUpperCaseFirstOne(name);
    }

    public String getSetter(String name) {
        return "set" + StringUtils.toUpperCaseFirstOne(name);
    }

    public String buildCreateSQL(String dbType, String tableName, String comment, List<Map<String, Object>> fields) {
        if (fields == null || fields.size() == 0) return "";
        RDBDatabaseMetaData databaseMetaData;
        switch (dbType) {
            case "h2":
                databaseMetaData = new H2RDBDatabaseMetaData();
                break;
            case "oracle":
                databaseMetaData = new OracleRDBDatabaseMetaData();
                break;
            case "mysql":
                databaseMetaData = new MysqlRDBDatabaseMetaData();
                break;
            default:
                return "";
        }
        databaseMetaData.init();
        SqlRender render = databaseMetaData.getRenderer(SqlRender.TYPE.META_CREATE);
        RDBTableMetaData metaData = new RDBTableMetaData();
        metaData.setName(tableName);
        metaData.setComment(comment);
        fields.forEach(map -> {
            RDBColumnMetaData fieldMetaData = new RDBColumnMetaData();
            String name = (String) map.get("column");
            if (name == null) {
                name = (String) map.get("name");
            }
            fieldMetaData.setName(name);
            fieldMetaData.setComment((String) map.get("comment"));
            fieldMetaData.setDataType((String) map.get("dataType"));
            fieldMetaData.setJdbcType(JDBCType.valueOf((String) map.get("jdbcType")));
            fieldMetaData.setNotNull(StringUtils.isTrue(map.get("notNull")));
            fieldMetaData.setProperty("not-null", StringUtils.isTrue(map.get("notNull")));
            metaData.addColumn(fieldMetaData);
        });
        SQL sql = render.render(metaData, metaData);
        StringBuilder builder = new StringBuilder();
        builder.append(sql.getSql()).append(";\n");
        sql.getBinds().forEach(bindSQL -> builder.append(bindSQL.getSql().getSql()).append(";\n"));
        return builder.toString();
    }
}
