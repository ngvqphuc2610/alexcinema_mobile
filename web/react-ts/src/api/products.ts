import apiClient from './client';
import { removeEmpty } from '../utils/api';
export interface Product {
  id: number;
  typeId: number;
  name: string;
  description?: string | null;
  price: number;
  image?: string | null;
  status?: string | null;
  quantity?: number | null;
}

export interface ProductCategory {
  id: number;
  name: string;
  description?: string | null;
  products: Product[];
}

export interface ProductPayload extends Record<string, unknown> {
  idTypeProduct: number;
  name: string;
  description?: string;
  price: number;
  image?: string;
  status?: string;
  quantity?: number;
}

export const fetchProducts = async (): Promise<ProductCategory[]> => {
  const { data } = await apiClient.get<ProductCategory[]>('/product');
  return data;
};

export const fetchAllProducts = async (): Promise<Product[]> => {
  const { data } = await apiClient.get<Product[]>('/product/items');
  return data;
};

export const createProduct = async (payload: ProductPayload): Promise<Product> => {
  const { data } = await apiClient.post<Product>('/product', removeEmpty(payload));
  return data;
};

export const updateProduct = async (id: number, payload: Partial<ProductPayload>): Promise<Product> => {
  const { data } = await apiClient.patch<Product>(`/product/${id}`, removeEmpty(payload));
  return data;
};

export const deleteProduct = async (id: number): Promise<void> => {
  await apiClient.delete(`/product/${id}`);
};
