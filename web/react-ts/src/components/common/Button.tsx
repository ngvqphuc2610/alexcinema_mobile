import { forwardRef } from 'react';
import type { ButtonHTMLAttributes, ReactNode } from 'react';
import clsx from 'clsx';

type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
  isLoading?: boolean;
  fullWidth?: boolean;
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      children,
      type = 'button',
      variant = 'primary',
      leftIcon,
      rightIcon,
      isLoading = false,
      disabled,
      fullWidth = false,
      className,
      ...rest
    },
    ref,
  ) => {
    const isDisabled = disabled || isLoading;
    return (
      <button
        ref={ref}
        type={type}
        className={clsx(
          'btn',
          `btn--${variant}`,
          { 'btn--loading': isLoading, 'btn--full': fullWidth },
          className,
        )}
        disabled={isDisabled}
        {...rest}
      >
        {isLoading && <span className="btn__spinner" aria-hidden="true" />}
        {leftIcon && <span className="btn__icon btn__icon--left">{leftIcon}</span>}
        <span className="btn__label">{children}</span>
        {rightIcon && <span className="btn__icon btn__icon--right">{rightIcon}</span>}
      </button>
    );
  },
);

Button.displayName = 'Button';

export default Button;

