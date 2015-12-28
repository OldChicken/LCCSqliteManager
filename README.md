## LCCSqliteManager
这是一个轻量级框架，目的是让使用的人脱离Sql语句。<br>
github地址:https://github.com/OldChicken/LCCSqliteManager


## 版本信息
* v1.0:完成了数据库基本功能的封装，包括建、删表以及数据的增删改查。<br>
* v1.1:优化了建表方法，利用block建表，可以根据你的需要进行表格的建立，而不用一次性再传入多个参数。

## 使用明细
1.环境搭建

2.基本方法
```Objective-C
LCCSqliteManager *manager = [LCCSqliteManager shareInstance];  
[manager openSqliteFile:@"yourSqliteFileName"];
```

在你的项目中执行这两句代码，你旧可以进行数据库的管理了。

3.外键连接

