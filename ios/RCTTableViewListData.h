typedef NS_ENUM(NSInteger, RCTTableViewListRowMoving) {
  RCTTableViewListRowMovingNone,
  RCTTableViewListRowMovingWithinSection
};

@interface RCTTableViewListRow : NSObject

- (instancetype)initWithKey:(NSString *)key;
@property (nonatomic, copy) NSString *key;

@end

@interface RCTTableViewListSection : NSObject

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title rows:(NSArray<RCTTableViewListRow *> *)rows menu:(NSArray<NSDictionary *> *)menu canDeleteRows:(BOOL)canDeleteRows moveRows:(RCTTableViewListRowMoving)moveRows;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<RCTTableViewListRow *> *rows;
@property (nonatomic, copy) NSArray<NSDictionary *> *menu;
@property (nonatomic, assign) BOOL canDeleteRows;
@property (nonatomic, assign) RCTTableViewListRowMoving moveRows;

@end

@interface RCTTableViewListData : NSObject

- (instancetype)initWithSections:(NSArray<RCTTableViewListSection *> *)sections;
@property (nonatomic, copy) NSArray<RCTTableViewListSection *> *sections;
@property (nonatomic, copy) NSDictionary<NSString *, NSIndexPath *> *indexPathForKey;

@end
