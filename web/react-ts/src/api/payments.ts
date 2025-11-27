import type { ApiListResponse, Payment } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface PaymentQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  status?: string;
  bookingCode?: string;
  transactionId?: string;
  methodCode?: string;
}

export interface PaymentPayload extends Record<string, unknown> {
  idBooking?: number;
  idPaymentMethod?: number;
  paymentMethod?: string;
  paymentDate?: string;
  amount: number;
  transactionId?: string;
  status?: string;
  paymentDetails?: string;
  providerCode?: string;
  providerOrderId?: string;
  providerTransId?: string;
  providerReturnCode?: string;
  providerReturnMessage?: string;
}

export interface UpdatePaymentPayload extends Partial<PaymentPayload> {}

export const fetchPayments = async (params: PaymentQueryParams = {}): Promise<ApiListResponse<Payment>> => {
  const { data } = await apiClient.get<ApiListResponse<Payment>>('/payments', { params: removeEmpty(params) });
  return data;
};

export const fetchPayment = async (id: number): Promise<Payment> => {
  const { data } = await apiClient.get<Payment>(`/payments/${id}`);
  return data;
};

export const createPayment = async (payload: PaymentPayload): Promise<Payment> => {
  const { data } = await apiClient.post<Payment>('/payments', removeEmpty(payload));
  return data;
};

export const updatePayment = async (id: number, payload: UpdatePaymentPayload): Promise<Payment> => {
  const { data } = await apiClient.patch<Payment>(`/payments/${id}`, removeEmpty(payload));
  return data;
};

export const deletePayment = async (id: number): Promise<void> => {
  await apiClient.delete(`/payments/${id}`);
};
