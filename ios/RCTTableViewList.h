#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>
#import <React/RCTAutoInsetsProtocol.h>

@interface RCTTableViewListRow : NSObject

- (instancetype)initWithKey:(NSString *)key;
@property (nonatomic, copy) NSString *key;

@end

@interface RCTTableViewListSection : NSObject

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title rows:(NSArray<RCTTableViewListRow *> *)rows menu:(NSArray<NSDictionary *> *)menu canDeleteRows:(BOOL)canDeleteRows;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<RCTTableViewListRow *> *rows;
@property (nonatomic, copy) NSArray<NSDictionary *> *menu;
@property (nonatomic, assign) BOOL canDeleteRows;

@end

@interface RCTTableViewListData : NSObject

- (instancetype)initWithSections:(NSArray<RCTTableViewListSection *> *)sections;
@property (nonatomic, copy) NSArray<RCTTableViewListSection *> *sections;
@property (nonatomic, copy) NSDictionary<NSString *, NSIndexPath *> *indexPathForKey;

@end

@interface RCTTableViewList : UITableView<UITableViewDelegate, UITableViewDataSource, RCTAutoInsetsProtocol>

@property (nonatomic, assign) BOOL automaticallyAdjustContentInsets;

@property (nonatomic, copy) RCTTableViewListData *sectionData;
@property (nonatomic, copy) NSArray<NSDictionary *> *menu;
@property (nonatomic, copy) RCTDirectEventBlock onPressRow;
@property (nonatomic, copy) RCTDirectEventBlock onDeleteRow;
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
