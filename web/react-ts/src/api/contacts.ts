import type { Contact, PaginatedResource } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface ContactQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  status?: string;
  staffId?: number;
  search?: string;
}

export interface ContactPayload extends Record<string, unknown> {
  name: string;
  email: string;
  subject: string;
  message: string;
  idStaff?: number;
  status?: string;
  reply?: string;
}

export interface ContactUpdatePayload extends Record<string, unknown> {
  subject?: string;
  message?: string;
  idStaff?: number;
  status?: string;
  reply?: string;
  replyDate?: string;
}

export const fetchContacts = async (params: ContactQueryParams = {}): Promise<PaginatedResource<Contact>> => {
  const { data } = await apiClient.get<PaginatedResource<Contact>>('/contacts', { params: removeEmpty(params) });
  return data;
};

export const fetchContact = async (id: number): Promise<Contact> => {
  const { data } = await apiClient.get<Contact>(`/contacts/${id}`);
  return data;
};

export const createContact = async (payload: ContactPayload): Promise<Contact> => {
  const { data } = await apiClient.post<Contact>('/contacts', removeEmpty(payload));
  return data;
};

export const updateContact = async (id: number, payload: ContactUpdatePayload): Promise<Contact> => {
  const { data } = await apiClient.patch<Contact>(`/contacts/${id}`, removeEmpty(payload));
  return data;
};

export const deleteContact = async (id: number): Promise<void> => {
  await apiClient.delete(`/contacts/${id}`);
};
