'use client';

import { useEffect, useState } from 'react';
import { apiFetch } from '@/lib/api';
import { useAuth } from '@/hooks/useAuth';
import { DataTable, Column } from '@/components/DataTable';
import { Pagination } from '@/components/Pagination';

interface Contact {
  id_contact: number;
  name: string;
  email: string;
  subject: string;
  status: string;
  contact_date: string;
}

interface ContactsResponse {
  items: Contact[];
  meta: {
    page: number;
    totalPages: number;
  };
}

const COLUMNS: Column<Contact>[] = [
  { key: 'name', header: 'Người gửi' },
  { key: 'email', header: 'Email' },
  { key: 'subject', header: 'Chủ đề' },
  { key: 'status', header: 'Trạng thái', render: (item) => (item.status === 'unread' ? 'Chưa đọc' : item.status) },
  {
    key: 'contact_date',
    header: 'Ngày gửi',
    render: (item) => new Date(item.contact_date).toLocaleString('vi-VN'),
  },
];

export default function ContactsPage() {
  const { token } = useAuth();
  const [data, setData] = useState<Contact[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const load = async () => {
      if (!token) return;
      setLoading(true);
      setError(null);
      try {
        const response = await apiFetch<ContactsResponse>(`/contacts?page=${page}&limit=10`, {}, token);
        setData(response.items);
        setTotalPages(response.meta.totalPages || 1);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Không thể tải danh sách liên hệ');
      } finally {
        setLoading(false);
      }
    };

    load();
  }, [page, token]);

  return (
    <div className="space-y-6">
      <header>
        <h2 className="text-xl font-semibold text-slate-900">Hộp thư liên hệ</h2>
        <p className="text-sm text-slate-500">Theo dõi phản hồi từ khách hàng và xử lý kịp thời.</p>
      </header>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-600">{error}</div>}

      <DataTable data={data} columns={COLUMNS} keyExtractor={(item) => item.id_contact} loading={loading} />

      <Pagination page={page} totalPages={totalPages} onPageChange={setPage} />
    </div>
  );
}
