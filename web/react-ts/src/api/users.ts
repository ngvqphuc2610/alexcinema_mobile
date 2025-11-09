import type { PaginatedResource, User } from '../types';
import apiClient from './client';

export interface UserQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  search?: string;
}

export interface UpdateUserPayload extends Record<string, unknown> {
  username?: string;
  email?: string;
  fullName?: string;
  phoneNumber?: string;
  dateOfBirth?: string;
  gender?: string;
  address?: string;
  profileImage?: string;
  role?: string;
  status?: string;
}

const removeEmpty = <T extends Record<string, unknown>>(payload: T) => {
  const result: Record<string, unknown> = {};
  Object.entries(payload).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      result[key] = value;
    }
  });
  return result;
};

export const fetchUsers = async (params: UserQueryParams = {}): Promise<PaginatedResource<User>> => {
  const { data } = await apiClient.get<PaginatedResource<User>>('/users', { params: removeEmpty(params) });
  return data;
};

export const fetchUser = async (id: number): Promise<User> => {
  const { data } = await apiClient.get<User>(`/users/${id}`);
  return data;
};

export const updateUser = async (id: number, payload: UpdateUserPayload): Promise<User> => {
  const { data } = await apiClient.patch<User>(`/users/${id}`, removeEmpty(payload));
  return data;
};

export const deleteUser = async (id: number): Promise<void> => {
  await apiClient.delete(`/users/${id}`);
};

export const updateUserPassword = async (id: number, newPassword: string): Promise<User> => {
  const { data } = await apiClient.patch<User>(`/users/${id}/password`, { newPassword });
  return data;
};
