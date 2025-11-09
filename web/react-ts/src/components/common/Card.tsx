import type { HTMLAttributes } from 'react';
import clsx from 'clsx';

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
  title?: string;
  description?: string;
  actions?: React.ReactNode;
}

const Card = ({ title, description, actions, children, className, ...rest }: CardProps) => (
  <div className={clsx('card', className)} {...rest}>
    {(title || description || actions) && (
      <div className="card__header">
        <div>
          {title && <h3 className="card__title">{title}</h3>}
          {description && <p className="card__description">{description}</p>}
        </div>
        {actions && <div className="card__actions">{actions}</div>}
      </div>
    )}
    <div className="card__content">{children}</div>
  </div>
);

export default Card;

