import { useState } from 'react';
import type { Staff } from '../../types';
import FormField from './FormField';
import Button from '../common/Button';

export interface ContactFormValues extends Record<string, unknown> {
  subject?: string;
  message?: string;
  status?: string;
  idStaff?: number;
  reply?: string;
  replyDate?: string;
}

interface ContactFormProps {
  staff: Staff[];
  defaultValues?: ContactFormValues;
  isSubmitting?: boolean;
  onSubmit: (values: ContactFormValues) => void;
  onCancel: () => void;
}

const ContactForm = ({ staff, defaultValues, isSubmitting, onSubmit, onCancel }: ContactFormProps) => {
  const [values, setValues] = useState<ContactFormValues>(
    defaultValues ?? {
      subject: '',
      message: '',
      status: 'unread',
      idStaff: undefined,
      reply: '',
      replyDate: new Date().toISOString().substring(0, 10),
    },
  );

  const handleChange = (field: keyof ContactFormValues, value: string) => {
    if (field === 'idStaff') {
      setValues((prev) => ({ ...prev, idStaff: value ? Number(value) : undefined }));
      return;
    }
    setValues((prev) => ({ ...prev, [field]: value }));
  };

  return (
    <form
      className="form"
      onSubmit={(event) => {
        event.preventDefault();
        onSubmit(values);
      }}
    >
      <FormField label="Tieu de" htmlFor="contact-subject">
        <input
          id="contact-subject"
          value={values.subject ?? ''}
          onChange={(event) => handleChange('subject', event.target.value)}
        />
      </FormField>
      <FormField label="Noi dung" htmlFor="contact-message">
        <textarea
          id="contact-message"
          value={values.message ?? ''}
          onChange={(event) => handleChange('message', event.target.value)}
        />
      </FormField>
      <FormField label="Trang thai" htmlFor="contact-status">
        <select
          id="contact-status"
          value={values.status ?? ''}
          onChange={(event) => handleChange('status', event.target.value)}
        >
          <option value="unread">Chua doc</option>
          <option value="in_progress">Dang xu ly</option>
          <option value="resolved">Da xu ly</option>
          <option value="">Khac</option>
        </select>
      </FormField>
      <FormField label="Nhan vien phu trach" htmlFor="contact-staff">
        <select
          id="contact-staff"
          value={values.idStaff ?? ''}
          onChange={(event) => handleChange('idStaff', event.target.value)}
        >
          <option value="">-- Khong chon --</option>
          {staff.map((member) => (
            <option key={member.id_staff} value={member.id_staff}>
              {member.staff_name}
            </option>
          ))}
        </select>
      </FormField>
      <FormField label="Tra loi" htmlFor="contact-reply">
        <textarea
          id="contact-reply"
          value={values.reply ?? ''}
          onChange={(event) => handleChange('reply', event.target.value)}
        />
      </FormField>
      <FormField label="Ngay tra loi" htmlFor="contact-reply-date">
        <input
          id="contact-reply-date"
          type="date"
          value={values.replyDate ?? ''}
          onChange={(event) => handleChange('replyDate', event.target.value)}
        />
      </FormField>
      <div className="form__actions">
        <Button type="button" variant="ghost" disabled={isSubmitting} onClick={onCancel}>
          Huy
        </Button>
        <Button type="submit" isLoading={isSubmitting}>
          Cap nhat
        </Button>
      </div>
    </form>
  );
};

export default ContactForm;
