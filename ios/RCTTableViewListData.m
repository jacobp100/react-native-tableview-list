#import "RCTTableViewListData.h"

@implementation RCTTableViewListRow

- (instancetype)initWithKey:(NSString *)key
{
  if (self = [super init]) {
    _key = key;
  }
  return self;
}

@end

@implementation RCTTableViewListSection

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title rows:(NSArray<RCTTableViewListRow *> *)rows menu:(NSArray<NSDictionary *> *)menu canDeleteRows:(BOOL)canDeleteRows
{
  if (self = [super init]) {
    _key = key;
    _title = title;
    _rows = rows;
    _menu = menu;
    _canDeleteRows = canDeleteRows;
  }
  return self;
}

@end

@implementation RCTTableViewListData

- (instancetype)initWithSections:(NSArray<RCTTableViewListSection *> *)sections
{
  if (self = [super init]) {
    NSMutableDictionary *indexPathForKey = [NSMutableDictionary new];

    for (NSInteger section = 0; section < sections.count; section += 1) {
      NSArray<RCTTableViewListRow *> *rows = sections[section].rows;

      for (NSInteger row = 0; row < rows.count; row += 1) {
        [indexPathForKey
         setObject:[NSIndexPath indexPathForRow:row inSection:section]
         forKey:rows[row].key];
      }
    }

    _sections = sections;
    _indexPathForKey = indexPathForKey;
  }
  return self;
}

@end
