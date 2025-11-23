import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface TypeProduct {
  id: number;
  name: string;
  description?: string | null;
}

export interface TypeProductPayload {
  typeName: string;
  description?: string;
}

export const fetchTypeProducts = async (): Promise<TypeProduct[]> => {
  const { data } = await apiClient.get<TypeProduct[]>('/type-product');
  return data;
};

export const createTypeProduct = async (payload: TypeProductPayload): Promise<TypeProduct> => {
  const { data } = await apiClient.post<TypeProduct>('/type-product', removeEmpty(payload));
  return data;
};

export const updateTypeProduct = async (id: number, payload: Partial<TypeProductPayload>): Promise<TypeProduct> => {
  const { data } = await apiClient.patch<TypeProduct>(`/type-product/${id}`, removeEmpty(payload));
  return data;
};

export const deleteTypeProduct = async (id: number): Promise<void> => {
  await apiClient.delete(`/type-product/${id}`);
};
