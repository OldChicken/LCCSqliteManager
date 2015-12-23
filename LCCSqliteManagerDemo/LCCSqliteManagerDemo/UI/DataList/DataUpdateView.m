//
//  DataUpdateView.m
//  DatabaseMangerDemo
//
//  Created by LccLcc on 15/12/11.
//  Copyright © 2015年 LccLcc. All rights reserved.
//



#import "Define.h"
#import "DataUpdateView.h"
#import "LccCell.h"
#import "LCCSqliteManager.h"
@implementation DataUpdateView
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
        [ensureButton addTarget:self action:@selector(_updateActon) forControlEvents:UIControlEventTouchUpInside];
        
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
    
    LccCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upData"];
    if (cell == nil) {
        
        cell = [[LccCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"upData" andWidth:300];
        
    }
    cell.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSArray * attributes =  [_manager getSheetAttributesWithSheet:self.sheetTitle];
    NSLog(@"attributes = %@",attributes);
    cell.textFiled.text = self.dataArray[indexPath.row];
    cell.textFiled.placeholder = attributes[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}


#pragma mark -Action

- (void)_updateActon{
    
    NSMutableArray* newData = [[NSMutableArray alloc]init];
    for (int i = 0; i < _cellCount; i ++) {
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        LccCell *pCell = [self.tableView cellForRowAtIndexPath:path ];
        [pCell.textFiled resignFirstResponder];
        [newData addObject:pCell.textFiled.text];

    }
    
    
    NSLog(@"更新的数据 ＝ %@",newData);
    LCCSqliteManager *manger = [LCCSqliteManager shareInstance];
   BOOL result = [manger updateDataToSheet:self.sheetTitle withData: newData where:self.updateContidion];
    
    if (result == YES) {
        
        [self _clearAction];
        [self.delegate updateSuccess];
        
    }
    
    if (result == NO) {
        
        [self.delegate updateError];
        
    }
    
    
}

- (void)_clearAction{
    
    for (int i = 0; i < _cellCount; i ++) {
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        LccCell *pCell = [self.tableView cellForRowAtIndexPath:path ];
        pCell.textFiled.text = @"";
        
    }
    
}

- (void)_deleateAction{
    
    NSLog(@"关闭视图");
    [self.delegate closeUpdateView];
    
}


@end
