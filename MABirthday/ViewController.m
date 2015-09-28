//
//  ViewController.m
//  MABirthday
//
//  Created by admin on 15/9/24.
//  Copyright © 2015年 kf5. All rights reserved.
//

#define SNOW_IMAGENAME         @"snow"

// MainScreen Height&Width
#define Main_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width       [[UIScreen mainScreen] bounds].size.width

#define IMAGE_X                arc4random()%(int)Main_Screen_Width
#define IMAGE_ALPHA            ((float)(arc4random()%10))/10
#define IMAGE_WIDTH            arc4random()%20 + 10
#define PLUS_HEIGHT            Main_Screen_Height/25

#define MWColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define kScreenSize    [UIScreen mainScreen].bounds.size

#import "ViewController.h"
#import "ZYAnimationLayer.h"
#import "MAPlayer.h"

@interface ViewController ()<MAPlayerDelegate>

@property (nonatomic, strong) NSMutableArray *imagesArray;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *textArray;

@property (nonatomic, strong) NSTimer *time;

@property (nonatomic, assign) BOOL isStop;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MWColor(77, 206, 238);
    self.isStop = NO;
    
    // 0.加载音乐
    [self loadMusic];
    
    // 1.添加文字
    [self loadText];
    
    // 2.加载雪花
    [self loadSnow];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(loadHapplyBirthdayMusic)];
    [self.scrollView addGestureRecognizer:longGesture];
}
#pragma mark - 音乐
- (void)loadMusic
{
    [MAPlayer sharedMAPlayer].delegate = self;
    [self loadFirstMusic];
}

- (void)loadHapplyBirthdayMusic
{
    [[MAPlayer sharedMAPlayer] loadMusicWithMusicURL:@"http://125.70.12.9:2873/happyBirthday.mp3"];
    [[MAPlayer sharedMAPlayer] setTitle:@"星星" artist:@"我爱你" albumTitle:@"生日快乐"];
    [[MAPlayer sharedMAPlayer] play];
}

- (void)loadFirstMusic
{
    [[MAPlayer sharedMAPlayer] loadMusicWithMusicURL:@"http://125.70.12.9:2873/theCityOfSky.mp3"];
    [[MAPlayer sharedMAPlayer] setTitle:@"星星我爱你" artist:@"天空之城" albumTitle:@"生日快乐"];
    [[MAPlayer sharedMAPlayer] play];
}

- (void)loadSecondMusic
{
    [[MAPlayer sharedMAPlayer] loadMusicWithMusicURL:@"http://125.70.12.9:2873/theDreamWedding.mp3"];
    [[MAPlayer sharedMAPlayer] setTitle:@"星星我爱你" artist:@"空中的婚礼" albumTitle:@"生日快乐"];
    [[MAPlayer sharedMAPlayer] play];
}

#pragma mark MAPlayerDelegate
- (void)playerWithPlayEndWithMAPlayer:(MAPlayer *)player
{
    if (self.view.tag == 1) {
        [self loadFirstMusic];
    }else{
        [self loadSecondMusic];
    }
    self.view.tag = !self.view.tag;
}
- (void)playerStatusFailedWithMAPlayer:(MAPlayer *)player
{
    [player player];
}

#pragma mark - 文字
- (void)loadText
{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    self.textArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"text" ofType:@"plist"]];
    
    self.time = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(markText) userInfo:nil repeats:YES];
}

static int idx = 0;
- (void)markText
{
    if (idx > self.textArray.count - 1) {
        [self.time invalidate];
        [[MAPlayer sharedMAPlayer]pause];
        self.isStop = YES;
        return;
    }
    NSString *text = self.textArray[idx];

    CGFloat height = 40;
    CGFloat width = kScreenSize.width;
    CGRect frame = CGRectMake(0, idx * (height + 10) + 20, width, height);
    
    [ZYAnimationLayer createAnimationLayerWithString:text andRect:frame  andView:self.scrollView andFont:[UIFont boldSystemFontOfSize:38] andStrokeColor:[self randomColor]];

    self.scrollView.contentSize = CGSizeMake(width, CGRectGetMaxY(frame));
    CGFloat offsetY = CGRectGetMaxY(frame) - kScreenSize.height + 50;
    [self.scrollView setContentOffset:CGPointMake(0, offsetY > 0 ? offsetY : 0) animated:YES];
    idx++;
    if (text.length == 0) {
        [self markText];
    }
}

#pragma mark - 雪花
- (void)loadSnow
{
    _imagesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; ++ i) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SNOW_IMAGENAME]];
        float x = IMAGE_WIDTH;
        imageView.frame = CGRectMake(IMAGE_X, -30, x, x);
        imageView.alpha = IMAGE_ALPHA;
        [self.view addSubview:imageView];
        [_imagesArray addObject:imageView];
    }
    [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(makeSnow) userInfo:nil repeats:YES];
}
static int i = 0;
- (void)makeSnow
{
    i = i + 1;
    if ([_imagesArray count] > 0) {
        UIImageView *imageView = [_imagesArray objectAtIndex:0];
        imageView.tag = i;
        [_imagesArray removeObjectAtIndex:0];
        [self snowFall:imageView];
    }
    
}
- (void)snowFall:(UIImageView *)aImageView
{
    [UIView beginAnimations:[NSString stringWithFormat:@"%d",(int)aImageView.tag] context:nil];
    [UIView setAnimationDuration:6];
    [UIView setAnimationDelegate:self];
    aImageView.frame = CGRectMake(aImageView.frame.origin.x, Main_Screen_Height, aImageView.frame.size.width, aImageView.frame.size.height);
    [UIView commitAnimations];
}
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:[animationID intValue]];
    float x = IMAGE_WIDTH;
    imageView.frame = CGRectMake(IMAGE_X, -30, x, x);
    [_imagesArray addObject:imageView];
}

-(UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
