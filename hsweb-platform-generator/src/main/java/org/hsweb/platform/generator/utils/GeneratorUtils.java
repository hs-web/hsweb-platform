package org.hsweb.platform.generator.utils;

import org.hsweb.commons.StringUtils;
import org.hsweb.ezorm.executor.SQL;
import org.hsweb.ezorm.meta.DatabaseMetaData;
import org.hsweb.ezorm.meta.FieldMetaData;
import org.hsweb.ezorm.meta.TableMetaData;
import org.hsweb.ezorm.render.SqlRender;
import org.hsweb.ezorm.render.dialect.H2DatabaseMeta;
import org.hsweb.ezorm.render.dialect.MysqlDatabaseMeta;
import org.hsweb.ezorm.render.dialect.OracleDatabaseMeta;

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
        if(fields==null||fields.size()==0)return "";
        DatabaseMetaData databaseMetaData;
        switch (dbType) {
            case "h2":
                databaseMetaData = new H2DatabaseMeta();
                break;
            case "oracle":
                databaseMetaData = new OracleDatabaseMeta();
                break;
            case "mysql":
                databaseMetaData = new MysqlDatabaseMeta();
                break;
            default:
                return "";
        }
        databaseMetaData.init();
        SqlRender render = databaseMetaData.getRenderer(SqlRender.TYPE.META_CREATE);
        TableMetaData metaData = new TableMetaData();
        metaData.setName(tableName);
        metaData.setComment(comment);
        fields.forEach(map -> {
            FieldMetaData fieldMetaData = new FieldMetaData();
            String name = (String) map.get("column");
            if (name == null) {
                name = (String) map.get("name");
            }
            fieldMetaData.setName(name);
            fieldMetaData.setComment((String) map.get("comment"));
            fieldMetaData.setDataType((String) map.get("dataType"));
            fieldMetaData.setJdbcType(JDBCType.valueOf((String) map.get("jdbcType")));
            fieldMetaData.setProperty("not-null", StringUtils.isTrue(map.get("notNull")));
            metaData.addField(fieldMetaData);
        });
        SQL sql = render.render(metaData, metaData);
        StringBuilder builder = new StringBuilder();
        builder.append(sql.getSql()).append(";\n");
        sql.getBinds().forEach(bindSQL -> builder.append(bindSQL.getSql().getSql()).append(";\n"));
        return builder.toString();
    }
}
