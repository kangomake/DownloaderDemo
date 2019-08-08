//
//  GCRNSURLConnectionBigFileDownloadController.m
//  GCR_DownloadDemo
//
//  Created by gcr on 2019/7/31.
//  Copyright © 2019 teamwork. All rights reserved.
//

#import "GCRNSURLConnectionBigFileDownloadController.h"

@interface GCRNSURLConnectionBigFileDownloadController ()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) NSInteger fileLength;
@property (nonatomic, assign) NSInteger currentLength;
@property (nonatomic, strong) NSFileHandle *fileHandle;

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong) UILabel * progressLabel;

@end

@implementation GCRNSURLConnectionBigFileDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"NSURLConnection下载大文件";
    
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadBtn.frame = CGRectMake(20, 100, 120, 40);
    downloadBtn.backgroundColor = [UIColor purpleColor];
    [downloadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [downloadBtn setTitle:@"download" forState:UIControlStateNormal];
    [downloadBtn setTitle:@"cancel" forState:UIControlStateSelected];
    [downloadBtn addTarget:self action:@selector(downloadBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadBtn];
    
    
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.progressLabel];
    
//    NSURL *url = [NSURL URLWithString:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg"];
//    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
    
    // Do any additional setup after loading the view.
}

/*
 NSURLConnection并没有提供暂停下载的方法，只提供了取消下载任务的cancel方法。
 那么，如果我们想要使用NSURLConnection来实现断点下载的功能，就需要先了解HTTP请求头中Range的知识点。
 HTTP请求头中的Range可以只请求实体的一部分，指定范围。
 Range请求头的格式为： Range: bytes=start-end
 例如：
 Range: bytes=10-：表示第10个字节及最后个字节的数据。
 Range: bytes=40-100：表示第40个字节到第100个字节之间的数据。
 注意：这里的[start,end]，即是包含请求头的start及end字节的。所以，下一个请求，应该是上一个请求的[end+1, nextEnd]。
 所以我们需要做的步骤为：
 
 添加需要实现断点下载的[开始/暂停]按钮。
 设置一个NSURLConnection的全局变量。
 如果继续下载，设置HTTP请求头的Range为当前已下载文件的长度位置到最后文件末尾位置。然后创建一个NSURLConnection发送异步下载，并监听代理方法。
 如果暂停下载，那么NSURLConnection发送取消下载方法，并清空。
 
 作者：行走少年郎
 链接：https://www.jianshu.com/p/ce3eaee74bde
 */


- (void)downloadBtn:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    if(sender.selected){// [开始下载/继续下载]
        
        // 沙盒文件路径
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"QQ_V5.4.0.dmg"];
        
        NSInteger currentLength = [self fileLengthForPath:path];
        if(currentLength >0){// [继续下载]
            self.currentLength = currentLength;
        }
        
        // 创建下载URL
        NSURL *url = [NSURL URLWithString:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg"];
        
        // 2.创建request请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 设置HTTP请求头中的Range
        NSString *range = [NSString stringWithFormat:@"bytes=%ld-",self.currentLength];
        [request  setValue:range forHTTPHeaderField:@"Range"];
        
        // 3.下载
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        
    }else{// [暂停下载]
        
        [self.connection cancel];
        self.connection = nil;
        
    }
    
    
    
    
}


/**
 * 获取已下载的文件大小
 */
- (NSInteger)fileLengthForPath:(NSString *)path{
    
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if([fileManager fileExistsAtPath:path]){
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if(!error && fileDict){
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}

#pragma mark --<NSURLConnectionDataDelegate>

/**
 * 接收到响应的时候：创建一个空的沙盒文件
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSLog(@"response_%@",response);
    // 获得下载文件的总长度
    self.fileLength = response.expectedContentLength +self.currentLength;
    // 沙盒文件路径
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"QQ_V5.4.0.dmg"];
    
    NSLog(@"File downloaded to: %@",path);
    
    // 创建一个空的文件到沙盒中
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:path]){
        // 如果没有下载文件的话，就创建一个文件。如果有下载文件的话，则不用重新创建(不然会覆盖掉之前的文件)
        [manager createFileAtPath:path contents:nil attributes:nil];
    }
    
    
    // 创建文件句柄
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    
}

/**
 * 接收到具体数据：把数据写入沙盒文件中
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"data-%@",data);
    
    // 指定数据的写入位置 -- 文件内容的最后面
    [self.fileHandle seekToEndOfFile];
    
    // 向沙盒写入数据
    [self.fileHandle writeData:data];
    
    // 拼接文件总长度
    self.currentLength += data.length;
    
    // 下载进度
    self.progressView.progress = 1.0*self.currentLength/self.fileLength;
    self.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%",100.0 * self.currentLength / self.fileLength];

}

/**
 *  下载完文件之后调用：关闭文件、清空长度
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    // 关闭fileHandle
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    
    // 清空长度
    self.currentLength = 0;
    self.fileLength = 0;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}


#pragma mark -- setter
- (UIProgressView *)progressView{
    
    if(!_progressView){
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(50, 200, 260, 50)];
        _progressView.backgroundColor = [UIColor lightTextColor];
    }
    return _progressView;
}


- (UILabel *)progressLabel{
    
    if(!_progressLabel){
        _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 260, 200, 40)];
        _progressLabel.backgroundColor = [UIColor whiteColor];
        _progressLabel.textColor = [UIColor orangeColor];
        _progressLabel.font = [UIFont systemFontOfSize:15];
    }
    return _progressLabel;
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
