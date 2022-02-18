//
//  NativeAdViewC.m
//  Astri
//
//  Created by Alexandre on 2/9/22.
//

#import "NativeAdView.h"

@interface NativeAdView ()
//required
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *callToActionLabel;
//optional
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UIView *adChoicesView;

//@property (weak, nonatomic) IBOutlet UIView *mediaContainerView;
@end

@implementation NativeAdView

+ (UINib *)nib {
    return [UINib nibWithNibName:@"Native" bundle:[NSBundle bundleForClass:NativeAdView.class]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NativeAdView * nativeView = [super initWithCoder:aDecoder];
    return nativeView;
}

- (void)drawRect:(CGRect)rect {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8.0;
    self.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    
    self.iconView.layer.cornerRadius = 8.0;
    self.iconView.layer.masksToBounds = YES;
    
    self.callToActionLabel.layer.cornerRadius = 4.0;
    self.callToActionLabel.layer.masksToBounds = YES;
    self.callToActionLabel.layer.borderWidth = 1.0;
    self.callToActionLabel.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.descriptionLabel.layer.masksToBounds = YES;
    self.iconView.layer.masksToBounds = YES;
    self.adChoicesView.layer.masksToBounds = YES;
}

@end
