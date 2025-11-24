import type { PaginatedResource, Promotion } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface PromotionQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  status?: string;
  search?: string;
}

export interface PromotionPayload extends Record<string, unknown> {
  promotionCode: string;
  title: string;
  description?: string;
  image?: string;
  discountPercent?: number;
  discountAmount?: number;
  startDate: string;
  endDate?: string;
  minPurchase?: number;
  maxDiscount?: number;
  usageLimit?: number;
  status?: string;
}

export const fetchPromotions = async (params: PromotionQueryParams = {}): Promise<PaginatedResource<Promotion>> => {
  const { data } = await apiClient.get<PaginatedResource<Promotion>>('/promotions', {
    params: removeEmpty(params),
  });
  return data;
};

export const fetchPromotion = async (id: number): Promise<Promotion> => {
  const { data } = await apiClient.get<Promotion>(`/promotions/${id}`);
  return data;
};

export const createPromotion = async (payload: PromotionPayload): Promise<Promotion> => {
  const { data } = await apiClient.post<Promotion>('/promotions', removeEmpty(payload));
  return data;
};

export const updatePromotion = async (id: number, payload: Partial<PromotionPayload>): Promise<Promotion> => {
  const { data } = await apiClient.patch<Promotion>(`/promotions/${id}`, removeEmpty(payload));
  return data;
};

export const deletePromotion = async (id: number): Promise<void> => {
  await apiClient.delete(`/promotions/${id}`);
};
