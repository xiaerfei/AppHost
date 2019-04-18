//
//  MKNavigationResponse.m

//
//  Created by liang on 05/01/2018.
//  Copyright © 2018 smilly.co All rights reserved.
//

#import "AHNavigationResponse.h"
#import "AppHostViewController.h"

@import SafariServices;

@implementation AHNavigationResponse

+ (NSDictionary<NSString *, NSString *> *)supportActionList
{
    return @{
        //增加apphost的supportTypeFunction
        @"startNewPage" : @"4",
        @"openUrl" : @"3",
        @"openExternalUrl" : @"1"
    };
}

#pragma mark - inner

- (void)openUrl:(NSDictionary *)paramDict
{
    NSString *urlTxt = [paramDict objectForKey:@"url"];
    BOOL forceOpenInSafari = [[paramDict objectForKey:@"openInBrowser"] boolValue];
    if (forceOpenInSafari) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlTxt] options:@{} completionHandler:nil];
    } else {
        NSURL *actualUrl = [NSURL URLWithString:urlTxt];
        [[UIApplication sharedApplication] openURL:actualUrl options:@{} completionHandler:nil];
    }
}

- (void)openExternalUrl:(NSDictionary *)paramDict
{
    NSString *url = [paramDict objectForKey:@"url"];
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
    [self.navigationController presentViewController:safari animated:YES completion:nil];
}

- (void)insertShadowView:(NSDictionary *)paramDict
{

    AppHostViewController *freshOne = [[AppHostViewController alloc] init];
    freshOne.url = [paramDict objectForKey:@"url"];
    freshOne.pageTitle = [paramDict objectForKey:@"title"];
    freshOne.rightActionBarTitle = [paramDict objectForKey:@"actionTitle"];
    freshOne.backPageParameter = [paramDict objectForKey:@"backPageParameter"];
    //
    NSArray *viewControllers = self.navigationController.viewControllers;

    if (viewControllers.count > 0) {
        //在A->B页面里，点击返回到C，然后C返回到A，形成 A-C-B，简化下成A——C；
        NSMutableArray *newViewControllers = [viewControllers mutableCopy];
        [newViewControllers addObject:freshOne];
        freshOne.hidesBottomBarWhenPushed = YES;
        self.navigationController.viewControllers = newViewControllers;
    }
}

- (void)startNewPage:(NSDictionary *)paramDict
{
    AppHostViewController *freshOne = [[AppHostViewController alloc] init];
    freshOne.url = [paramDict objectForKey:@"url"];
    freshOne.pageTitle = [paramDict objectForKey:@"title"];
    freshOne.rightActionBarTitle = [paramDict objectForKey:@"actionTitle"];

    freshOne.backPageParameter = [paramDict objectForKey:@"backPageParameter"];
    NSString *loadType = [paramDict objectForKey:@"type"];
    if (freshOne.backPageParameter) {
        //额外插入一个页面；
        [self insertShadowView:freshOne.backPageParameter];
    }
    if ([@"replace" isEqualToString:loadType]) {
        NSArray *viewControllers = self.navigationController.viewControllers;

        if (viewControllers.count > 1) {
            // replace的目的就是调整到新的list页面；需要替换旧list和新的回复页面；
            NSMutableArray *newViewControllers = [[viewControllers subarrayWithRange:NSMakeRange(0, [viewControllers count] - 2)] mutableCopy];
            [newViewControllers addObject:freshOne];
            freshOne.hidesBottomBarWhenPushed = YES;
            [self.navigationController setViewControllers:newViewControllers animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.navigationController pushViewController:freshOne animated:YES];
    }
}
@end
