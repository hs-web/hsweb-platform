package org.hsweb.test.datasource.dao.mysql;

import org.apache.ibatis.annotations.Select;
import org.hsweb.web.bean.po.user.User;

/**
 * Created by zhouhao on 16-4-26.
 */
public interface MysqlUserMapper {
    @Select("select * from s_user where username=#{username}")
    User selectUserByUsername(String username);
}
