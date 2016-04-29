package org.hsweb.test.datasource;

import com.alibaba.druid.pool.DruidDataSource;
import org.hsweb.web.bean.po.user.User;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.boot.autoconfigure.MybatisAutoConfiguration;
import org.mybatis.spring.mapper.MapperScannerConfigurer;
import org.springframework.boot.autoconfigure.AutoConfigureOrder;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

/**
 * Created by zhouhao on 16-4-26.
 */
@Configuration
@EnableAutoConfiguration(exclude = {
        DataSourceAutoConfiguration.class,
        DataSourceTransactionManagerAutoConfiguration.class,
        MybatisAutoConfiguration.class})
@AutoConfigureOrder(value = 3)
public class Application {

    @Bean(name = "h2DataSource")
    public DataSource h2DataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName("org.h2.Driver");
        dataSource.setUrl("jdbc:h2:mem:hsweb");
        dataSource.setUsername("sa");
        dataSource.setPassword("");
        return dataSource;
    }

    @Bean(name = "h2SqlSessionFactoryBean")
    public SqlSessionFactoryBean h2SqlSessionFactoryBean() {
        SqlSessionFactoryBean sqlSessionFactory = new SqlSessionFactoryBean();
        sqlSessionFactory.setDataSource(h2DataSource());
        sqlSessionFactory.setTypeAliases(new Class[]{User.class});
        return sqlSessionFactory;
    }

    @Bean(name = "h2MapperScannerConfigurer")
    public MapperScannerConfigurer h2MapperScannerConfigurer() {
        MapperScannerConfigurer configurer = new MapperScannerConfigurer();
        configurer.setBasePackage("org.hsweb.test.datasource.dao.h2");
        configurer.setSqlSessionFactoryBeanName("h2SqlSessionFactoryBean");
        return configurer;
    }

    @Bean(name = "mysqlDataSource")
    public DataSource mysqlDataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://127.0.0.1:3306/hsweb?useUnicode=true&characterEncoding=utf-8&useSSL=false");
        dataSource.setUsername("root");
        dataSource.setPassword("19920622");
        return dataSource;
    }

    @Bean(name = "mysqlSqlSessionFactoryBean")
    public SqlSessionFactoryBean mysqlSqlSessionFactoryBean() {
        SqlSessionFactoryBean sqlSessionFactory = new SqlSessionFactoryBean();
        sqlSessionFactory.setDataSource(mysqlDataSource());
        sqlSessionFactory.setTypeAliases(new Class[]{User.class});
        return sqlSessionFactory;
    }

    @Bean(name = "mysqlMapperScannerConfigurer")
    public MapperScannerConfigurer mysqlMapperScannerConfigurer() {
        MapperScannerConfigurer configurer = new MapperScannerConfigurer();
        configurer.setBasePackage("org.hsweb.test.datasource.dao.mysql");
        configurer.setSqlSessionFactoryBeanName("mysqlSqlSessionFactoryBean");
        return configurer;
    }

}
