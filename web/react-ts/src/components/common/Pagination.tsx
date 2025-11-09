import clsx from 'clsx';
import Button from './Button';

export interface PaginationProps {
  page: number;
  totalPages: number;
  onChange: (page: number) => void;
  pageSize?: number;
  total?: number;
  className?: string;
}

const Pagination = ({ page, totalPages, onChange, total, className }: PaginationProps) => {
  if (totalPages <= 1) {
    return null;
  }

  const canPrev = page > 1;
  const canNext = page < totalPages;

  return (
    <div className={clsx('pagination', className)}>
      <div className="pagination__info">
        Trang {page}/{totalPages}
        {typeof total === 'number' && <span> - Tong: {total}</span>}
      </div>
      <div className="pagination__actions">
        <Button variant="ghost" disabled={!canPrev} onClick={() => canPrev && onChange(page - 1)}>
          Truoc
        </Button>
        <Button variant="ghost" disabled={!canNext} onClick={() => canNext && onChange(page + 1)}>
          Tiep
        </Button>
      </div>
    </div>
  );
};

export default Pagination;
