/* global JSX */
import React from 'react';
import {
  Animated,
  ColorValue,
  LayoutChangeEvent,
  NativeSyntheticEvent,
  requireNativeComponent,
  ScrollView,
  StyleProp,
  StyleSheet,
  View,
  ViewStyle,
} from 'react-native';
import type {
  IndexPathRow,
  MenuItem,
  MoveRowEvent,
  RowEvent,
  Section,
  VisibleIndexPaths,
} from './types';
import useBatching from './useBatching';

const TableViewList = requireNativeComponent<any>('RCTTableViewList');

const styles = StyleSheet.create({
  container: {
    flex: 1,
    overflow: 'scroll',
  } as ViewStyle,
  cellContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
  } as ViewStyle,
  listEmptyContainer: {},
});

type MenuItemWithoutCallbacks<Row> = Omit<MenuItem<Row>, 'onPress'> & {
  onPress?: undefined;
};

const removeMenuItemCallbacks = <Row,>(
  menu: MenuItem<Row>
): MenuItemWithoutCallbacks<Row> => ({
  title: menu.title,
  key: menu.key,
  systemIcon: menu.systemIcon,
  destructive: menu.destructive,
  disabled: menu.disabled,
  inline: menu.inline,
  children: menu.children?.map(removeMenuItemCallbacks),
});

type SectionData<Row> = {
  title: string;
  key: string;
  rows: Array<{ key: string }>;
  menu: MenuItemWithoutCallbacks<Row>[] | undefined;
  canDeleteRows?: boolean;
  moveRows?: 'none' | 'within-section';
};

export type { Section, RowEvent, MoveRowEvent };
export type { MenuItem };

type RowBasicEventData = {
  sectionIndex: number;
  sectionKey: number;
  rowIndex: number;
  rowKey: number;
};

type MoveEventData = {
  fromSection: number;
  fromRow: number;
  toSection: number;
  toRow: number;
};

type MenuEventData = RowBasicEventData & {
  indexPath: number[];
  key: string | undefined;
};

export type Props<Row> = ScrollView['props'] & {
  ref?: any;
  sections: Section<Row>[];
  renderItem: (data: RowEvent<Row>) => JSX.Element;
  keyExtractor?: (row: Row, index: number, sectionIndex: number) => string;
  rowHeight: number;
  separatorInset?: { left?: number; right?: number };
  separatorColor?: ColorValue;
  cellContainerStyle?: StyleProp<ViewStyle>;
  onPressRow?: (event: RowEvent<Row>) => void;
  onDeleteRow?: (event: RowEvent<Row>) => void;
  moveRows?: 'none' | 'within-section';
  onMoveRow?: (event: MoveRowEvent<Row>) => void;
  editing?: boolean;
  menu?: MenuItem<Row>[];
  initialNumToRender?: number;
  maxToRenderPerBatch?: number;
  windowSize?: number;
  updateCellsBatchingPeriod?: number;
  ListEmptyComponent?: () => JSX.Element;
};

const defaultKeyExtractor = (data: any) => data.key;

const combineKeys = (
  sectionKey: string | undefined,
  section: number,
  rowKey: string
) => `${sectionKey ?? String(section)}:${rowKey}`;

const Component = <Row,>(props: Props<Row>, ref: any, NativeComponent: any) => {
  const {
    style: baseStyle,
    onLayout: baseOnLayout,
    sections,
    renderItem,
    keyExtractor = defaultKeyExtractor,
    rowHeight,
    separatorInset,
    separatorColor,
    cellContainerStyle,
    onPressRow: baseOnPressRow,
    onDeleteRow: baseOnDeleteRow,
    onMoveRow: baseOnMoveRow,
    moveRows = 'none',
    editing,
    menu: baseMenu,
    initialNumToRender = 10,
    maxToRenderPerBatch = 10,
    windowSize = 21,
    updateCellsBatchingPeriod = 50,
    ListEmptyComponent,
    ...restProps
  } = props;

  const canDeleteRows = baseOnDeleteRow != null;

  const sectionData = React.useMemo(() => {
    return sections.map(
      (section, sectionIndex): SectionData<Row> => ({
        title: section.title,
        key: section.key ?? String(sectionIndex),
        rows: section.data.map((item, rowIndex) => ({
          key: combineKeys(
            section.key,
            sectionIndex,
            keyExtractor(item, rowIndex, sectionIndex)
          ),
        })),
        menu: section.menu?.map(removeMenuItemCallbacks),
        canDeleteRows: section.onDeleteRow != null || canDeleteRows,
        moveRows: section.moveRows ?? moveRows,
      })
    );
  }, [sections, keyExtractor, canDeleteRows, moveRows]);

  const rowData = React.useMemo(() => {
    const out: IndexPathRow<Row>[] = [];
    sections.forEach((section, sectionIndex) => {
      section.data.forEach((item, rowIndex) => {
        out.push({
          section: sectionIndex,
          row: rowIndex,
          key: sectionData[sectionIndex].rows[rowIndex].key,
          item,
        });
      });
    });
    return out;
  }, [sections, sectionData]);

  const onPressRow = React.useCallback(
    (e: NativeSyntheticEvent<RowBasicEventData>) => {
      const { sectionIndex, rowIndex } = e.nativeEvent;
      const section = sections[sectionIndex];
      const item = section.data[rowIndex];
      baseOnPressRow?.({ item, index: rowIndex, section });
    },
    [sections, baseOnPressRow]
  );

  const onDeleteRow = React.useCallback(
    (e: NativeSyntheticEvent<RowBasicEventData>) => {
      const { sectionIndex, rowIndex } = e.nativeEvent;
      const section = sections[sectionIndex];
      const item = section.data[rowIndex];
      const callback = section.onDeleteRow ?? baseOnDeleteRow;
      callback?.({ item, index: rowIndex, section });
    },
    [sections, baseOnDeleteRow]
  );

  const onMoveRow = React.useCallback(
    (e: NativeSyntheticEvent<MoveEventData>) => {
      const data = e.nativeEvent;
      const fromSection = sections[data.fromSection];
      const fromItem = fromSection.data[data.fromRow];
      const toSection = sections[data.toSection];
      const toItem = toSection.data[data.toRow];
      baseOnMoveRow?.({
        fromItem,
        fromIndex: data.fromRow,
        fromSection,
        toItem,
        toIndex: data.toRow,
        toSection,
      });
    },
    [sections, baseOnMoveRow]
  );

  const menu = React.useMemo(
    () => baseMenu?.map(removeMenuItemCallbacks),
    [baseMenu]
  );

  const onMenu = React.useCallback(
    (e: NativeSyntheticEvent<MenuEventData>) => {
      const { sectionIndex, rowIndex, indexPath } = e.nativeEvent;
      const section = sections[sectionIndex];
      const menuObject = section.menu ?? baseMenu;
      const item = section.data[rowIndex];
      type Accum = Pick<MenuItem<Row>, 'children' | 'onPress'> | undefined;
      const menuChild = indexPath.reduce<Accum>(
        (accum, index) => accum?.children?.[index],
        { children: menuObject }
      );
      menuChild?.onPress?.({ item, index: rowIndex, section });
    },
    [baseMenu, sections]
  );

  const [height, setHeight] = React.useState(0);
  const onLayout = React.useCallback(
    (e: LayoutChangeEvent) => {
      setHeight(e.nativeEvent.layout.height);
      baseOnLayout?.(e);
    },
    [baseOnLayout]
  );
  const windowRows =
    Math.max(windowSize - 1, 0) * Math.ceil(height / rowHeight);

  const [visibleIndexPaths, setVisibleIndexPaths] =
    React.useState<VisibleIndexPaths>();
  const onVisibleIndexPathsChanged = React.useCallback((e: any) => {
    const { startSection, startRow, endSection, endRow } = e.nativeEvent;
    setVisibleIndexPaths((s) => {
      if (
        s == null ||
        s.startSection !== startSection ||
        s.startRow !== startRow ||
        s.endSection !== endSection ||
        s.endRow !== endRow
      ) {
        return { startSection, startRow, endSection, endRow };
      } else {
        return s;
      }
    });
  }, []);

  const batchedIndexRange = useBatching({
    rowData,
    visibleIndexPaths,
    windowRows,
    maxToRenderPerBatch,
    initialNumToRender,
    updateCellsBatchingPeriod,
  });

  const cellStyle = React.useMemo(() => {
    return StyleSheet.compose(
      {
        ...styles.cellContainer,
        height: rowHeight,
      },
      cellContainerStyle
    );
  }, [rowHeight, cellContainerStyle]);

  type RenderCache = {
    cache: Map<string, JSX.Element>;
    dependencies: any[];
  };
  const renderCacheRef = React.useRef<RenderCache | undefined>();
  const childrenBatched = React.useMemo(() => {
    const renderCache = renderCacheRef.current;
    const dependencies: any[] = [sections, renderItem, cellStyle];
    const cache =
      renderCache != null &&
      renderCache.dependencies.every((prev, i) =>
        Object.is(prev, dependencies[i])
      )
        ? renderCache.cache
        : undefined;
    const nextCache = new Map<string, JSX.Element>();
    renderCacheRef.current = {
      cache: nextCache,
      dependencies,
    };

    const { start, length } = batchedIndexRange;
    return Array.from({ length }, (_, i) => {
      const index = start + i;
      const { section, row, key, item } = rowData[index];

      const value = cache?.get(key) ?? (
        <View key={key} nativeID={key} style={cellStyle}>
          {renderItem({ item, index: row, section: sections[section] })}
        </View>
      );
      nextCache.set(key, value);

      return value;
    });
  }, [sections, renderItem, cellStyle, rowData, batchedIndexRange]);

  return (
    <NativeComponent
      ref={ref}
      onLayout={onLayout}
      sectionData={sectionData}
      style={StyleSheet.compose(styles.container, baseStyle)}
      rowHeight={rowHeight}
      separatorInset={separatorInset}
      separatorColor={separatorColor}
      onPressRow={onPressRow}
      onDeleteRow={onDeleteRow}
      onMoveRow={onMoveRow}
      editing={editing}
      menu={menu}
      onMenu={onMenu}
      onVisibleIndexPathsChanged={onVisibleIndexPathsChanged}
      {...restProps}
    >
      {sections.length > 0 ? (
        childrenBatched
      ) : ListEmptyComponent != null ? (
        <View
          nativeID="TableViewListEmptyComponent"
          style={styles.listEmptyContainer}
        >
          <ListEmptyComponent />
        </View>
      ) : null}
    </NativeComponent>
  );
};

export default React.forwardRef(<Row,>(props: Props<Row>, ref: any) =>
  Component(props, ref, TableViewList)
) as <Row>(props: Props<Row>) => JSX.Element;

const AnimatedTableViewList = Animated.createAnimatedComponent(
  TableViewList
) as any;

export const AnimatedComponent = React.forwardRef(
  <Row,>(props: Props<Row>, ref: any): JSX.Element =>
    Component(props, ref, AnimatedTableViewList)
) as <Row>(props: Props<Row>) => JSX.Element;
