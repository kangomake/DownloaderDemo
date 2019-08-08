//
//  ViewController.m
//  GCR_DownloadDemo
//
//  Created by gcr on 2019/7/31.
//  Copyright © 2019 teamwork. All rights reserved.
//

#import "ViewController.h"
#import "GCRNSURLConnectionBigFileDownloadController.h"

// 当前屏幕宽
#define kScreenWidth   ([UIScreen mainScreen].bounds.size.width)

// 当前屏幕高
#define kScreenHeight  ([UIScreen mainScreen].bounds.size.height)

//iphone X
#define is_iPhoneX [UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f
#define kMainScreenHeight_x  ([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f ? ([UIScreen mainScreen].bounds.size.height - 88) :([UIScreen mainScreen].bounds.size.height - 64))
#define kNaviHeight ([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f ? 88 : 64)
#define kStatusBarHeight  ([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f ? 44 : 20)
#define kTabbarHeight ([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f ? 83 : 49)
#define kBottomHeight ([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f ? 34 : 0)


#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(1)];



@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSArray *dataSource;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    
    // Do any additional setup after loading the view, typically from a nib.
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.textColor = RGB(102, 102, 102);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row ==0){
        
    }else if (indexPath.row == 1){
        GCRNSURLConnectionBigFileDownloadController *VC = [[GCRNSURLConnectionBigFileDownloadController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
    }

    
    
}


- (UITableView *)tableView{
    
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNaviHeight, kScreenWidth, kMainScreenHeight_x-60) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]init];
        _tableView.separatorColor = RGB(235, 235, 235);
        _tableView.scrollEnabled = YES;
        
    }
    
    return _tableView;
}

- (NSArray *)dataSource{
    if(!_dataSource){
        _dataSource = @[@"下载小文件",@"下载大文件",@"离线下载大文件"];
    }
    return _dataSource;
}


@end
