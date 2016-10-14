## 后台管理基础框架-演示
[![Build Status](https://api.travis-ci.org/hs-web/hsweb-platform.svg?branch=master)](https://travis-ci.org/hs-web/hsweb-platform)

## 注意!
目前仅提供了一个ui模块:miniui,此ui不为开源项目,仅做演示使用,如需商用请购买正版。
<br/>
正在寻找ui替代方案...
## 在线演示
[http://demo.hsweb.me](http://demo.hsweb.me)
用户名 test test1 test2 ... 密码 123456

## 运行
项目运行环境需要java8

1. 无maven环境
[下载源码](https://github.com/hs-web/hsweb-platform/archive/master.zip) 解压后执行
```bash
    $ ./run.sh #linux
    $ run.cmd  #window
```
2. maven
```bash
    $ git clone https://github.com/hs-web/hsweb-platform.git
    $ cd hsweb-platform/hsweb-platform-run
    $ mvn spring-boot:run
```

3. IDE
直接运行hsweb-platform-run下Run.java类

4. 打包
```bash
    $ git clone https://github.com/hs-web/hsweb-platform.git
    $ cd hsweb-platform/hsweb-platform-run
    $ mvn package
    $ cd target
    $ java -jar hsweb-platform-run.jar
```

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
