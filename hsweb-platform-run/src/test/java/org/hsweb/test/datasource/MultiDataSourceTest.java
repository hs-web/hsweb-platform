package org.hsweb.test.datasource;

import org.hsweb.test.datasource.dao.h2.H2UserMapper;
import org.hsweb.test.datasource.dao.mysql.MysqlUserMapper;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import javax.annotation.Resource;

/**
 * Created by zhouhao on 16-4-26.
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = Application.class)
public class MultiDataSourceTest {

    @Resource
    private MysqlUserMapper mysqlUserMapper;

    @Resource
    private H2UserMapper h2UserMapper;

    @Test
    public void testMapper() {
        mysqlUserMapper.selectUserByUsername("admin");
        h2UserMapper.selectUserByUsername("admin");
    }
}
