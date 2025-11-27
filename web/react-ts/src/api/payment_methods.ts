import type { PaymentMethod } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface PaymentMethodPayload extends Record<string, unknown> {
  methodCode: string;
  methodName: string;
  description?: string;
  iconUrl?: string;
  isActive?: boolean;
  processingFee?: number;
  minAmount?: number;
  maxAmount?: number;
  displayOrder?: number;
}

export interface PaymentMethodQuery {
  includeInactive?: boolean;
}

export const fetchPaymentMethods = async (params: PaymentMethodQuery = {}): Promise<PaymentMethod[]> => {
  const { data } = await apiClient.get<PaymentMethod[]>('/payment-methods', {
    params: removeEmpty(params),
  });
  return data;
};

export const fetchPaymentMethod = async (id: number): Promise<PaymentMethod> => {
  const { data } = await apiClient.get<PaymentMethod>(`/payment-methods/${id}`);
  return data;
};

export const createPaymentMethod = async (payload: PaymentMethodPayload): Promise<PaymentMethod> => {
  const { data } = await apiClient.post<PaymentMethod>('/payment-methods', removeEmpty(payload));
  return data;
};

export const updatePaymentMethod = async (
  id: number,
  payload: Partial<PaymentMethodPayload>,
): Promise<PaymentMethod> => {
  const { data } = await apiClient.patch<PaymentMethod>(`/payment-methods/${id}`, removeEmpty(payload));
  return data;
};

export const deletePaymentMethod = async (id: number): Promise<void> => {
  await apiClient.delete(`/payment-methods/${id}`);
};
