import React from 'react';
import TestRenderer from 'react-test-renderer';
import TableViewList from '..';

jest.mock('../TableViewList', () => ({
  __esModule: true,
  default: 'TableViewList',
}));

test('does not crash when length of data changes', async () => {
  const testRenderer = TestRenderer.create(
    <TableViewList
      sections={[{ title: '', data: [1] }]}
      renderItem={() => null!}
      rowHeight={100}
    />
  );

  testRenderer.update(
    <TableViewList
      sections={[{ title: '', data: [] }]}
      renderItem={() => null!}
      rowHeight={100}
    />
  );
});
