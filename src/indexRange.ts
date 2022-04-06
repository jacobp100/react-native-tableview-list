export type IndexRange = { start: number; length: number };

export const isEqual = (a: IndexRange, b: IndexRange) =>
  a.start === b.start && a.length === b.length;

export const clampToLength = (
  indexRange: IndexRange,
  dataLength: number
): IndexRange => {
  const start = Math.min(Math.max(indexRange.start, 0), dataLength);
  const end = Math.min(
    Math.max(indexRange.start + indexRange.length, 0),
    dataLength
  );
  const length = end - start;
  return indexRange.start !== start || indexRange.length !== length
    ? { start, length }
    : indexRange;
};

export enum Overlap {
  None,
  PartialAtStart,
  PartialAtEnd,
  Full,
}

export const overlap = (a: IndexRange, b: IndexRange): Overlap => {
  const aEnd = a.start + a.length;
  const bEnd = b.start + b.length;
  if (aEnd <= b.start || a.start >= bEnd) {
    return Overlap.None;
  } else if (
    (a.start >= b.start && aEnd <= bEnd) ||
    (a.start <= b.start && aEnd >= bEnd)
  ) {
    return Overlap.Full;
  } else if (a.start < b.start) {
    return Overlap.PartialAtStart;
  } else {
    return Overlap.PartialAtEnd;
  }
};

export const extendInto = (
  a: IndexRange,
  b: IndexRange,
  by: number
): IndexRange | null => {
  switch (overlap(a, b)) {
    case Overlap.Full: {
      const spaceBefore = a.start - b.start;
      const spaceAfter = b.start + b.length - (a.start + a.length);

      let rowsBefore =
        spaceAfter >= spaceBefore ? Math.floor(by / 2) : Math.ceil(by / 2);
      if (spaceBefore < rowsBefore) {
        // Clamp start
        rowsBefore = spaceBefore;
      } else if (spaceAfter < by - rowsBefore) {
        // Clamp end
        rowsBefore = by - spaceAfter;
      }

      const start = Math.max(a.start - rowsBefore, b.start);
      const end = Math.min(start + a.length + by, b.start + b.length);
      const length = end - start;
      return { start, length };
    }
    case Overlap.PartialAtStart: {
      const start = a.start;
      const end = Math.min(a.start + a.length + by, b.start + b.length);
      const length = end - start;
      return { start, length };
    }
    case Overlap.PartialAtEnd: {
      const start = Math.max(a.start - by, b.start);
      const end = a.start + a.length;
      const length = end - start;
      return { start, length };
    }
    case Overlap.None:
      return null;
  }
};
