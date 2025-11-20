import type { Entertainment, PaginatedResource } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface EntertainmentQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  status?: string;
  featured?: boolean;
  search?: string;
  cinemaId?: number;
}

export interface EntertainmentPayload extends Record<string, unknown> {
  idCinema?: number;
  title: string;
  description?: string;
  imageUrl?: string;
  startDate: string;
  endDate?: string;
  status?: string;
  viewsCount?: number;
  featured?: boolean;
  idStaff?: number;
}

export const fetchEntertainment = async (
  params: EntertainmentQueryParams = {},
): Promise<PaginatedResource<Entertainment>> => {
  const { data } = await apiClient.get<PaginatedResource<Entertainment>>('/entertainment', {
    params: removeEmpty(params),
  });
  return data;
};

export const fetchEntertainmentItem = async (id: number): Promise<Entertainment> => {
  const { data } = await apiClient.get<Entertainment>(`/entertainment/${id}`);
  return data;
};

export const createEntertainment = async (payload: EntertainmentPayload): Promise<Entertainment> => {
  const { data } = await apiClient.post<Entertainment>('/entertainment', removeEmpty(payload));
  return data;
};

export const updateEntertainment = async (id: number, payload: Partial<EntertainmentPayload>): Promise<Entertainment> => {
  const { data } = await apiClient.patch<Entertainment>(`/entertainment/${id}`, removeEmpty(payload));
  return data;
};

export const deleteEntertainment = async (id: number): Promise<void> => {
  await apiClient.delete(`/entertainment/${id}`);
};
