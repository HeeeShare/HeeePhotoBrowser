//
//  DetailViewController.m
//  HeeePhotoBrowser-demo
//
//  Created by hgy on 2018/10/17.
//  Copyright © 2018年 hgy. All rights reserved.
//
#define kUIScreen_width [[UIScreen mainScreen] bounds].size.width
#define kUIScreen_height [[UIScreen mainScreen] bounds].size.height

#import "DetailViewController.h"
#import "HeeePhotoBrowser.h"
#import "UIImageView+WebCache.h"

@interface DetailViewController ()<HeeePhotoBrowserDelegate>
@property (nonatomic,strong) NSMutableArray *IVArr;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片详情";
    self.view.backgroundColor = [UIColor whiteColor];
    _IVArr = [NSMutableArray array];
    
    NSArray *urlArr = @[
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1541153925255&di=068103a39c73a6b5bdbe57402a40755f&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01641f5a61925fa80120121fef7c46.jpg%401280w_1l_2o_100sh.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461180197&di=a23a9834a7b431c9c576f1b35bdb2298&imgtype=jpg&src=http%3A%2F%2Fimg0.imgtn.bdimg.com%2Fit%2Fu%3D3564877025%2C796183547%26fm%3D214%26gp%3D0.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461301631&di=fc9f49499318ba398a469f4be601b516&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2Fa%2F55f8c18720263.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461151728&di=2460be17ebf7d1ea7526ef25e00c6b76&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F5%2F532931489604e.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525606577982&di=2cba09247182622852d3d92e888b64d9&imgtype=0&src=http%3A%2F%2Fp8.qhimg.com%2Ft016ff4d49031ff3653.png",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539781470113&di=2d4e9600e7580773870ebb6b063b7173&imgtype=0&src=http%3A%2F%2Fimg2.ddove.com%2Fupload%2F20120906%2F060740261074.jpg"
                        ];
    
    CGFloat w = (kUIScreen_width - 2*10 - 2*5)/3;
    CGFloat h = w*3/4;
    
    for (int i = 0; i < urlArr.count; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10 + (w + 5)*(i%3), 100 + (h + 5)*(i/3), w, h)];
        [_IVArr addObject:iv];
        iv.clipsToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
        [iv addGestureRecognizer:tap];
        [iv sd_setImageWithURL:[NSURL URLWithString:urlArr[i]] placeholderImage:[UIImage imageNamed:@"默认图片加载.png"]];
        [self.view addSubview:iv];
    }
}

- (void)imageClick:(UIGestureRecognizer *)gestureRecognizer {
    UIView *IV = gestureRecognizer.view;    
    HeeePhotoBrowser *photoBrowser = [HeeePhotoBrowser showPhotoBrowserWithImageView:_IVArr clickImageIndex:[_IVArr indexOfObject:IV] andHighQualityImageArray:nil];
    photoBrowser.delegate = self;
}

#pragma mark - HeeePhotoBrowserDelegate
- (void)photoBrowser:(HeeePhotoBrowser *)photoBrowser didScrollToIndex:(NSInteger)index {
    
}

- (void)photoBrowserDidDisappear:(HeeePhotoBrowser *)photoBrowser {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
