//
//  LCCSqliteManager.m
//  LCCSqliteManagerDemo
//
//  Created by LccLcc on 15/11/25.
//  Copyright © 2015年 LccLcc. All rights reserved.
//

#import "LCCSqliteManager.h"



@implementation LCCSqliteManager
{
    //数据库指针
    sqlite3 *_sqlite ;

}


+ (LCCSqliteManager *)shareInstance{
    
    static LCCSqliteManager *instance = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [[[self class ]alloc ]init];
    });
    
    return instance;

}


- (BOOL)openSqlite{
    
    //创建数据库路径
    NSString *filePath = [NSHomeDirectory() stringByAppendingFormat: @"/Documents/%@", @"database.sqlite"];
    //判断打开结果，如果打开成功则让_sqlite指向它，如果打开失败则会创建一个新的数据库。
    int result = sqlite3_open([filePath UTF8String], &_sqlite);
    if (result != SQLITE_OK) {
        NSLog(@"数据库打开失败");
        return NO;
    }
    NSLog(@"数据库打开成功，路径为:%@",filePath);
    return YES;

}


- (BOOL)closeSqlite{
    
    sqlite3_close(_sqlite);
    NSLog(@"关闭了数据库");
    return YES;
    
}



- (NSArray *)getAllSheetNames{
    
    NSMutableArray *allSheetTitles = [[NSMutableArray alloc]init];
    
    sqlite3_stmt *statement;
    const char *getTableInfo = "select * from sqlite_master where type='table' order by name";
    sqlite3_prepare_v2(_sqlite, getTableInfo, -1, &statement, nil);
    while (sqlite3_step(statement) == SQLITE_ROW) {
        char *nameData = (char *)sqlite3_column_text(statement, 1);
        NSString *tableName = [[NSString alloc] initWithUTF8String:nameData];
        [allSheetTitles addObject:tableName];
    }
    
    return allSheetTitles;
    
}



- (BOOL)createSheetWithName:(NSString *)pName attributes:(NSArray *)pAttributes{
    

    //对pAttributes进行相关判断
    if (pAttributes.count == 0) {
        return NO;
    }
    
    
    //构造SQL语句，创建数据库表。
    NSString *appendString = [[NSString alloc]init];
    for (int i = 0 ; i < pAttributes.count; i ++) {
        if (i == pAttributes.count - 1) {
            appendString  = [appendString stringByAppendingString:[NSString stringWithFormat:@"\"%@\" text",pAttributes[i]]];
            break;
        }
       appendString  = [appendString stringByAppendingString:[NSString stringWithFormat:@"\"%@\" text,",pAttributes[i]]];
    }
    
    NSString *targetSql = [NSString stringWithFormat:@"CREATE TABLE \"%@\"(%@)",pName,appendString];
    NSLog(@"创建数据库表的sql语句 ＝ %@",targetSql);
    
    //执行SQL语句
    char *error = NULL;
    int result = sqlite3_exec(_sqlite, [targetSql UTF8String], NULL, NULL, &error);
    if (result != SQLITE_OK) {
        NSLog(@"创建失败：%s", error);
        return NO;
    }

    return YES;

}


- (BOOL)deleateSheetWithName:(NSString *)pName{
    
    //构造sql语句
     NSString *targetSql = [NSString stringWithFormat:@"DROP TABLE \"%@\"",pName];
    //执行SQL语句
    char *error = NULL;
    int result = sqlite3_exec(_sqlite, [targetSql UTF8String], NULL, NULL, &error);
    if (result != SQLITE_OK) {
        NSLog(@"删除失败：%s", error);
        return NO;
    }

    return YES;
    
}


- (NSArray *)getSheetAttributesWithSheet:(NSString *)pName{
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    sqlite3_stmt *statement;
    NSString *targetSql = [NSString stringWithFormat:@"PRAGMA table_info(\"%@\")",pName];
    const char *getTableInfo = [targetSql UTF8String];
    sqlite3_prepare_v2(_sqlite, getTableInfo, -1, &statement, nil);
    while (sqlite3_step(statement) == SQLITE_ROW) {
        char *nameData = (char *)sqlite3_column_text(statement, 1);
        NSString *attributeName = [[NSString alloc] initWithUTF8String:nameData];
        [array addObject:attributeName];
    }
    
    return array;
    
}

- (NSInteger )getSheetAttributesCountWithSheet:(NSString *)pName{
    
    NSInteger count = [self getSheetAttributesWithSheet:pName].count;
    return count;
    
}


- (NSArray *)getSheetDataWithSheet:(NSString *)pName{
    
    NSMutableArray *dataArray = [NSMutableArray array];
    NSInteger count = [self getSheetAttributesWithSheet:pName].count;
    NSLog(@"这个表有%ld个字段",(long)count);
    
    //预编译sql语句
    NSString *targetsql = [NSString stringWithFormat:@"SELECT * FROM \"%@\" ",pName] ;
    sqlite3_stmt *ppStmt = NULL;
    int result = sqlite3_prepare_v2(_sqlite, [targetsql UTF8String], -1, &ppStmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"预编译失败");
        return nil;
    }
    //执行查询语句
    int hasData = sqlite3_step(ppStmt);
    //代表当前有一行数据
    while (hasData == SQLITE_ROW) {
        //读出当前行数据的每一个字段内容
        const  unsigned char *str;
        NSMutableArray *dataModel = [NSMutableArray array];
        for (int i = 0 ; i < count; i++) {
            str = sqlite3_column_text(ppStmt, i); //读出当前数据的每一列内容
            if (str == NULL) {
                [dataModel addObject:@""];
            }
            else{
                [dataModel addObject:[NSString stringWithUTF8String:(const char*)str]];
            }
            
        }
        //把数据加入到数组中
        [dataArray addObject:dataModel];
        //指向下一行
        hasData = sqlite3_step(ppStmt);
        
    }
    NSLog(@"当前表内数据  ＝ %@",dataArray);
    //释放内存
    sqlite3_finalize(ppStmt);
    return dataArray;

}

- (NSInteger )getSheetDataCountWithSheet:(NSString *)pName{
    
    NSInteger count = [self getSheetDataWithSheet:pName].count;
    return count;
    
}



#pragma - mark 增删改查

- (BOOL)insertDataToSheet:(NSString *)sheetName withData:(NSArray *)data {

    //构造sql语句,其中插入的数据用占位符？代替
    NSString *placeHoderString = [[NSString alloc]init];
    for (int i = 0 ; i < data.count; i ++) {
        if (i == data.count - 1) {
            placeHoderString = [placeHoderString stringByAppendingString:@"?"];
            break;
        }
        placeHoderString = [placeHoderString stringByAppendingString:@"?,"];
    }
    NSString *targetString  = [NSString stringWithFormat:@"INSERT INTO \"%@\" VALUES(%@)",sheetName,placeHoderString];
    NSLog(@"%@",targetString);

    
    //预编译
    sqlite3_stmt *ppStmt = NULL;
    int  result = sqlite3_prepare_v2(_sqlite, [targetString UTF8String], -1, &ppStmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"预编译失败");
        return NO;
    }
    //如果预编译成功，向占位符上填充数据
    for (int i = 0; i < data.count ; i++) {
        sqlite3_bind_text(ppStmt, i+1, [data[i] UTF8String], -1, NULL);
    }
    
    //执行SQL语句
    result = sqlite3_step(ppStmt);
    if (result != SQLITE_DONE) {
        NSLog(@"插入数据失败");
        //释放数据库句柄和预编译以后的数据库句柄
        sqlite3_finalize(ppStmt);
        return NO;
    }
    //释放内存。
    sqlite3_finalize(ppStmt);
    return YES;


}


- (BOOL)deleateDataWhere:(NSDictionary *)condition from:(NSString *)sheetName{
    

    NSString *conditionStr = [[NSString alloc]init];
    NSArray *attributes = [condition allKeys];
    NSArray * values = [condition allValues];

    for (int i = 0 ; i < condition.count; i ++) {
        if (i == condition.count - 1) {
            NSString *pstr = [NSString stringWithFormat:@" \"%@\"=? ",attributes[i]];
            conditionStr = [conditionStr stringByAppendingString:pstr];
            break;
        }
        NSString *pstr = [NSString stringWithFormat:@" \"%@\"=? and",attributes[i]];
        conditionStr = [conditionStr stringByAppendingString:pstr];
    }

    NSString *targetSql = [NSString stringWithFormat:@"DELETE FROM \"%@\" WHERE %@",sheetName,conditionStr];
    NSLog(@"%@",targetSql);
    
    sqlite3_stmt *ppStmt = NULL;
    int result = sqlite3_prepare_v2(_sqlite, [targetSql UTF8String], -1, &ppStmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"预编译失败");
        return NO;
    }

    for (int i = 0; i < condition.count ; i++) {
        sqlite3_bind_text(ppStmt, i+1, [values[i] UTF8String], -1, NULL);
    }

    result = sqlite3_step(ppStmt);
    if (result != SQLITE_DONE) {
        NSLog(@"删除数据失败");
        return NO;
    }
    
    
    //释放内存
    sqlite3_finalize(ppStmt);
    NSLog(@"删除成功");
    return YES;
    
}


- (BOOL)updateDataToSheet:(NSString *)sheetName withData:(NSArray *)data where:(NSDictionary *)condition {
    
    //判断
    LCCSqliteManager *_manager  = [LCCSqliteManager shareInstance];
    NSArray *attributes = [_manager getSheetAttributesWithSheet:sheetName];
    if (data.count != attributes.count) {
        NSLog(@"数据个数不匹配");
        return NO;
    }
    
    
    //需要更新的字段构造，这里默认更新整条数据（有待改进）。
    NSString *updataDataString = [[NSString alloc]init];
    for (int i = 0 ; i < attributes.count; i ++) {
        if (i == attributes.count - 1) {
            NSString *pstr = [NSString stringWithFormat:@" \"%@\"=?",attributes[i]];
            updataDataString = [updataDataString stringByAppendingString:pstr];
            break;
        }
        NSString *pstr = [NSString stringWithFormat:@" \"%@\"=? ,",attributes[i]];
        updataDataString = [updataDataString stringByAppendingString:pstr];

    }

    
    //条件构造
    NSString *conditionStr = [[NSString alloc]init];
    NSArray *targetAttributes = [condition allKeys];
    NSArray * values = [condition allValues];
    
    for (int i = 0 ; i < condition.count; i ++) {
        if (i == condition.count - 1) {
            NSString *pstr = [NSString stringWithFormat:@" \"%@\"=?",targetAttributes[i]];
            conditionStr = [conditionStr stringByAppendingString:pstr];
            break;
        }
        NSString *pstr = [NSString stringWithFormat:@" \"%@\"=? and",targetAttributes[i]];
        conditionStr = [conditionStr stringByAppendingString:pstr];
    }
    
    //Sql构造
    NSString *targetSql = [NSString stringWithFormat:@"UPDATE \"%@\" SET %@ WHERE %@",sheetName,updataDataString,conditionStr];
    
    NSLog(@"%@",targetSql);
    

    
    //预编译
    sqlite3_stmt *ppStmt = NULL;
    int result = sqlite3_prepare_v2(_sqlite, [targetSql UTF8String], -1, &ppStmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"预编译失败，请检查");
        return NO;
    }
    
    //填充数据
    NSLog(@"data = %@",data);
    NSLog(@"values = %@",values);
    for (int i = 0; i < attributes.count ; i++) {
        sqlite3_bind_text(ppStmt, i+1, [data[i] UTF8String], -1, NULL);
    }
    for (int j = (int)attributes.count; j < (attributes.count + condition.count); j ++) {
        sqlite3_bind_text(ppStmt, j+1, [values[j-attributes.count] UTF8String], -1, NULL);
    }
    //执行SQL语句。
     result = sqlite3_step(ppStmt);
    if (result != SQLITE_DONE) {
        NSLog(@"更新失败");
        return NO;
    }
    sqlite3_finalize(ppStmt);
    return YES;
    
}


- (NSArray *)searchDataFromSheet:(NSString *)sheetName where:(NSDictionary *)condition{
    

    NSMutableArray *dataArray = [NSMutableArray array];
    NSInteger count = [self getSheetAttributesWithSheet:sheetName].count;
    NSLog(@"这个表有%ld个字段",(long)count);
    
    //条件构造
    NSString *conditionStr = [[NSString alloc]init];
    NSArray *targetAttributes = [condition allKeys];
    NSArray * values = [condition allValues];
    
    for (int i = 0 ; i < condition.count; i ++) {
        if (i == condition.count - 1) {
            NSString *pstr = [NSString stringWithFormat:@" \"%@\"=?",targetAttributes[i]];
            conditionStr = [conditionStr stringByAppendingString:pstr];
            break;
        }
        NSString *pstr = [NSString stringWithFormat:@" \"%@\"=? and",targetAttributes[i]];
        conditionStr = [conditionStr stringByAppendingString:pstr];
    }

    
    //构造sql语句
    NSString *targetsql = [NSString stringWithFormat:@"SELECT * FROM \"%@\" Where %@",sheetName,conditionStr] ;
    NSLog(@"查找语句＝%@",targetsql);
    
    //预编译
    sqlite3_stmt *ppStmt = NULL;
    int result = sqlite3_prepare_v2(_sqlite, [targetsql UTF8String], -1, &ppStmt, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"预编译失败");
        return nil;
    }
    
    //填充占位符
    for (int i = 0; i < condition.count ; i++) {

        sqlite3_bind_text(ppStmt, i+1, [values[i] UTF8String], -1, NULL);

    }



 
    //执行Sql语句
    int hasData = sqlite3_step(ppStmt);
    NSLog(@"%d",hasData);
    //代表当前有一行数据
    while (hasData == SQLITE_ROW) {
        
        //读出当前行数据的每一个字段内容
        const  unsigned char *str;
        NSMutableArray *dataModel = [NSMutableArray array];
        for (int i = 0 ; i < count; i++) {
            
            str = sqlite3_column_text(ppStmt, i); //读出当前行的每一列内容
            if (str == NULL) {
                [dataModel addObject:@""];
            }
            else{
                [dataModel addObject:[NSString stringWithUTF8String:(const char*)str]];
            }

            
        }
        //把Model加入到数组中
        [dataArray addObject:dataModel];
        //让游标指向下一行
        hasData = sqlite3_step(ppStmt);
        
    }
    NSLog(@"当前表符合条件的数据  ＝ %@",dataArray);
    sqlite3_finalize(ppStmt);
    return dataArray;
    
    
}


@end
