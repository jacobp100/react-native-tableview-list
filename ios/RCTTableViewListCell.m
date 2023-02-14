#import "RCTTableViewListCell.h"
#import <React/RCTUIManager.h>

@implementation RCTTableViewListCell

- (void)layoutSubviews
{
  [super layoutSubviews];

  UIView *reactView = [self.contentView.subviews firstObject];
  if (reactView == nil) {
    return;
  }

  CGSize contentSize = self.contentView.frame.size;
  if (!CGSizeEqualToSize(contentSize, reactView.frame.size)) {
    // Needed to handle safe areas
    [_bridge.uiManager setSize:contentSize
                       forView:reactView];
  }
}

@end
