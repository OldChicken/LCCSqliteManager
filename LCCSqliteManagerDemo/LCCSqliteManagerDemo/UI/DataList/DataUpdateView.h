//
//  DataUpdateView.h
//  DatabaseMangerDemo
//
//  Created by LccLcc on 15/12/11.
//  Copyright © 2015年 LccLcc. All rights reserved.
//

#import "DataInsertView.h"

@protocol DataUpdateViewDelegate <NSObject>

//更新失败
- (void)updateError;
//更新成功
- (void)updateSuccess;
//关闭
- (void)closeUpdateView;

@end


@interface DataUpdateView : UIView<UITableViewDelegate,UITableViewDataSource>



@property(nonatomic,assign)NSInteger cellCount;
@property(nonatomic,strong)NSString *sheetTitle;
@property(nonatomic,weak)id<DataUpdateViewDelegate>delegate;
@property(nonatomic,strong)UITableView *tableView;

//更新条件
@property(nonatomic,strong)NSMutableDictionary *updateContidion;



@end
