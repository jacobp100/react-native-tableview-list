import type { IndexPathRow } from './types';

export const findIndex = (
  rowData: IndexPathRow<unknown>[],
  section: number,
  row: number
): number | undefined => {
  let start = 0;
  let end = rowData.length - 1;

  while (start <= end) {
    // eslint-disable-next-line no-bitwise
    const middle = ((start + end) / 2) | 0;
    const rowDatum = rowData[middle];

    const delta =
      rowDatum.section === section
        ? Math.sign(row - rowDatum.row)
        : Math.sign(section - rowDatum.section);

    if (delta > 0) {
      start = middle + 1;
    } else if (delta < 0) {
      end = middle - 1;
    } else {
      return middle;
    }
  }

  return undefined;
};
