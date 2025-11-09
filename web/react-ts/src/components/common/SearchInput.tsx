import { useEffect, useState } from 'react';
import type { InputHTMLAttributes } from 'react';
import clsx from 'clsx';

export interface SearchInputProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'onChange'> {
  onSearch?: (value: string) => void;
  debounce?: number;
}

const SearchInput = ({
  placeholder = 'Tim kiem...',
  onSearch,
  debounce = 300,
  className,
  defaultValue = '',
  ...rest
}: SearchInputProps) => {
  const [value, setValue] = useState(String(defaultValue ?? ''));

  useEffect(() => {
    setValue(String(defaultValue ?? ''));
  }, [defaultValue]);

  useEffect(() => {
    if (!onSearch) return undefined;
    const handler = window.setTimeout(() => onSearch(value.trim()), debounce);
    return () => window.clearTimeout(handler);
  }, [value, debounce, onSearch]);

  return (
    <div className={clsx('search-input', className)}>
      <input
        {...rest}
        value={value}
        onChange={(event) => setValue(event.target.value)}
        placeholder={placeholder}
      />
      <span className="search-input__icon" aria-hidden="true">
        ?
      </span>
    </div>
  );
};

export default SearchInput;

