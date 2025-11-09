import clsx from 'clsx';
import type { HTMLAttributes } from 'react';

export type BadgeVariant = 'default' | 'success' | 'warning' | 'danger' | 'info';

export interface BadgeProps extends HTMLAttributes<HTMLSpanElement> {
  variant?: BadgeVariant;
}

const Badge = ({ children, variant = 'default', className, ...rest }: BadgeProps) => (
  <span className={clsx('badge', `badge--${variant}`, className)} {...rest}>
    {children}
  </span>
);

export default Badge;

