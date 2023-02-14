#import "RCTTableViewList.h"
#import "RCTTableViewListCell.h"
#import "RCTTableViewListData.h"
#import <React/RCTBridge.h>
#import <React/UIView+React.h>
#import <React/RCTView.h>
#import <React/RCTConvert.h>
#import <React/RCTScrollEvent.h>

@implementation RCTTableViewList {
  __weak RCTBridge *_bridge;
  BOOL _ready;
  NSMutableDictionary<NSString *, UIView *> *_cells;
  NSMutableArray<NSString *> *_pendingCellUpdates;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
  self = [super init];
  if (self) {
    _bridge = bridge;

    self.delegate = self;
    self.dataSource = self;
    _cells = [NSMutableDictionary new];
    _pendingCellUpdates = [NSMutableArray new];
    [self registerClass:RCTTableViewListCell.class forCellReuseIdentifier:@"cell"];

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
  [_pendingCellUpdates addObject:subview.nativeID];
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

  if (!_ready) {
    return;
  }

  for (NSString *key in _pendingCellUpdates) {
    NSIndexPath *indexPath = _sectionData.indexPathForKey[key];
    if (indexPath == nil) {
      continue;
    }

    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
      continue;
    }

    [self configureCell:cell withKey:key];
  }

  [_pendingCellUpdates removeAllObjects];
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
      NSMutableArray<UIMenuElement *> *children = [[NSMutableArray alloc] initWithCapacity:menu.count];

      for (NSInteger index = 0; index < menu.count; index += 1) {
        UIMenuElement *action = [self convertMenuElement:menu[index]
                                         atMenuIndexPath:@[@(index)]
                                          atRowIndexPath:indexPath];
        [children addObject:action];
      }

      return [UIMenu menuWithTitle:@""
                          children:children];
    }];
}

- (UIMenuElement *)convertMenuElement:(NSDictionary *)menuItem
                      atMenuIndexPath:(NSArray<NSNumber *> *)menuIndexPath
                       atRowIndexPath:(NSIndexPath *)rowIndexPath
API_AVAILABLE(ios(13.0))
{
  NSArray *childrenMenuItems = [RCTConvert NSArray:menuItem[@"children"]];

  NSString *title = [RCTConvert NSString:menuItem[@"title"]];
  NSString *key = [RCTConvert NSString:menuItem[@"key"]];
  NSString *systemIcon = [RCTConvert NSString:menuItem[@"systemIcon"]];
  UIImage *image = systemIcon != nil ? [UIImage systemImageNamed:systemIcon] : nil;
  BOOL destructive = [RCTConvert BOOL:menuItem[@"destructive"]];
  BOOL disabled = [RCTConvert BOOL:menuItem[@"disabled"]];

  if (childrenMenuItems != nil) {
    NSMutableArray<UIMenuElement *> *children = [[NSMutableArray alloc] initWithCapacity:childrenMenuItems.count];

    for (NSInteger index = 0; index < childrenMenuItems.count; index += 1) {
      UIMenuElement *action = [self convertMenuElement:childrenMenuItems[index]
                                       atMenuIndexPath:[menuIndexPath arrayByAddingObject:@(index)]
                                        atRowIndexPath:rowIndexPath];
      [children addObject:action];
    }

    UIMenuOptions options =
      ([RCTConvert BOOL:menuItem[@"inline"]] ? UIMenuOptionsDisplayInline : 0) |
      (destructive ? UIMenuOptionsDestructive : 0);

    return [UIMenu menuWithTitle:title
                           image:image
                      identifier:nil
                         options:options
                        children:children];
  } else {
    UIAction *action = [UIAction actionWithTitle:title
                                           image:image
                                      identifier:nil
                                         handler:^(__kindof UIAction * _Nonnull action) {
      if (self.onMenu != nil) {
        NSMutableDictionary *eventData = [[self eventDataForIndexPath:rowIndexPath] mutableCopy];
        [eventData setValue:menuIndexPath forKey:@"indexPath"];
        [eventData setValue:key forKey:@"key"];
        self.onMenu(eventData);
      }
    }];

    action.attributes =
      (destructive ? UIMenuElementAttributesDestructive : 0) |
      (disabled ? UIMenuElementAttributesDisabled : 0);

    return action;
  }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
  RCTTableViewListCell *cell = [self dequeueReusableCellWithIdentifier:@"cell"];
  cell.bridge = _bridge;
  NSString *key = _sectionData.sections[indexPath.section].rows[indexPath.row].key;

  [self configureCell:cell withKey:key];

  return cell;
}

- (void)configureCell:(UITableViewCell *)cell
              withKey:(NSString *)key
{
  cell.backgroundColor = [UIColor clearColor];

  for (UIView *subview in cell.contentView.subviews) {
    [subview removeFromSuperview];
  }

  UIView *content = _cells[key];
  if (cell != nil) {
    [cell.contentView addSubview:content];
  }
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
