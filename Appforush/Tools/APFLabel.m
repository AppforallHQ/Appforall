//
//  APFLabel.m
//  PROJECT
//
//  Created by PROJECT on 3/June/14.
//  Copyright (c) 2014 PROJECT. All rights reserved.
//

#import "APFLabel.h"

@implementation APFLabel

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.font = [UIFont fontWithName:@"IRANSans" size:self.font.pointSize];
    }
    return self;
}

-(void)setText:(NSString *)text {
    if(!_arabicDigits) {
        _arabicDigits = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
        _hindiDigits = @[@"۰", @"۱", @"۲", @"۳", @"۴", @"۵", @"۶", @"۷", @"۸", @"۹"];
    }
    
    for(int i = 0; i <= 9; i++) {
        text = [text stringByReplacingOccurrencesOfString:[_arabicDigits objectAtIndex:i] withString:[_hindiDigits objectAtIndex:i]];
    }
    
    [super setText:text];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
