import dayjs from 'dayjs';

const DATE_FORMAT = 'DD/MM/YYYY';
const DATE_TIME_FORMAT = 'DD/MM/YYYY HH:mm';

export const formatDate = (value?: string | null) => {
  if (!value) return '--';
  return dayjs(value).format(DATE_FORMAT);
};

export const formatDateTime = (value?: string | null) => {
  if (!value) return '--';
  return dayjs(value).format(DATE_TIME_FORMAT);
};

export const formatTime = (value?: string | null) => {
  if (!value) return '--';
  return dayjs(value).format('HH:mm');
};

export const formatCurrency = (value?: string | number | null, currency = 'VND') => {
  if (value === undefined || value === null) return '--';
  const numeric = typeof value === 'number' ? value : Number(value);
  if (Number.isNaN(numeric)) return String(value);
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency }).format(numeric);
};

export const formatStatus = (value?: string | null) => {
  if (!value) return '--';
  return value.replace(/[_-]/g, ' ').replace(/\b\w/g, (char) => char.toUpperCase());
};

