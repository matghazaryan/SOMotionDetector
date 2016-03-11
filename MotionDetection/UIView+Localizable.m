//
//  UIView+Localizable.m
//  Wantz
//
//  Created by Narek Haytyan on 05/07/13.
//  Copyright (c) 2013 SocialObjects Software. All rights reserved.
//

#import <objc/runtime.h>

static char fontNameKey;

@implementation UIView (Localizable)

- (NSString *)fontName
{
    return objc_getAssociatedObject(self, &fontNameKey);
}

- (void)setFontName:(NSString *)fontName
{
    objc_setAssociatedObject(self, &fontNameKey, fontName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// using for localize storyboard file due to we want to have one storyboard
- (void)awakeFromNib
{
    if ([self.class isSubclassOfClass:[UIButton class]]) {
        UIButton *view = (UIButton *)self;
        NSString *str = NSLocalizedString(view.titleLabel.text, nil);
        if(self.fontName.length) {
            view.titleLabel.font = [UIFont fontWithName:view.fontName size:view.titleLabel.font.pointSize];
        }
        [view setTitle:str forState:UIControlStateNormal];
    } else if ([self.class isSubclassOfClass:[UILabel class]]) {
        UILabel *view = (UILabel *)self;
        if(self.fontName.length) {
            view.font = [UIFont fontWithName:view.fontName size:view.font.pointSize];
        }
        NSString *str = NSLocalizedString([view text], nil);
        str = [str stringByReplacingOccurrencesOfString:@"{newline}" withString:@"\n"];        
        view.text = str;
    } else if([self.class isSubclassOfClass:[UITabBar class]]) {
        UITabBar *view = (UITabBar*)self;
        for (UITabBarItem *item in view.items) {
            item.title = NSLocalizedString(item.title,nil);
        }
    } else if([self.class isSubclassOfClass:[UITextField class]]) {
        UITextField *view = (UITextField*)self;
        if (![view.text isEqualToString:@""]) {
            NSString *str = NSLocalizedString(view.text, nil);;
            view.text = str;
        }
        if(self.fontName.length) {
            view.font = [UIFont fontWithName:view.fontName size:view.font.pointSize];
        }
        view.placeholder = NSLocalizedString(view.placeholder, nil);
    } else if([self.class isSubclassOfClass:[UITextView class]]) {
        UITextView *view = (UITextView*)self;
        NSString *str = NSLocalizedString(view.text, nil);
        str = [str stringByReplacingOccurrencesOfString:@"{newline}" withString:@"\n"];
        view.text = str;
        if(self.fontName.length) {
            view.font = [UIFont fontWithName:view.fontName size:view.font.pointSize];
        }
    } else if([self.class isSubclassOfClass:[UINavigationBar class]]) {
        UINavigationBar *view = (UINavigationBar *)self;
        view.topItem.title = NSLocalizedString(view.topItem.title, nil);
    } else if(![self.class isSubclassOfClass:[UIImageView class]] &&
              ![self.class isSubclassOfClass:[UIScrollView class]] &&
              ![self.class isSubclassOfClass:[UITableViewCell class]]) {
    }
}

@end
