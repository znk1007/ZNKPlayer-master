//
//  ZFTableViewController.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFTableViewController.h"
#import "ZFPlayerCell.h"
#import "ZFPlayerModel.h"
#import "ZFPlyerResolution.h"
//#import <Masonry/Masonry.h>
//#import <ZFDownload/ZFDownloadManager.h>

@interface ZFTableViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) AYPlayer   *playerView;

@end

/*
 巴黎宝贝 http://jq.v.ismartv.tv/cdn/1/81/ ... al/slice/index.m3u8
 星空国际 http://att.livem3u8.na.itv.cn/li ... a68356f8c2bd00.m3u8
 凤凰中文 http://210.51.19.156/live/iphone/zxt/index_350k.m3u8
 凤凰资讯 http://210.51.19.156/live/iphone/zwt/index_350k.m3u8
 星空卫视 http://att.livem3u8.na.itv.cn/li ... a68356f8c2bd00.m3u8
 BBC新闻 http://akamedia2.lsops.net/live/ ... .smil/playlist.m3u8
 CNN http://akamedia2.lsops.net/live/smil:cnn_en.smil/playlist.m3u8
 ICN纽约中文台 http://att.livem3u8.na.itv.cn/li ... ad.m3u8?bitrate=800
 ICN洛杉矶中文台 http://att.livem3u8.na.itv.cn/li ... e9.m3u8?bitrate=800
 ICN旧金山中文台 http://att.livem3u8.na.itv.cn/li ... e7.m3u8?bitrate=800
 日本放送协会（NHK） http://plslive3.nhk.or.jp/nhkworld/app/live.m3u8
 韩国KBS  http://news24kbs-2.gscdn.com/new ... tream/playlist.m3u8
 韩国WOW  http://wowmlive.shinbnstar.com:1935/live2/wowtv/playlist.m3u8
 韩国独岛实况摄像头 http://kbs-dokdo.gscdn.com/dokdo ... tream/playlist.m3u8
 越南VTV1  http://112.197.2.16:1935/live/vtv1.stream/playlist.m3u8
 伊朗Press http://akamedia2.lsops.net/live/ ... .smil/playlist.m3u8
 维京电台 http://wow01.105.net/live/virgin1/playlist.m3u8
 法国24 http://stream7.france24.yacast.n ... fr/iPad.f24_fr.m3u8
 法国时尚 http://217.146.95.164:8081/ch27yiphone.m3u8
 德国arte http://iphone.envivio.com/iphone/downloads/ch1/index.m3u8
 美国NASA http://www.nasa.gov/multimedia/nasatv/NTV-Public-IPS.m3u8
 今日俄罗斯 RussiaToday http://akamedia2.lsops.net/live/ ... .smil/playlist.m3u8
 半岛电视台  http://akamedia2.lsops.net/live/ ... .smil/playlist.m3u8
 */

@implementation ZFTableViewController

#pragma mark - life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 379.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self requestData];
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"ZFPlayerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ZFPlayerCell"];
//    [self.tableView registerClass:[ZFPlayerCell class] forCellReuseIdentifier:@"playerCell"];
}

// 页面消失时候
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.playerView resetPlayer];
    [self.playerView prepareToPlay];
}

- (void)requestData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"videoData" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    self.dataSource = @[].mutableCopy;
    NSArray *videoList = [rootDict objectForKey:@"videoList"];
    for (NSDictionary *dataDic in videoList) {
        ZFPlayerModel *model = [[ZFPlayerModel alloc] init];
        [model setValuesForKeysWithDictionary:dataDic];
        [self.dataSource addObject:model];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view.backgroundColor = [UIColor whiteColor];
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier        = @"playerCell1";
    ZFPlayerCell *cell                 = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
//    ZFPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell == nil) {
//        cell = [[ZFPlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        
////        cell = [[[NSBundle mainBundle]loadNibNamed:@"ZFPlayerCell" owner:self options:nil]lastObject];
//    }
    // 取到对应cell的model
    __block ZFPlayerModel *model       = self.dataSource[indexPath.row];
    // 赋值model
    cell.model                         = model;
    
    __block NSIndexPath *weakIndexPath = indexPath;
    __block ZFPlayerCell *weakCell     = cell;
    __weak typeof(self) weakSelf       = self;
    // 点击播放的回调
    cell.playBlock = ^(UIButton *btn){
        weakSelf.playerView = [AYPlayer sharedPlayerView];
        // 设置播放前的站位图（需要在设置视频URL之前设置）
        weakSelf.playerView.placeholderImageName = @"loading_bgView1";
        
        // 分辨率字典（key:分辨率名称，value：分辨率url)
        NSMutableDictionary *dic = @{}.mutableCopy;
        for (ZFPlyerResolution * resolution in model.playInfo) {
            [dic setValue:resolution.url forKey:resolution.name];
        }
        // 取出字典中的第一视频URL
        NSURL *videoURL = [NSURL URLWithString:dic.allValues.firstObject];
        
        // 设置player相关参数(需要设置imageView的tag值，此处设置的为101)
        [weakSelf.playerView setVideoURL:videoURL
                           withTableView:weakSelf.tableView
                             AtIndexPath:weakIndexPath
                        withImageViewTag:101];
        [weakSelf.playerView addPlayerToCellImageView:weakCell.picView];
//        weakSelf.playerView.title = @"可以设置视频的标题";

//        // 下载功能
//        weakSelf.playerView.hasDownload   = YES;
//        // 下载按钮的回调
//        weakSelf.playerView.downloadBlock = ^(NSString *urlStr) {
//            // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
//            NSString *name = [urlStr lastPathComponent];
//            [[ZFDownloadManager sharedDownloadManager] downFileUrl:urlStr filename:name fileimage:nil];
//            // 设置最多同时下载个数（默认是3）
//            [ZFDownloadManager sharedDownloadManager].maxCount = 1;
//        };
        
//        // 赋值分辨率字典
//        weakSelf.playerView.resolutionDic = dic;
        //（可选设置）可以设置视频的填充模式，默认为（等比例填充，直到一个维度到达区域边界）
        weakSelf.playerView.playerLayerGravity = AYPlayerLayerGravityAspectFit;
        [weakSelf.playerView prepareToPlay];
        // 自动播放
        [weakSelf.playerView autoToplay];
    };

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath---%zd",indexPath.row);
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
