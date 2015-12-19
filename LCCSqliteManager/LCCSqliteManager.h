//
//  LCCSqliteManager.h
//  LCCSqliteManagerDemo
//
//  Created by LccLcc on 15/11/25.
//  Copyright © 2015年 LccLcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class LCCSqliteSheet;
@class LCCSqliteModel;

@interface LCCSqliteManager : NSObject



//获取单例manager
+ (LCCSqliteManager*)shareInstance;

#pragma mark - Manger进行数据库操作
//打开数据库
- (BOOL)openSqlite;
//关闭数据库
- (BOOL)closeSqlite;




#pragma mark - Manger进行表管理
//获取所有表名
- (NSArray*)getAllSheetNames;
//新建表
- (BOOL)createSheetWithName:(NSString *)pName attributes:(NSArray *)pAttributes;
//删除表
- (BOOL)deleateSheetWithName:(NSString *)pName;
//获取表的字段
- (NSArray *)getSheetAttributesWithSheet:(NSString *)pName;
//获取表的字段数
- (NSInteger )getSheetAttributesCountWithSheet:(NSString *)pName;
//获取表的所有数据
- (NSArray *)getSheetDataWithSheet:(NSString *)pName;
//获取表的数据个数
- (NSInteger )getSheetDataCountWithSheet:(NSString *)pName;


//待加....



#pragma mark -Manger进行数据的增删改查
//增
- (BOOL)insertDataToSheet:(NSString *)sheetName withData:(NSArray *)data;

//删
- (BOOL)deleateDataWhere:(NSDictionary *)condition from:(NSString *)sheetName;

//改
- (BOOL)updateDataToSheet:(NSString *)sheetName withData:(NSArray *)data where:(NSDictionary *)condition;

//查
- (NSArray *)searchDataFromSheet:(NSString *)sheetName where:(NSDictionary *)condition;


#pragma mark - 其他
//外键连接


//表拷贝





@end
