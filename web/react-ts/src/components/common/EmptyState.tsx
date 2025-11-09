import type { HTMLAttributes } from 'react';
import clsx from 'clsx';

export interface EmptyStateProps extends HTMLAttributes<HTMLDivElement> {
  title?: string;
  description?: string;
  action?: React.ReactNode;
}

const EmptyState = ({
  title = 'Khong co du lieu',
  description = 'Hay thay doi bo loc hoac tao du lieu moi.',
  action,
  className,
  ...rest
}: EmptyStateProps) => (
  <div className={clsx('empty-state', className)} {...rest}>
    <h3 className="empty-state__title">{title}</h3>
    <p className="empty-state__description">{description}</p>
    {action && <div className="empty-state__action">{action}</div>}
  </div>
);

export default EmptyState;

