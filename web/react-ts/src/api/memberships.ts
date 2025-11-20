import type { Membership, PaginatedResource } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface MembershipQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  status?: string;
  search?: string;
}

export interface MembershipPayload extends Record<string, unknown> {
  code: string;
  title: string;
  image?: string;
  link?: string;
  description?: string;
  benefits?: string;
  criteria?: string;
  status?: string;
}

export const fetchMemberships = async (params: MembershipQueryParams = {}): Promise<PaginatedResource<Membership>> => {
  const { data } = await apiClient.get<PaginatedResource<Membership>>('/memberships', {
    params: removeEmpty(params),
  });
  return data;
};

export const fetchMembership = async (id: number): Promise<Membership> => {
  const { data } = await apiClient.get<Membership>(`/memberships/${id}`);
  return data;
};

export const createMembership = async (payload: MembershipPayload): Promise<Membership> => {
  const { data } = await apiClient.post<Membership>('/memberships', removeEmpty(payload));
  return data;
};

export const updateMembership = async (id: number, payload: Partial<MembershipPayload>): Promise<Membership> => {
  const { data } = await apiClient.patch<Membership>(`/memberships/${id}`, removeEmpty(payload));
  return data;
};

export const deleteMembership = async (id: number): Promise<void> => {
  await apiClient.delete(`/memberships/${id}`);
};
