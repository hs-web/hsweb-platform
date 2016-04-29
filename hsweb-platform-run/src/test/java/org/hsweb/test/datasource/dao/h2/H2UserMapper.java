package org.hsweb.test.datasource.dao.h2;

import org.apache.ibatis.annotations.Select;
import org.hsweb.web.bean.po.user.User;

/**
 * Created by zhouhao on 16-4-26.
 */
public interface H2UserMapper {
    @Select("select * from s_user where username=#{username}")
    User selectUserByUsername(String username);
}
