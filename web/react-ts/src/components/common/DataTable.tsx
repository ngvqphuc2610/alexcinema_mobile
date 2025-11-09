import type { ReactNode } from 'react';
import clsx from 'clsx';

export interface DataTableColumn<T> {
  key: string;
  title: ReactNode;
  dataIndex?: keyof T | string;
  render?: (item: T) => ReactNode;
  align?: 'left' | 'center' | 'right';
  width?: string;
  className?: string;
}

export interface DataTableProps<T> {
  columns: Array<DataTableColumn<T>>;
  data: T[];
  rowKey: (item: T) => string | number;
  emptyMessage?: string;
  className?: string;
}

const DataTable = <T,>({
  columns,
  data,
  rowKey,
  emptyMessage = 'Khong co du lieu',
  className,
}: DataTableProps<T>) => (
  <div className={clsx('data-table', className)}>
    <table>
      <thead>
        <tr>
          {columns.map((column) => (
            <th
              key={column.key}
              style={column.width ? { width: column.width } : undefined}
              className={clsx(
                column.className,
                column.align ? `data-table__cell--${column.align}` : undefined,
              )}
            >
              {column.title}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {data.length === 0 ? (
          <tr>
            <td className="data-table__empty" colSpan={columns.length}>
              {emptyMessage}
            </td>
          </tr>
        ) : (
          data.map((item) => (
            <tr key={rowKey(item)}>
              {columns.map((column) => {
                const rawValue =
                  column.render?.(item) ??
                  (column.dataIndex ? (item as Record<string, unknown>)[column.dataIndex as string] : null);
                const content =
                  rawValue === null || rawValue === undefined || rawValue === '' ? '--' : (rawValue as ReactNode);
                return (
                  <td
                    key={column.key}
                    className={clsx(
                      column.className,
                      column.align ? `data-table__cell--${column.align}` : undefined,
                    )}
                  >
                    {content}
                  </td>
                );
              })}
            </tr>
          ))
        )}
      </tbody>
    </table>
  </div>
);

export default DataTable;
