import clsx from 'clsx';
import type { HTMLAttributes } from 'react';

export interface StatusDotProps extends HTMLAttributes<HTMLSpanElement> {
  status?: 'active' | 'inactive' | 'pending' | 'success' | 'danger' | 'warning' | string | null;
}

const getVariant = (status?: StatusDotProps['status']) => {
  if (!status) return 'default';
  const normalized = status.toString().toLowerCase();
  if (normalized.includes('inactive') || normalized.includes('expired') || normalized.includes('cancel')) {
    return 'danger';
  }
  if (normalized.includes('pending') || normalized.includes('draft')) {
    return 'warning';
  }
  if (normalized.includes('active') || normalized.includes('success') || normalized.includes('confirmed')) {
    return 'success';
  }
  return 'default';
};

const StatusDot = ({ status, className, children, ...rest }: StatusDotProps) => (
  <span className={clsx('status-dot', className)} {...rest}>
    <span className={clsx('status-dot__indicator', `status-dot__indicator--${getVariant(status)}`)} />
    <span>{children ?? status ?? '--'}</span>
  </span>
);

export default StatusDot;

