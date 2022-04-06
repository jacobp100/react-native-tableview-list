#import "RCTTableViewList.h"
#import <React/UIView+React.h>
#import <React/RCTView.h>
#import <React/RCTConvert.h>
#import <React/RCTScrollEvent.h>

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

@implementation RCTTableViewList {
  BOOL _ready;
  NSMutableDictionary<NSString *, UIView *> *_cells;
  UIView *_listEmptyView;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.delegate = self;
    self.dataSource = self;
    _cells = [NSMutableDictionary new];
    [self registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];

    // React Native defaults
    self.backgroundColor = [UIColor clearColor];
  }
  return self;
}

-(void)didSetProps:(NSArray<NSString *> *)changedProps
{
  // Stops rows changing height as mounting (and flickering)
  if (!_ready) {
    _ready = YES;
    [self reloadData];
  }
}

- (void)setSectionData:(RCTTableViewListData *)sectionData
{
  BOOL skipReload = [_sectionData.indexPathForKey
                     isEqualToDictionary:sectionData.indexPathForKey];

  _sectionData = sectionData;

  if (!skipReload) {
    [self reloadData];
  }
}

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)index
{
  [super insertReactSubview:subview atIndex:index];
  [_cells setObject:subview forKey:subview.nativeID];
}

- (void)removeReactSubview:(UIView *)subview
{
  [super removeReactSubview:subview];
  [_cells removeObjectForKey:subview.nativeID];
}

- (void)didUpdateReactSubviews
{
  NSArray<UIView *> *reactSubviews = self.reactSubviews;

  if (
      reactSubviews.count == 1 &&
      [reactSubviews[0].nativeID isEqual:@"TableViewListEmptyComponent"]
  ) {
    self.backgroundView = reactSubviews[0];
    return;
  } else if (self.backgroundView != nil) {
    self.backgroundView = nil;
  }

  NSMutableArray<NSIndexPath *> *updated = [NSMutableArray new];

  for (UIView *subview in reactSubviews) {
    if (subview.superview == nil) {
      NSIndexPath *indexPath = _sectionData.indexPathForKey[subview.nativeID];

      if (indexPath != nil) {
        [updated addObject:indexPath];
      }
    }
  }

  if (_ready && updated.count > 0) {
    [self reloadRowsAtIndexPaths:updated
                withRowAnimation:UITableViewRowAnimationNone];
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return _ready ? [_sectionData.sections count] : 0;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return _sectionData.sections[section].rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return _sectionData.sections[section].title;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self rowHeight];
}

- (NSDictionary *)eventDataForIndexPath:(NSIndexPath *)indexPath
{
  RCTTableViewListSection *section = _sectionData.sections[indexPath.section];
  return @{
    @"sectionIndex": @(indexPath.section),
    @"rowIndex": @(indexPath.row),
    @"sectionKey": section.key,
    @"rowKey": section.rows[indexPath.row].key,
  };
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (self.onPressRow != nil) {
    self.onPressRow([self eventDataForIndexPath:indexPath]);
  }
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle != UITableViewCellEditingStyleDelete) {
    return;
  }

  if (self.onDeleteRow) {
    self.onDeleteRow([self eventDataForIndexPath:indexPath]);
  }

  NSMutableArray<RCTTableViewListSection *> *sections = [_sectionData.sections mutableCopy];
  RCTTableViewListSection *section = sections[indexPath.section];
  NSMutableArray<RCTTableViewListRow *> *rows = [section.rows mutableCopy];

  [rows removeObjectAtIndex:indexPath.row];

  sections[indexPath.section] = [[RCTTableViewListSection alloc]
                                 initWithKey:section.key
                                 title:section.title
                                 rows:rows
                                 menu:section.menu
                                 canDeleteRows:section.canDeleteRows];

  _sectionData = [[RCTTableViewListData alloc] initWithSections:sections];

  [tableView deleteRowsAtIndexPaths:@[indexPath]
                   withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  BOOL canDeleteRows = _sectionData.sections[indexPath.section].canDeleteRows;
  return canDeleteRows ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView
contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
                                    point:(CGPoint)point
API_AVAILABLE(ios(13.0)) {
  NSArray<NSDictionary *> *menu = _sectionData.sections[indexPath.section].menu ?: _menu;

  if (menu == nil) {
    return nil;
  }

  return
    [UIContextMenuConfiguration
     configurationWithIdentifier:nil
     previewProvider:nil
     actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
      NSMutableArray<UIMenuElement *> *actions = [[NSMutableArray alloc] initWithCapacity:menu.count];

      for (NSInteger index = 0; index < menu.count; index += 1) {
        NSDictionary *menuItem = menu[index];
        NSString *title = [RCTConvert NSString:menuItem[@"title"]];
        NSString *key = [RCTConvert NSString:menuItem[@"key"]];
        NSString *systemIcon = [RCTConvert NSString:menuItem[@"systemIcon"]];
        UIImage *image = [UIImage systemImageNamed:systemIcon];
        BOOL destructive = [RCTConvert BOOL:menuItem[@"destructive"]];
        BOOL disabled = [RCTConvert BOOL:menuItem[@"disabled"]];

        UIAction *action = [UIAction actionWithTitle:title
                                               image:image
                                          identifier:nil
                                             handler:^(__kindof UIAction * _Nonnull action) {
          if (self.onMenu != nil) {
            NSMutableDictionary *eventData = [[self eventDataForIndexPath:indexPath] mutableCopy];
            [eventData setValue:@(index) forKey:@"index"];
            [eventData setValue:key forKey:@"key"];
            self.onMenu(eventData);
          }
        }];

        action.attributes =
          (destructive ? UIMenuElementAttributesDestructive : 0) |
          (disabled ? UIMenuElementAttributesDisabled : 0);

        [actions addObject:action];
      }

      return [UIMenu menuWithTitle:@"" children:actions];
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
  UITableViewCell *container = [self dequeueReusableCellWithIdentifier:@"cell"];
  container.backgroundColor = [UIColor clearColor];

  for (UIView *subview in container.contentView.subviews) {
    [subview removeFromSuperview];
  }

  NSString *key = _sectionData.sections[indexPath.section].rows[indexPath.row].key;
  UIView *content = _cells[key];
  if (content) {
    [container.contentView addSubview:content];
  }

  return container;
}

#if TARGET_OS_MACCATALYST
// Background blur looks terrible on MacOS
- (void)tableView:(UITableView *)tableView
willDisplayHeaderView:(UIView *)view
       forSection:(NSInteger)section
{
  UIBackgroundConfiguration *backgroundConfig =
    [UIBackgroundConfiguration listPlainHeaderFooterConfiguration];
  backgroundConfig.backgroundColor = [UIColor tertiarySystemBackgroundColor];
  backgroundConfig.visualEffect = nil;
  ((UITableViewHeaderFooterView *)view).backgroundConfiguration = backgroundConfig;
}
#endif

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self emitVisibleIndexPathsChangedEvent];
}

- (void)tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self emitVisibleIndexPathsChangedEvent];
}

- (void)emitVisibleIndexPathsChangedEvent
{
  NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  NSIndexPath *endIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];

  NSArray<NSIndexPath *> *indexPaths = self.indexPathsForVisibleRows;
  if (indexPaths.count != 0) {
    startIndexPath = indexPaths[0];
    endIndexPath = indexPaths[0];
    for (NSIndexPath *indexPath in indexPaths) {
      if ([indexPath compare:startIndexPath] == NSOrderedAscending) {
        startIndexPath = indexPath;
      }
      if ([indexPath compare:endIndexPath] == NSOrderedDescending) {
        endIndexPath = indexPath;
      }
    }
  }

  self.onVisibleIndexPathsChanged(@{
    @"startSection": @(startIndexPath.section),
    @"startRow": @(startIndexPath.row),
    @"endSection": @(endIndexPath.section),
    @"endRow": @(endIndexPath.row),
  });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if (self.onScroll != nil) {
    RCTScrollEvent *scrollEvent = [[RCTScrollEvent alloc] initWithEventName:@"onScroll"
                                                                   reactTag:self.reactTag
                                                    scrollViewContentOffset:scrollView.contentOffset
                                                     scrollViewContentInset:scrollView.contentInset
                                                      scrollViewContentSize:scrollView.contentSize
                                                            scrollViewFrame:scrollView.frame
                                                        scrollViewZoomScale:scrollView.zoomScale
                                                                   userData:nil
                                                              coalescingKey:0];

    self.onScroll(scrollEvent.arguments[2]);
  }
}

- (void)refreshContentInset
{
  [RCTView autoAdjustInsetsForView:self
                    withScrollView:self
                      updateOffset:YES];
}

@end
