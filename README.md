# react-native-tableview-list

[SectionList](https://reactnative.dev/docs/sectionlist)-like component backed by a [UITableView](https://developer.apple.com/documentation/uikit/uitableview) (iOS only).

The aim is to have the fully native experience: swipe to delete (with correct haptics and automatic dismissal when scrolling), press and hold menus etc. Performance is probably on par with the default `SectionList` component.

Only renders custom cells - if you need the standard styles, use [react-native-tableview](https://github.com/aksonov/react-native-tableview). This library will also handle custom cells - but doing so breaks stuff like `Context`.

|                                                                                                             |                                                                                                             |                                                                                                             |
| ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| ![Screenshot 1](https://github.com/jacobp100/react-native-tableview-list/blob/master/assets/1.png?raw=true) | ![Screenshot 2](https://github.com/jacobp100/react-native-tableview-list/blob/master/assets/2.png?raw=true) | ![Screenshot 3](https://github.com/jacobp100/react-native-tableview-list/blob/master/assets/3.png?raw=true) |

## Installation

```sh
npm install react-native-tableview-list
```

## Usage

```jsx
import TableviewListView from 'react-native-tableview-list';

<TableviewListView
  sections={[{ title: 'title', key: 'key', data: [1, 2, 3] }]}
  rowHeight={50}
  renderItem={({ item }) => (
    <>
      <Text>{item}</Text>
      <View style={styles.lozenge} />
    </>
  )}
/>;
```

If you need a `FlatList`-like list, pass a single section with the title set to an empty string (`''`).

### Props

Properties marked with an asterisk (\*) are required

| Name                      | Type                                       | Description                                                                |
| ------------------------- | ------------------------------------------ | -------------------------------------------------------------------------- |
| sections \*               | Section[]                                  | See below for props                                                        |
| renderItem \*             | ({ item, index, section }) => ReactElement | Render row                                                                 |
| keyExtractor              | (Row, index, sectionIndex) => string       | Needed if data does not have a `key` or `id` property                      |
| rowHeight \*              | number                                     | Currently all rows must have the same, fixed height                        |
| separatorInset            | { left?: number, right?: number }          | Margin applied to the left and right of each separator                     |
| separatorColor            | string                                     | Color string or PlatformColor                                              |
| cellContainerStyle        | style                                      | Customise cell style: do not chagne postion, width, or height              |
| onPressRow                | ({ item, index, section }) => void         | Called when a row is pressed                                               |
| onDeleteRow               | ({ item, index, section }) => void         | Enables swipe to delete - you **MUST** delete the item when this is called |
| menu                      | MenuItem[]                                 | See below for props                                                        |
| initialNumToRender        | number                                     | See [VirtualisedList](https://reactnative.dev/docs/virtualizedlist)        |
| maxToRenderPerBatch       | number                                     | See [VirtualisedList](https://reactnative.dev/docs/virtualizedlist)        |
| windowSize                | number                                     | See [VirtualisedList](https://reactnative.dev/docs/virtualizedlist)        |
| updateCellsBatchingPeriod | number                                     | See [VirtualisedList](https://reactnative.dev/docs/virtualizedlist)        |
| ListEmptyComponent        | ReactElement                               | Displayed when there's no data                                             |

### Types

```ts
type Section<Row> = {
  title: string;
  key?: string;
  data: Row[];
  // Enables press and hold interaction
  menu?: MenuItem<Row>[];
  // Enables swipe to delete for section
  // You **MUST** delete the item when this is called
  onDeleteRow?: (e: RowEvent<Row>) => void;
};

type MenuItem<Row> = {
  title: string;
  key?: string;
  // See SF Symbols
  systemIcon: string;
  // Red text
  destructive?: boolean;
  // Greyed out
  disabled?: boolean;
  // Display children inline - rather than as a submenu
  inline?: boolean;
  // Submenu
  children?: MenuItem<Row>[];
  // On press
  onPress: (e: RowEvent<Row>) => void;
};

type RowEvent<Row> = {
  item: Row;
  section: Section<Row>;
  index: number;
};
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
