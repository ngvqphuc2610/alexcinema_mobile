import type { PaginatedResource, TypeStaff } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface TypeStaffQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  search?: string;
}

export interface TypeStaffPayload extends Record<string, unknown> {
  typeName: string;
  description?: string;
  permissionLevel?: number;
}

export const fetchTypeStaff = async (params: TypeStaffQueryParams = {}): Promise<PaginatedResource<TypeStaff>> => {
  const { data } = await apiClient.get<PaginatedResource<TypeStaff>>('/type-staff', { params: removeEmpty(params) });
  return data;
};

export const createTypeStaff = async (payload: TypeStaffPayload): Promise<TypeStaff> => {
  const { data } = await apiClient.post<TypeStaff>('/type-staff', removeEmpty(payload));
  return data;
};

export const updateTypeStaff = async (id: number, payload: Partial<TypeStaffPayload>): Promise<TypeStaff> => {
  const { data } = await apiClient.patch<TypeStaff>(`/type-staff/${id}`, removeEmpty(payload));
  return data;
};

export const deleteTypeStaff = async (id: number): Promise<void> => {
  await apiClient.delete(`/type-staff/${id}`);
};
