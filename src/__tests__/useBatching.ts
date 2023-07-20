import type { IndexPathRow } from '../types';
import {
  limitBatchedIndexRangeToTargetIndexRange,
  Props,
} from '../useBatching';

const rowDataOfLength = (length: number) =>
  ({ length } as any as IndexPathRow<unknown>[]);

const defaultProps: Props = {
  rowData: rowDataOfLength(1000),
  visibleIndexPaths: undefined,
  windowRows: 21,
  initialNumToRender: 10,
  maxToRenderPerBatch: 10,
  updateCellsBatchingPeriod: 50,
};

describe('limitBatchedIndexRangeToTargetIndexRange', () => {
  test('should not limit overlapping ranges', () => {
    expect(
      limitBatchedIndexRangeToTargetIndexRange(
        {
          batchedIndexRange: { start: 10, length: 10 },
          visibleIndexRange: { start: 0, length: 30 },
          targetIndexRange: { start: 0, length: 30 },
        },
        defaultProps
      )
    ).toEqual({
      start: 10,
      length: 10,
    });
  });

  test('should reset non-overlapping ranges', () => {
    expect(
      limitBatchedIndexRangeToTargetIndexRange(
        {
          batchedIndexRange: { start: 10, length: 10 },
          visibleIndexRange: { start: 100, length: 10 },
          targetIndexRange: { start: 50, length: 100 },
        },
        defaultProps
      )
    ).toEqual({
      start: 100,
      length: 10,
    });
  });

  test('should reset partially overlapping ranges re-using rendered rows', () => {
    expect(
      limitBatchedIndexRangeToTargetIndexRange(
        {
          batchedIndexRange: { start: 100, length: 20 },
          visibleIndexRange: { start: 150, length: 20 },
          targetIndexRange: { start: 110, length: 100 },
        },
        defaultProps
      )
    ).toEqual({
      start: 100,
      length: 30,
    });

    expect(
      limitBatchedIndexRangeToTargetIndexRange(
        {
          batchedIndexRange: { start: 100, length: 20 },
          visibleIndexRange: { start: 50, length: 20 },
          targetIndexRange: { start: 10, length: 100 },
        },
        defaultProps
      )
    ).toEqual({
      start: 90,
      length: 30,
    });
  });
});
