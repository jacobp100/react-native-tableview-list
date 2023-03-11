import React from 'react';
import { Alert, SafeAreaView, StyleSheet, Text, View } from 'react-native';
import TableviewListView, {
  MenuItem,
  MoveRowEvent,
  RowEvent,
  Section,
} from 'react-native-tableview-list';

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  cellContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 18,
  },
  lozenge: {
    width: 10,
    height: 10,
    backgroundColor: 'red',
    transform: [{ rotate: '45deg' }],
  },
});

const defaultSections: Section<string>[] = [
  {
    title: 'First Section',
    key: 'first',
    data: Array.from({ length: 20 }, (_, i) => `Item ${i + 1}`),
  },
  {
    title: 'Second Section',
    key: 'second',
    data: Array.from({ length: 10 }, (_, i) => `Item ${i + 1}`),
    moveRows: 'within-section',
  },
  {
    title: 'Third Section',
    key: 'third',
    data: Array.from({ length: 100 }, (_, i) => `Item ${i + 1}`),
  },
];

export default function App() {
  const [editing, setEditing] = React.useState(false);
  const [sections, setSections] = React.useState(defaultSections);

  const deleteRow = React.useCallback(({ index, section }: RowEvent<any>) => {
    setSections((ss) => {
      return ss.map((s) => ({
        ...s,
        data: s.data.filter((_, i) => s !== section || index !== i),
      }));
    });
  }, []);

  const moveRow = React.useCallback(
    ({ fromSection, fromItem, fromIndex, toIndex }: MoveRowEvent<any>) => {
      setSections((ss) => {
        return ss.map((s) => {
          if (s !== fromSection) {
            return s;
          }

          const data = s.data.slice();
          data.splice(fromIndex, 1);
          data.splice(toIndex, 0, fromItem);
          return { ...s, data };
        });
      });
    },
    []
  );

  const menu = React.useMemo(
    (): MenuItem<string>[] => [
      {
        title: 'Toggle Editing',
        systemIcon: 'square.and.pencil',
        onPress: () => setEditing((e) => !e),
      },
      {
        title: 'Alert',
        systemIcon: 'eyeglasses',
        onPress: ({ item }) => Alert.alert(item),
      },
      {
        title: 'Delete',
        systemIcon: 'trash',
        destructive: true,
        onPress: deleteRow,
      },
    ],
    [deleteRow]
  );

  return (
    <SafeAreaView style={styles.container}>
      <TableviewListView<string>
        sections={sections}
        rowHeight={50}
        cellContainerStyle={styles.cellContainer}
        keyExtractor={React.useCallback((item) => item, [])}
        renderItem={React.useCallback(({ item }) => {
          return (
            <>
              <Text>{item}</Text>
              <View style={styles.lozenge} />
            </>
          );
        }, [])}
        onPressRow={React.useCallback(({ item }) => Alert.alert(item), [])}
        menu={menu}
        onDeleteRow={deleteRow}
        onMoveRow={moveRow}
        editing={editing}
      />
    </SafeAreaView>
  );
}
