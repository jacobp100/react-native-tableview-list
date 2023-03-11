// Match <SectionList /> types
export type RowEvent<Row> = {
  item: Row;
  section: Section<Row>;
  index: number;
};

export type MoveRowEvent<Row> = {
  fromItem: Row;
  fromSection: Section<Row>;
  fromIndex: number;
  toItem: Row;
  toSection: Section<Row>;
  toIndex: number;
};

export type Section<Row> = {
  title: string;
  key?: string;
  data: Row[];
  menu?: MenuItem<Row>[];
  moveRows?: 'none' | 'within-section';
  onDeleteRow?: (e: RowEvent<Row>) => void;
};

export type MenuItem<Row> = {
  title: string;
  key?: string;
  systemIcon?: string;
  destructive?: boolean;
  disabled?: boolean;
  inline?: boolean;
  children?: MenuItem<Row>[];
  onPress?: (e: RowEvent<Row>) => void;
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
