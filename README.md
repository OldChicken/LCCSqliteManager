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
获得单例
    ```Objective-C
    LCCSqliteManager *manager = [LCCSqliteManager shareInstance];  
    [manager openSqliteFile:@"yourSqliteFileName"];
    ```
    在进行数据库操作之前，你需要在你的项目中先执行下列代码，所有操作都需要用manager对象进行调用。openSqliteFile这个方法，若Sqlite文件不存在，则会自动创建一个并打开，你不需要设置路径，只需要传入文件名即可。<br><br><br>



接下来调用相关方法进行数据库管理<br>
>* 建表
    ```Objective-C
    [manager createSheetWithSheetHandler:^(LCCSqliteSheetHandler *sheet) {
      sheet.sheetName = @"Table1";
      sheet.sheetField = @[@"column1",@"column2",@"column3",@"column4"];
    }];
    ```
    上述代码建立了一张名为Table1，且含有四个字段的表。block中你可以进行这张表的相关设置，如果你需要建立一张带主键或者外键的表，你可以查看LCCSqliteSheetHandler类的头文件，了解如何设置一张完整的表。<br><br><br>


>* 得到所有表名
    ```Objective-C
    NSArray *sheets = [manager getAllSheetNames]
    ```
    上述代码返回当前sqlite数据库中的所有表名。<br><br><br>
    
    

>* 得到表的所有字段
    ```Objective-C
    NSArray *dates = [manager getSheetAttributesWithSheet:@“Table1”]
    ```
    上述代码返回表Table1的所有字段。<br><br><br>
    
    
    
>* 得到表的所有数据
    ```Objective-C
    NSArray *dates = [manager getSheetDataWithSheet:@“Table1”]
    ```
    上述代码返回表Table1的所有数据。<br><br><br>
    
    

>* 增
    ```Objective-C
    [manager insertDataToSheet:@"Table1" withData:@[@"1",@"2",@"3",@"4"];
    ```
    向上述创建的表中添加四个数据<br><br><br>




>* 删
    ```Objective-C
    [manager deleateDataFromSheet:@“Table1” where:@"  \"column1\"=\'1\'  ";
    ```
    删除表Table1中，字段"column1"为'data1'的那行数据。where后面跟的字符串是删除条件，你可以输入精确条件、比较条件、模糊查找条件、组合条件等。注意，字段用“”辨识，数据用‘’辨识。具体查找条件在deleateDataFromSheet的注释中有详细介绍。<br><br><br>




>* 改
    ```Objective-C
    [manager updateDataToSheet:@"Table1" withData:@[@"a","b",@"c",@"d"] where:@"  \"column1\"=\'1\' “ ;
    ```
    将表Table1中符合”column“＝‘1’的所有数据更新。<br><br><br>




>* 查
    ```Objective-C
    NSArray *result = [manager searchDataFromSheet:@"Table1"  where:@"  \"column1\"=\'1\' “ ;
    ```
    得到表Table1中 "column1"='1' 的所有数据。<br><br><br>


>* 说明:这里，查找条件中的 \"column1\"=\'1\',仅仅是用于sqlite中区分字段和字符串的作用。希望不要与NSString中的“”搞混
，你只需要将整个OC字符串@"  \"column1\"=\'1\' “ 作为查找条件传入即可。<br><br><br>



上个方法是主要方法，可以完成数据库的基本操作。一些其他方法，请查看LCCSqliteManager的头文件。


# 注意事项
* **所有数据都是以字符串形式存储在表中**，因此，当你从表中检索到数据时，你需要自己进行类型转换。这就导致了查找条件中你进行数值时会发生一些问题，比较例如“年龄”>'8'时，字符串‘10’是小于‘8’的，你必须存入‘08’而非‘8’，才能得到正确的检索结果。也正是因为如此，有关数据的任何计算，我都没有提供方法，你可以将符合条件的数据提取到你的项目中条件转换后再进行计算。

* **设置主键防止程序和数据库出现数据不同步而导致程序崩溃的现象**，在使用TableView的deleteRowsAtIndexPaths方法时，很容易出现你删除了一个cell，数据库删除了多个数据的情况导致崩溃。
