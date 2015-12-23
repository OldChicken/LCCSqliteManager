//
//  SheetDataController.m
//  DatabaseMangerDemo
//
//  Created by LccLcc on 15/12/1.
//  Copyright © 2015年 LccLcc. All rights reserved.
//

#import "DataListController.h"
#import "LCCSqliteManager.h"
#import "LccButton.h"
#import "LccDataCell.h"
#import "DataInsertView.h"
#import "DataUpdateView.h"
#import "Define.h"
@interface DataListController ()<UITableViewDelegate,UITableViewDataSource,InsertViewDelegate,DataUpdateViewDelegate>

{
    
    //数据库
    LCCSqliteManager * _manager;
    //接收所有数据
    NSArray * _allDataArray;
    //插入数据页面
    DataInsertView * _dataInsertView;
    //更新数据页面
    DataUpdateView * _dataUpdateView;
    //搜索条件
    NSString * _searchCondition;
    //删除条件
    NSString * _deleateCondition;
    //更新条件
    NSString * _updateCondition;

}

@end

@implementation DataListController

- (void)viewDidLoad {
    [super viewDidLoad];

    _manager = [LCCSqliteManager shareInstance];
    //获取到当前表的字段
    _attributesArray = [_manager getSheetAttributesWithSheet:self.title];
    //获取到当前表内所有数据
    _allDataArray = [_manager getSheetDataWithSheet:self.title];
    //初始化更新、查询、删除三个条件
    _deleateCondition = @"";
    _updateCondition = @"";
    _searchCondition = @"";
    //表视图
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //插入视图
    _dataInsertView = [[DataInsertView alloc]initWithFrame:CGRectMake(0, -KHeight, KWidth, KHeight)];
    _dataInsertView.delegate = self;
    _dataInsertView.sheetTitle = self.title;
    _dataInsertView.cellCount = _attributesArray.count;
    [self.navigationController.view addSubview:_dataInsertView];
    [self.navigationController.view bringSubviewToFront:_dataInsertView];
    
    
}

#pragma mark - TableViewDataSourse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    return _allDataArray.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 80;
}


#pragma mark - TableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * BGView = [[UIView alloc]init];
    BGView.backgroundColor = [UIColor whiteColor];
    long width = KWidth/_attributesArray.count;
    for (int i = 0; i < _attributesArray.count; i ++) {
        UILabel *attributetitle = [[UILabel alloc]initWithFrame:CGRectMake(i * width, 50, width, 20)];
        attributetitle.text = _attributesArray[i];
        [attributetitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        attributetitle.textColor = [UIColor grayColor];
        attributetitle.textAlignment = NSTextAlignmentCenter;
        [BGView addSubview:attributetitle];
    }
    
    long width2 = KWidth / 4;
    long xOffset = (width2 - 45)/2;
    NSArray *array = @[@"增",@"删",@"改",@"查"];
    for (int i = 0; i <= 3; i++) {
        LccButton *button = [LccButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(i*width2 + xOffset, 6, 45, 25);
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [BGView addSubview:button];
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 40, KWidth, 1)];
    line.backgroundColor = [UIColor grayColor];
    [BGView addSubview:line];

    
    return BGView;
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LccDataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell"];
    //为空时
    if (cell == nil) {
        if (_allDataArray.count == 0) {
            cell = [[LccDataCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dataCell"];
        }
        else{
            cell = [[LccDataCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dataCell" data:_allDataArray[indexPath.row]];
        }
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    //不为空时，因为单元格复用,需要对cell的title进行重新赋值。
    for (int i = 0; i < _attributesArray.count; i ++) {
        UILabel *pLabel = [cell viewWithTag:i+100];
        pLabel.text = _allDataArray[indexPath.row][i];
    }

    return cell;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        LccDataCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        for (int i = 0; i < _attributesArray.count; i ++) {
            UILabel *pLabel = [cell viewWithTag:i+100];
            if (i == _attributesArray.count - 1) {
                NSString *pstr = [NSString stringWithFormat:@" \"%@\"=\'%@\'",_attributesArray[i],pLabel.text];
                _deleateCondition = [_deleateCondition stringByAppendingString:pstr];
                break;
            }
            NSString *pstr = [NSString stringWithFormat:@" \"%@\"=\'%@\' and",_attributesArray[i],pLabel.text];
            _deleateCondition = [_deleateCondition stringByAppendingString:pstr];

        }
        NSLog(@"删除条件 ＝ %@",_deleateCondition);
        
        //删除满足该条件的数据
        [_manager deleateDataFromSheet:self.title where:_deleateCondition];
        _deleateCondition = @"";
        //从新读取数据并刷新,判断是在哪里删除的数据
        _allDataArray = [_manager getSheetDataWithSheet:self.title];
        if (![_searchCondition  isEqual: @""]) {
            NSLog(@"搜索过了，返回搜索列表数据");
            _allDataArray = [_manager searchDataFromSheet:self.title where:_searchCondition];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"弹出修改视图");
    _updateCondition = @"";
    LccDataCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i = 0; i < _attributesArray.count; i ++) {
        UILabel *pLabel = [cell viewWithTag:i+100];
        [array addObject:pLabel.text];
        if (i == _attributesArray.count - 1) {
            NSString *pstr = [NSString stringWithFormat:@" \"%@\"=\'%@\' ",_attributesArray[i],pLabel.text];
            _updateCondition = [_updateCondition stringByAppendingString:pstr];
            break;
        }
        NSString *pstr = [NSString stringWithFormat:@" \"%@\"=\'%@\' and",_attributesArray[i],pLabel.text];
        _updateCondition = [_updateCondition stringByAppendingString:pstr];
        
    }

    //数据更新视图
    _dataUpdateView = [[DataUpdateView alloc]initWithFrame:CGRectMake(0, -KHeight, KWidth, KHeight)];
    _dataUpdateView.delegate = self;
    _dataUpdateView.sheetTitle = self.title;
    _dataUpdateView.cellCount = _attributesArray.count;
    _dataUpdateView.updateContidion = _updateCondition;
    _dataUpdateView.dataArray = array;
    
    [self.navigationController.view addSubview:_dataUpdateView];
    [self.navigationController.view bringSubviewToFront:_dataUpdateView];
    
    NSLog(@"更新条件＝%@",_updateCondition);
    [UIView animateWithDuration:.3 animations:^{
        _dataUpdateView.frame = CGRectMake(0, 0, KWidth, KHeight);
    } completion:nil] ;
}


#pragma mark - InsertViewDelegate
- (void)closeInsertlView{
    
    [_dataInsertView endEditing:YES];
    [UIView animateWithDuration:.2 animations:^{
        _dataInsertView.frame = CGRectMake(0, -KHeight, KWidth, KHeight);
    } completion:nil];

}

-(void)insertSuccess{
    //插入一条新数据后，所有搜索记录清空
    [self _clearCondition];
    _allDataArray = [_manager getSheetDataWithSheet:self.title];
    [self.tableView reloadData];

    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"插入成功"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cannleAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [alter addAction:cannleAction];
    
    [self presentViewController:alter animated:YES completion:nil];

}

-(void)insertError{
    
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"插入失败，请检查"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cannleAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [alter addAction:cannleAction];
    [self presentViewController:alter animated:YES completion:nil];

}

#pragma mark - DataUpdateViewDelegate
- (void)closeUpdateView{
    
    [_dataUpdateView endEditing:YES];
    NSLog(@"关闭更新视图");
    [UIView animateWithDuration:.2 animations:^{
        _dataUpdateView.frame = CGRectMake(0, -KHeight, KWidth, KHeight);
    } completion:nil];
    
}

-(void)updateSuccess{
    
    _updateCondition = @"";
    //从新读取数据并刷新,判断是在哪里更新的数据
    _allDataArray = [_manager getSheetDataWithSheet:self.title];
    if (![_searchCondition  isEqual: @""]) {
        
        NSLog(@"搜索过了，返回搜索列表数据");
        _allDataArray = [_manager searchDataFromSheet:self.title where:_searchCondition];
        
    }
    [self.tableView reloadData];
    
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"更新成功"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cannleAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self closeUpdateView];
    }];
    [alter addAction:cannleAction];
    [self presentViewController:alter animated:YES completion:nil];
    
}

-(void)updateError{
    
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"更新失败"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cannleAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [alter addAction:cannleAction];
    [self presentViewController:alter animated:YES completion:nil];
    
}


#pragma mark - Action
- (void)_buttonAction:(UIButton *)pButton{
    
    if (pButton.tag == 0) {
        
        NSLog(@"插入数据");
        [UIView animateWithDuration:.3 animations:^{
            _dataInsertView.frame = CGRectMake(0, 0, KWidth, KHeight);
        } completion:^(BOOL finished) {
        }];

    }
    if (pButton.tag == 1) {
        
        pButton.selected = !pButton.selected;
        [self.tableView setEditing:pButton.selected animated:YES];
        
    }
    if (pButton.tag == 2) {
        
        NSLog(@"修改数据");
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"点击数据即可修改"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cannleAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
        [alter addAction:cannleAction];
        [self presentViewController:alter animated:YES completion:nil];

    }
    if (pButton.tag == 3) {
        
        NSLog(@"查找数据");
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"查找"
                                                                       message:@"请输入查找条件,条件为空则获取全部数据;查找条件举例:\"姓名\"=‘LCC’ "
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alter addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            textField.placeholder = @"提示:多个条件之间用and连接";
            
        }];
        
        UIAlertAction *searchAction = [UIAlertAction actionWithTitle:@"查找" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            _searchCondition = alter.textFields[0].text;
            if ([_searchCondition  isEqual: @""]) {
                
                _allDataArray = [_manager getSheetDataWithSheet:self.title];
                [self.tableView reloadData];
                
            }
            else{
                
                _allDataArray = [_manager searchDataFromSheet:self.title where:_searchCondition];
                [self.tableView reloadData];
                
            }
            
        }];
        
        UIAlertAction *cannleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        
        [alter addAction:cannleAction];
        [alter addAction:searchAction];
        _searchCondition = @"";
        [self presentViewController:alter animated:YES completion:nil];

    }

    
}

- (void)_clearCondition{
    
    _searchCondition = @"";
    _updateCondition = @"";
    _deleateCondition = @"";

}
@end
