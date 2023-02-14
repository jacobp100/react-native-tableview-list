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
