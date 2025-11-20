import { useState } from 'react';
import FormField from './FormField';
import Button from '../common/Button';

interface StaffPasswordFormProps {
  isSubmitting?: boolean;
  onSubmit: (password: string) => void;
  onCancel: () => void;
}

const StaffPasswordForm = ({ isSubmitting, onSubmit, onCancel }: StaffPasswordFormProps) => {
  const [password, setPassword] = useState('');

  return (
    <form
      className="form"
      onSubmit={(event) => {
        event.preventDefault();
        onSubmit(password);
      }}
    >
      <FormField label="Mat khau moi" htmlFor="staff-new-password" required>
        <input
          id="staff-new-password"
          type="password"
          minLength={6}
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          required
        />
      </FormField>
      <div className="form__actions">
        <Button type="button" variant="ghost" onClick={onCancel} disabled={isSubmitting}>
          Huy
        </Button>
        <Button type="submit" isLoading={isSubmitting} disabled={password.length < 6}>
          Cap nhat
        </Button>
      </div>
    </form>
  );
};

export default StaffPasswordForm;

