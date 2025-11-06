"use client";

interface PaginationProps {
  page: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

export function Pagination({ page, totalPages, onPageChange }: PaginationProps) {
  const canPrev = page > 1;
  const canNext = page < totalPages;

  return (
    <div className="flex items-center justify-between rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm shadow-sm">
      <span className="text-slate-500">
        Trang <strong>{page}</strong> / {totalPages || 1}
      </span>
      <div className="space-x-2">
        <button
          onClick={() => canPrev && onPageChange(page - 1)}
          disabled={!canPrev}
          className="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 transition hover:bg-slate-100 disabled:cursor-not-allowed disabled:text-slate-300"
        >
          Trước
        </button>
        <button
          onClick={() => canNext && onPageChange(page + 1)}
          disabled={!canNext}
          className="rounded-lg border border-slate-200 px-3 py-1 text-slate-600 transition hover:bg-slate-100 disabled:cursor-not-allowed disabled:text-slate-300"
        >
          Sau
        </button>
      </div>
    </div>
  );
}
