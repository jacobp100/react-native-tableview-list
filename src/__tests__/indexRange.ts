import { Overlap, overlap, extendInto } from '../indexRange';

describe('overlap', () => {
  test('none', () => {
    expect(overlap({ start: 5, length: 5 }, { start: 10, length: 5 })).toBe(
      Overlap.None
    );
    expect(overlap({ start: 10, length: 5 }, { start: 5, length: 5 })).toBe(
      Overlap.None
    );
  });

  test('partial', () => {
    expect(overlap({ start: 10, length: 10 }, { start: 5, length: 10 })).toBe(
      Overlap.PartialAtEnd
    );
    expect(overlap({ start: 5, length: 10 }, { start: 10, length: 10 })).toBe(
      Overlap.PartialAtStart
    );
  });

  test('full', () => {
    expect(overlap({ start: 10, length: 10 }, { start: 10, length: 10 })).toBe(
      Overlap.Full
    );
    expect(overlap({ start: 10, length: 30 }, { start: 20, length: 10 })).toBe(
      Overlap.Full
    );
    expect(overlap({ start: 20, length: 10 }, { start: 10, length: 30 })).toBe(
      Overlap.Full
    );
  });
});

describe('extendInto', () => {
  test('unclamped', () => {
    expect(
      extendInto({ start: 20, length: 10 }, { start: 10, length: 30 }, 10)
    ).toEqual({
      start: 15,
      length: 20,
    });

    expect(
      extendInto({ start: 20, length: 10 }, { start: 10, length: 30 }, 20)
    ).toEqual({
      start: 10,
      length: 30,
    });
  });

  test('clamp start', () => {
    expect(
      extendInto({ start: 15, length: 10 }, { start: 10, length: 50 }, 20)
    ).toEqual({
      start: 10,
      length: 30,
    });

    expect(
      extendInto({ start: 11, length: 10 }, { start: 10, length: 50 }, 20)
    ).toEqual({
      start: 10,
      length: 30,
    });
  });

  test('clamp end', () => {
    expect(
      extendInto({ start: 45, length: 10 }, { start: 10, length: 50 }, 20)
    ).toEqual({
      start: 30,
      length: 30,
    });

    expect(
      extendInto({ start: 49, length: 10 }, { start: 10, length: 50 }, 20)
    ).toEqual({
      start: 30,
      length: 30,
    });
  });

  test('clamp both', () => {
    expect(
      extendInto({ start: 0, length: 10 }, { start: 0, length: 10 }, 1)
    ).toEqual({
      start: 0,
      length: 10,
    });

    expect(
      extendInto({ start: 15, length: 20 }, { start: 10, length: 30 }, 20)
    ).toEqual({
      start: 10,
      length: 30,
    });

    expect(
      extendInto({ start: 11, length: 20 }, { start: 10, length: 30 }, 20)
    ).toEqual({
      start: 10,
      length: 30,
    });

    expect(
      extendInto({ start: 19, length: 20 }, { start: 10, length: 30 }, 20)
    ).toEqual({
      start: 10,
      length: 30,
    });
  });
});
