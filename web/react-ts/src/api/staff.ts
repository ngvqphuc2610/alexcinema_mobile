import type { PaginatedResource, Staff } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface StaffQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  status?: string;
  typeStaffId?: number;
  search?: string;
}

export interface StaffPayload extends Record<string, unknown> {
  idTypeStaff?: number;
  staffName: string;
  email: string;
  password: string;
  phoneNumber?: string;
  address?: string;
  dateOfBirth?: string;
  hireDate?: string;
  status?: string;
  profileImage?: string;
}

export interface StaffUpdatePayload extends Record<string, unknown> {
  idTypeStaff?: number;
  staffName?: string;
  email?: string;
  phoneNumber?: string;
  address?: string;
  dateOfBirth?: string;
  hireDate?: string;
  status?: string;
  profileImage?: string;
}

export const fetchStaff = async (params: StaffQueryParams = {}): Promise<PaginatedResource<Staff>> => {
  const { data } = await apiClient.get<PaginatedResource<Staff>>('/staff', { params: removeEmpty(params) });
  return data;
};

export const fetchStaffMember = async (id: number): Promise<Staff> => {
  const { data } = await apiClient.get<Staff>(`/staff/${id}`);
  return data;
};

export const createStaff = async (payload: StaffPayload): Promise<Staff> => {
  const { data } = await apiClient.post<Staff>('/staff', removeEmpty(payload));
  return data;
};

export const updateStaff = async (id: number, payload: StaffUpdatePayload): Promise<Staff> => {
  const { data } = await apiClient.patch<Staff>(`/staff/${id}`, removeEmpty(payload));
  return data;
};

export const updateStaffPassword = async (id: number, newPassword: string): Promise<Staff> => {
  const { data } = await apiClient.patch<Staff>(`/staff/${id}/password`, { newPassword });
  return data;
};

export const deleteStaff = async (id: number): Promise<void> => {
  await apiClient.delete(`/staff/${id}`);
};
