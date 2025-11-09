import type { HTMLAttributes } from 'react';
import clsx from 'clsx';
import Button from './Button';

export interface ErrorStateProps extends HTMLAttributes<HTMLDivElement> {
  title?: string;
  description?: string;
  onRetry?: () => void;
}

const ErrorState = ({
  title = 'Da co loi xay ra',
  description = 'Vui long thu lai sau.',
  onRetry,
  className,
  ...rest
}: ErrorStateProps) => (
  <div className={clsx('empty-state', 'empty-state--error', className)} {...rest}>
    <h3 className="empty-state__title">{title}</h3>
    <p className="empty-state__description">{description}</p>
    {onRetry && (
      <Button variant="primary" onClick={onRetry}>
        Thu lai
      </Button>
    )}
  </div>
);

export default ErrorState;

