# hsweb-platform
hsweb 敏捷开发平台
## spring-boot & mybatis & maven & docker

## 运行
main 方法运行: 模块hsweb-platform-run里的Run.java

## 修改数据库链接
```xml
    <!--hsweb-platform-run/pom.xml-->
     <profile>
        <id>dev</id>
       <properties>
           <envistronment.package>develop</envistronment.package>
           <jdbc.type>mysql</jdbc.type>
           <logging.path>/var/logger/hsweb/</logging.path>
           <jdbc.url>jdbc:mysql://127.0.0.1:3306/hsweb?useUnicode=true&amp;characterEncoding=utf-8&amp;useSSL=false</jdbc.url>
           <jdbc.username>mysql-username</jdbc.username>
           <jdbc.password>mysql-password</jdbc.password>
           <jdbc.driverClassName>com.mysql.jdbc.Driver</jdbc.driverClassName>
       </properties>
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
    </profile>
```