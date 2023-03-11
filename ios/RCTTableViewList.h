#import "RCTTableViewListData.h"
#import <UIKit/UIKit.h>
#import <React/RCTBridge.h>
#import <React/RCTComponent.h>
#import <React/RCTAutoInsetsProtocol.h>

@interface RCTTableViewList : UITableView<UITableViewDelegate, UITableViewDataSource, RCTAutoInsetsProtocol>

- (instancetype)initWithBridge:(RCTBridge *)bridge;

@property (nonatomic, assign) BOOL automaticallyAdjustContentInsets;

@property (nonatomic, copy) RCTTableViewListData *sectionData;
@property (nonatomic, copy) NSArray<NSDictionary *> *menu;
@property (nonatomic, copy) RCTDirectEventBlock onPressRow;
@property (nonatomic, copy) RCTDirectEventBlock onDeleteRow;
@property (nonatomic, copy) RCTDirectEventBlock onMoveRow;
@property (nonatomic, copy) RCTDirectEventBlock onMenu;
@property (nonatomic, copy) RCTDirectEventBlock onVisibleIndexPathsChanged;

// MARK: - ScrollView props
@property (nonatomic, copy) RCTDirectEventBlock onScrollBeginDrag;
@property (nonatomic, copy) RCTDirectEventBlock onScroll;
@property (nonatomic, copy) RCTDirectEventBlock onScrollToTop;
@property (nonatomic, copy) RCTDirectEventBlock onScrollEndDrag;
@property (nonatomic, copy) RCTDirectEventBlock onMomentumScrollBegin;
@property (nonatomic, copy) RCTDirectEventBlock onMomentumScrollEnd;

@end
