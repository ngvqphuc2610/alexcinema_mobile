import type { HTMLAttributes } from 'react';
import clsx from 'clsx';

export interface FormFieldProps extends HTMLAttributes<HTMLDivElement> {
  label: string;
  htmlFor?: string;
  error?: string;
  required?: boolean;
  description?: string;
}

const FormField = ({
  label,
  htmlFor,
  error,
  required = false,
  description,
  className,
  children,
  ...rest
}: FormFieldProps) => (
  <div className={clsx('form-field', className)} {...rest}>
    <label className="form-field__label" htmlFor={htmlFor}>
      {label}
      {required && <span className="form-field__required">*</span>}
    </label>
    {description && <p className="form-field__description">{description}</p>}
    <div className="form-field__control">{children}</div>
    {error && <p className="form-field__error">{error}</p>}
  </div>
);

export default FormField;

