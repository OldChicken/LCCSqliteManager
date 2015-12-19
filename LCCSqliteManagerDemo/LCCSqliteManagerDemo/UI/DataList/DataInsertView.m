//
//  InsertView.m
//  DatabaseMangerDemo
//
//  Created by LccLcc on 15/12/3.
//  Copyright © 2015年 LccLcc. All rights reserved.
//

#import "Define.h"
#import "DataInsertView.h"
#import "LccCell.h"
#import "LCCSqliteManager.h"
@implementation DataInsertView
{

    LCCSqliteManager *_manager;
    
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        //背景
        UIView * blackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KWidth, KHeight)];
        [self addSubview:blackgroundView];
        blackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        
        
        //表视图
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake((KWidth - 300)/2, 70, 300, KHeight - 250)];
        
        if (iPhone4) {
            self.tableView.frame = CGRectMake((KWidth - 300)/2, 40, 300, KHeight - 250);
        }

        [blackgroundView addSubview:self.tableView ];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  

        //确定按钮
        UIButton *ensureButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 70, 40, 40)];
        if (iPhone4) {
            ensureButton.frame = CGRectMake(10, 30, 40, 40);
        }
        [blackgroundView addSubview:ensureButton];
        [ensureButton setImage:[UIImage imageNamed:@"btn_save"] forState:UIControlStateNormal];
        [ensureButton addTarget:self action:@selector(_insertActon) forControlEvents:UIControlEventTouchUpInside];
        
        //删除按钮
        UIButton *deleateButton = [[UIButton alloc]initWithFrame:CGRectMake(KWidth - 50, 70, 40, 40)];
        if (iPhone4) {
            deleateButton.frame = CGRectMake(KWidth - 50, 30, 40, 40);
        }
        [blackgroundView addSubview:deleateButton];
        [deleateButton setImage:[UIImage imageNamed:@"btn_cannel"] forState:UIControlStateNormal];
        [deleateButton addTarget:self action:@selector(_deleateAction) forControlEvents:UIControlEventTouchUpInside];
        
        _manager = [LCCSqliteManager shareInstance];
    }
    
    return self;
    
}

#pragma mark - TableViewDelegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.cellCount;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LccCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inputCell"];
    if (cell == nil) {
        cell = [[LccCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"inputCell" andWidth:300];
    }
    cell.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //获取到这个表的字段
    NSArray * attributes =  [_manager getSheetAttributesWithSheet:self.sheetTitle];
    cell.textFiled.placeholder = attributes[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}


#pragma mark -Action

- (void)_insertActon{
    
    NSMutableArray* insertData = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < _cellCount; i ++) {
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        LccCell *pCell = [self.tableView cellForRowAtIndexPath:path ];
        [insertData addObject:pCell.textFiled.text];
        
    }
    
    NSLog(@"插入的数据 ＝ %@",insertData);
    LCCSqliteManager *manger = [LCCSqliteManager shareInstance];
    BOOL result =  [manger insertDataToSheet :self.sheetTitle withData:insertData];
    
    if (result == YES) {
        
        [self _clearAction];
        [self.delegate insertSuccess];
        
    }
    
    if (result == NO) {
        
        [self.delegate insertError];
        
    }
    
    
}

- (void)_clearAction{
    
    [self endEditing:YES];
    for (int i = 0; i < self.cellCount; i ++) {
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        LccCell *pCell = [self.tableView cellForRowAtIndexPath:path ];
        pCell.textFiled.text = @"";
        
    }
    
}

- (void)_deleateAction{
    
    [self.delegate closeInsertlView];
    
}


@end
