import type { Member, PaginatedResource } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface MemberQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  status?: string;
  typeMemberId?: number;
  membershipId?: number;
  userId?: number;
}

export interface MemberPayload extends Record<string, unknown> {
  idUser: number;
  idTypeMember: number;
  idMembership?: number;
  points?: number;
  joinDate?: string;
  status?: string;
}

export const fetchMembers = async (params: MemberQueryParams = {}): Promise<PaginatedResource<Member>> => {
  const { data } = await apiClient.get<PaginatedResource<Member>>('/members', { params: removeEmpty(params) });
  return data;
};

export const fetchMember = async (id: number): Promise<Member> => {
  const { data } = await apiClient.get<Member>(`/members/${id}`);
  return data;
};

export const createMember = async (payload: MemberPayload): Promise<Member> => {
  const { data } = await apiClient.post<Member>('/members', removeEmpty(payload));
  return data;
};

export const updateMember = async (id: number, payload: Partial<MemberPayload>): Promise<Member> => {
  const { data } = await apiClient.patch<Member>(`/members/${id}`, removeEmpty(payload));
  return data;
};

export const deleteMember = async (id: number): Promise<void> => {
  await apiClient.delete(`/members/${id}`);
};
