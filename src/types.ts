// Match <SectionList /> types
export type RowEvent<Row> = {
  item: Row;
  section: Section<Row>;
  index: number;
};

export type Section<Row> = {
  title: string;
  key?: string;
  data: Row[];
  menu?: MenuItem<Row>[];
  onDeleteRow?: (e: RowEvent<Row>) => void;
};

export type MenuItem<Row> = {
  title: string;
  key?: string;
  systemIcon: string;
  destructive?: boolean;
  disabled?: boolean;
  onPress: (e: RowEvent<Row>) => void;
};

export type IndexPathRow<Row> = {
  section: number;
  row: number;
  key: string;
  item: Row;
};

export type VisibleIndexPaths = {
  startSection: number;
  startRow: number;
  endSection: number;
  endRow: number;
};
