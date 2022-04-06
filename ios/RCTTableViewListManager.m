#import "RCTTableViewListManager.h"
#import "RCTTableViewList.h"

@implementation RCTTableViewListManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[RCTTableViewList alloc] init];
}

RCT_CUSTOM_VIEW_PROPERTY(sectionData, RCTTableViewListData, RCTTableViewList) {
  NSArray *sectionsJson = [RCTConvert NSArray:json];

  NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:sectionsJson.count];

  for (id sectionJson in sectionsJson) {
    NSArray *jsonRows = [RCTConvert NSArray:sectionJson[@"rows"]];

    NSString *title = [RCTConvert NSString:sectionJson[@"title"]];
    NSString *sectionKey = [RCTConvert NSString:sectionJson[@"key"]];
    NSMutableArray *rows = [[NSMutableArray alloc] initWithCapacity:jsonRows.count];
    NSArray *menu = [RCTConvert NSArray:sectionJson[@"menu"]];
    BOOL canDeleteRows = [RCTConvert BOOL:sectionJson[@"canDeleteRows"]];

    for (id rowJson in jsonRows) {
      NSString *rowKey = [RCTConvert NSString:rowJson[@"key"]];

      [rows addObject:[[RCTTableViewListRow alloc] initWithKey:rowKey]];
    }

    [sections addObject:[[RCTTableViewListSection alloc] initWithKey:sectionKey
                                                               title:title
                                                                rows:rows
                                                                menu:menu
                                                       canDeleteRows:canDeleteRows]];
  }

  view.sectionData = [[RCTTableViewListData alloc] initWithSections:sections];
}

RCT_EXPORT_VIEW_PROPERTY(menu, NSArray)
RCT_EXPORT_VIEW_PROPERTY(rowHeight, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(separatorInset, UIEdgeInsets)
RCT_EXPORT_VIEW_PROPERTY(separatorColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(canDeleteRows, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onPressRow, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDeleteRow, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMenu, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVisibleIndexPathsChanged, RCTDirectEventBlock)

// MARK: - ScrollView props
RCT_EXPORT_VIEW_PROPERTY(alwaysBounceHorizontal, BOOL)
RCT_EXPORT_VIEW_PROPERTY(alwaysBounceVertical, BOOL)
RCT_EXPORT_VIEW_PROPERTY(bounces, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(bouncesZoom, BOOL)
RCT_EXPORT_VIEW_PROPERTY(canCancelContentTouches, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(centerContent, BOOL)
RCT_EXPORT_VIEW_PROPERTY(maintainVisibleContentPosition, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(automaticallyAdjustContentInsets, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(automaticallyAdjustKeyboardInsets, BOOL)
RCT_EXPORT_VIEW_PROPERTY(decelerationRate, CGFloat)
//RCT_EXPORT_VIEW_PROPERTY(directionalLockEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(indicatorStyle, UIScrollViewIndicatorStyle)
RCT_EXPORT_VIEW_PROPERTY(keyboardDismissMode, UIScrollViewKeyboardDismissMode)
//RCT_EXPORT_VIEW_PROPERTY(maximumZoomScale, CGFloat)
//RCT_EXPORT_VIEW_PROPERTY(minimumZoomScale, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(scrollEnabled, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(pagingEnabled, BOOL)
//RCT_REMAP_VIEW_PROPERTY(pinchGestureEnabled, scrollView.pinchGestureEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(scrollsToTop, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, BOOL)
RCT_EXPORT_VIEW_PROPERTY(scrollEventThrottle, NSTimeInterval)
//RCT_EXPORT_VIEW_PROPERTY(zoomScale, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(contentInset, UIEdgeInsets)
RCT_EXPORT_VIEW_PROPERTY(scrollIndicatorInsets, UIEdgeInsets)
RCT_EXPORT_VIEW_PROPERTY(scrollToOverflowEnabled, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(snapToInterval, int)
//RCT_EXPORT_VIEW_PROPERTY(disableIntervalMomentum, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(snapToOffsets, NSArray<NSNumber *>)
//RCT_EXPORT_VIEW_PROPERTY(snapToStart, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(snapToEnd, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(snapToAlignment, NSString)
RCT_EXPORT_VIEW_PROPERTY(contentOffset, CGPoint)
RCT_EXPORT_VIEW_PROPERTY(onScrollBeginDrag, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onScroll, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onScrollToTop, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onScrollEndDrag, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onMomentumScrollBegin, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onMomentumScrollEnd, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(inverted, BOOL)
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 /* __IPHONE_13_0 */
RCT_EXPORT_VIEW_PROPERTY(automaticallyAdjustsScrollIndicatorInsets, BOOL)
#endif
RCT_EXPORT_VIEW_PROPERTY(contentInsetAdjustmentBehavior, UIScrollViewContentInsetAdjustmentBehavior)

@end
