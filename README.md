# LCCSqliteManager
这是一个轻量级框架，可以让使用的人脱离Sql语句进行数据库的管理。<br>
github地址:https://github.com/OldChicken/LCCSqliteManager


# 版本信息
* v1.0:完成了数据库基本功能的封装，包括建、删表以及数据的增删改查。<br>
* v1.1:优化了建表方法，利用block建表，可以根据你的需要进行表格的建立，而不用一次性再传入多个参数。

# 使用明细
###1.环境搭建<br>
将下载后的LCCSqliteManager文件夹直接拖入你的项目中，并往你的项目中导入C语言库文件libsqlite3.0后就可以直接使用了。
    
###2.基本方法

在你的项目中执行下列代码后就可以进行数据库的管理，所有操作都需要用manager对象进行调用。openSqliteFile这个方法，若Sqlite文件不存在，则会自动创建一个并打开，你不需要设置路径，只需要传入文件名即可。

```Objective-C
LCCSqliteManager *manager = [LCCSqliteManager shareInstance];  
[manager openSqliteFile:@"yourSqliteFileName"];
```


>接下来调用相关方法进行数据库管理<br>
>>建表
```Objective-C
[_manager createSheetWithSheetHandler:^(LCCSqliteSheetHandler *sheet) {
    sheet.sheetName = @"Table1";
    sheet.sheetField = @[@"column1",@"column2",@"column3",@"column4"];
    }];
```
上述代码建立了一张名为Table1，且含有四个字段的表。block中你可以进行这张表的相关设置，如果你需要建立一张带主键或者外键的表，你可以查看LCCSqliteSheetHandler类的头文件，了解如何设置一张完整的表。

>>增

>>删

>>改

>>查




