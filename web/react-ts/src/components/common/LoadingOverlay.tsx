import clsx from 'clsx';
import type { HTMLAttributes } from 'react';

export interface LoadingOverlayProps extends HTMLAttributes<HTMLDivElement> {
  fullscreen?: boolean;
  message?: string;
}

const LoadingOverlay = ({
  fullscreen = false,
  message = 'Dang tai du lieu...',
  className,
  ...rest
}: LoadingOverlayProps) => (
  <div
    className={clsx('loading-overlay', { 'loading-overlay--fullscreen': fullscreen }, className)}
    role="status"
    {...rest}
  >
    <span className="loading-overlay__spinner" />
    <span className="loading-overlay__message">{message}</span>
  </div>
);

export default LoadingOverlay;

