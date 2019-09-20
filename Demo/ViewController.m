//
//  ViewController.m
//  Demo
//
//  Created by ZCGC on 2019/9/16.
//  Copyright © 2019 getElementByYou. All rights reserved.
//

#import "ViewController.h"
#import "ELCardScrollView.h"

@interface ViewController ()

@property (nonatomic, strong) ELCardScrollView * cardScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    ELCardScrollViewConfigModel * configModel = [[ELCardScrollViewConfigModel alloc]init];
    configModel.imageMargin = 6;
    configModel.imageArray = @[[UIImage imageNamed:@"01"],
                               [UIImage imageNamed:@"02"],
                               [UIImage imageNamed:@"03"],
                               [UIImage imageNamed:@"04"],
                               [UIImage imageNamed:@"05"]];
    configModel.SelectBlock = ^(NSInteger index) {
        NSLog(@"%ld",index);
    };
    self.cardScrollView = [[ELCardScrollView alloc]initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 115) configModel:configModel];
    [self.view addSubview:self.cardScrollView];
}


@end
