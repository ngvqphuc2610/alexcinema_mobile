import { useEffect } from 'react';
import { createPortal } from 'react-dom';
import clsx from 'clsx';

export interface ModalProps {
  open: boolean;
  title?: string;
  description?: string;
  onClose: () => void;
  children: React.ReactNode;
  actions?: React.ReactNode;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

const Modal = ({ open, title, description, onClose, children, actions, size = 'md', className }: ModalProps) => {
  useEffect(() => {
    if (!open) return undefined;
    const previous = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = previous;
    };
  }, [open]);

  if (!open) return null;

  return createPortal(
    <div className="modal" role="dialog" aria-modal="true">
      <div className="modal__backdrop" onClick={onClose} />
      <div className={clsx('modal__container', `modal__container--${size}`, className)}>
        <button type="button" className="modal__close" aria-label="Dong" onClick={onClose}>
          x
        </button>
        {(title || description) && (
          <header className="modal__header">
            {title && <h2 className="modal__title">{title}</h2>}
            {description && <p className="modal__description">{description}</p>}
          </header>
        )}
        <div className="modal__content">{children}</div>
        {actions && <footer className="modal__footer">{actions}</footer>}
      </div>
    </div>,
    document.body,
  );
};

export default Modal;

