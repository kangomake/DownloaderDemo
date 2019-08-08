//
//  GCRSmallFileDownloadViewController.m
//  GCR_DownloadDemo
//
//  Created by gcr on 2019/7/31.
//  Copyright © 2019 teamwork. All rights reserved.
//

#import "GCRSmallFileDownloadViewController.h"

@interface GCRSmallFileDownloadViewController ()

@end

@implementation GCRSmallFileDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"下载小文件";
    
    // Do any additional setup after loading the view.
}

//NSData
- (void)NSDataDownloadSmallFile{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
       
        // 创建下载路径
        NSURL *url = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/1877784-b4777f945878a0b9.jpg"];
        // NSData的dataWithContentsOfURL:方法下载
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 回到主线程，刷新UI
            NSLog(@"%@",data);
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.image = [UIImage imageWithData:data];
        });
        
        
    });
    
    
}

//NSURLConnection
- (void)NSURLConnectionDownloadSmallFile{
    
    NSURL *url = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/1877784-b4777f945878a0b9.jpg"];
    
    // NSURLConnection发送异步Get请求，该方法iOS9.0之后就废除了，推荐NSURLSession
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        // 可以在这里把下载的文件保存
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.image = [UIImage imageWithData:data];
    }];
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
