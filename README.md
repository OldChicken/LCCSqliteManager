## LCCSqliteManager
这是一个Sqlite数据库框架
github地址:https://github.com/OldChicken/LCCSqliteManager

## 特点
这是一个轻量级框架，目的是让使用的人脱离Sql语句。你要建表，传入几个参数就可以，删除一条数据，传入表名和一个删除条件数组
就能达到目的，我把大部分Sql语句帮你封装好了。

## 版本信息
1.0版本:完成了数据库基本功能的封装，包括建、删表(带外键的暂时不建议用),数据的增删改查。
1.1版本:优化了建表方法，利用block建表，可以根据你的需要进行表格的建立，而不用一次性再传入多个参数。

## 使用明细
1.环境搭建

2.基本方法

LCCSqliteManager *manager = [LCCSqliteManager shareInstance];
[manager openSqliteFile:@"yourSqliteFileName"];

在你的项目中执行这两句代码，你旧可以进行数据库的管理了。

3.外键连接

