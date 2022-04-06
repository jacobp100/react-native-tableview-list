/* eslint-disable no-bitwise */
import React from 'react';
import { InteractionManager } from 'react-native';
import { findIndex as indexPathFindIndex } from './indexPath';
import {
  clampToLength as indexRangeClampToLength,
  extendInto as indexRangeExtendInto,
  IndexRange,
  isEqual as indexRangeIsEqual,
  overlap as indexRangeOverlap,
  Overlap,
} from './indexRange';
import type { IndexPathRow, VisibleIndexPaths } from './types';

export type Props = {
  rowData: IndexPathRow<unknown>[];
  visibleIndexPaths: VisibleIndexPaths | undefined;
  windowRows: number;
  initialNumToRender: number;
  maxToRenderPerBatch: number;
  updateCellsBatchingPeriod: number;
};

export const limitBatchedIndexRangeToTargetIndexRange = (
  {
    batchedIndexRange,
    visibleIndexRange,
    targetIndexRange,
  }: {
    batchedIndexRange: IndexRange;
    visibleIndexRange: IndexRange;
    targetIndexRange: IndexRange;
  },
  { rowData, initialNumToRender, windowRows }: Props
) => {
  const rowsAround = (windowRows / 2) | 0;
  switch (indexRangeOverlap(batchedIndexRange, targetIndexRange)) {
    case Overlap.Full:
      return indexRangeClampToLength(batchedIndexRange, rowData.length);
    case Overlap.PartialAtStart: {
      // Use already rendered additional rows *after* batchedIndexRange
      const start = batchedIndexRange.start;
      const end = Math.min(
        batchedIndexRange.start + batchedIndexRange.length + rowsAround,
        targetIndexRange.start + targetIndexRange.length
      );
      const length = end - start;
      return indexRangeClampToLength({ start, length }, rowData.length);
    }
    case Overlap.PartialAtEnd: {
      // Use already rendered additional rows *before* batchedIndexRange
      const start = Math.max(
        batchedIndexRange.start - rowsAround,
        targetIndexRange.start,
        0
      );
      const end = batchedIndexRange.start + batchedIndexRange.length;
      const length = end - start;
      return indexRangeClampToLength({ start, length }, rowData.length);
    }
    case Overlap.None:
      return indexRangeClampToLength(
        {
          start: visibleIndexRange?.start ?? 0,
          length: initialNumToRender,
        },
        rowData.length
      );
  }
};

export default (props: Props): IndexRange => {
  const {
    rowData,
    visibleIndexPaths,
    windowRows,
    initialNumToRender,
    maxToRenderPerBatch,
    updateCellsBatchingPeriod,
  } = props;

  const visibleIndexRange = React.useMemo(() => {
    if (visibleIndexPaths == null) {
      return null;
    } else {
      const { startSection, startRow, endSection, endRow } = visibleIndexPaths;
      const start = indexPathFindIndex(rowData, startSection, startRow) ?? 0;
      const end = indexPathFindIndex(rowData, endSection, endRow);
      const length = end != null ? end - start + 1 : 0;
      return { start, length };
    }
  }, [rowData, visibleIndexPaths]);

  const targetIndexRange = React.useMemo(() => {
    if (visibleIndexRange != null) {
      const start = Math.max(
        visibleIndexRange.start - ((windowRows / 2) | 0),
        0
      );
      const end = Math.min(start + windowRows, rowData.length);
      const length = end - start;
      return { start, length };
    } else {
      return null;
    }
  }, [windowRows, visibleIndexRange, rowData.length]);

  const [uncheckedBatchedIndexRange, setBatchedIndexRange] = React.useState({
    start: 0,
    length: Math.min(initialNumToRender, rowData.length),
  });
  const batchedIndexRange =
    visibleIndexRange != null && targetIndexRange != null
      ? limitBatchedIndexRangeToTargetIndexRange(
          {
            batchedIndexRange: uncheckedBatchedIndexRange,
            visibleIndexRange,
            targetIndexRange,
          },
          props
        )
      : uncheckedBatchedIndexRange;
  if (!indexRangeIsEqual(uncheckedBatchedIndexRange, batchedIndexRange)) {
    setBatchedIndexRange(batchedIndexRange);
  }

  type BatchedValue = {
    targetIndexRange: IndexRange;
    maxToRenderPerBatch: number;
  };
  const batchedValue = React.useRef<BatchedValue | null>(null);
  React.useEffect(() => {
    if (targetIndexRange == null) {
      return;
    }

    const hasPendingIndexRange = batchedValue.current != null;
    batchedValue.current = { targetIndexRange, maxToRenderPerBatch };

    if (hasPendingIndexRange) {
      return;
    }

    // This debouncing is to handle the case where the user is continuously
    // scrolling, causing continuous changes to targetIndexRange. Doing the
    // standard returning a function that cancels the timeout will mean the
    // timeout never gets called.
    //
    // This approach technically leaks after the component unmounts.
    // However, the extra call is safe, and the extra overhead to handle this
    // textbook correctly is not worth it.
    setTimeout(() => {
      InteractionManager.runAfterInteractions(() => {
        const currentBatchedValue = batchedValue.current;
        if (currentBatchedValue == null) {
          return;
        }

        batchedValue.current = null;
        setBatchedIndexRange((s) => {
          const nextValue = indexRangeExtendInto(
            s,
            currentBatchedValue.targetIndexRange,
            currentBatchedValue.maxToRenderPerBatch
          );
          return nextValue != null && !indexRangeIsEqual(nextValue, s)
            ? nextValue
            : s;
        });
      });
    }, updateCellsBatchingPeriod);
  }, [
    targetIndexRange,
    batchedIndexRange,
    maxToRenderPerBatch,
    updateCellsBatchingPeriod,
  ]);

  return batchedIndexRange;
};
