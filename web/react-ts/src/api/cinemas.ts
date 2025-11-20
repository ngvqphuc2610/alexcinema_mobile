import type { Cinema, PaginatedResource } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface CinemaQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  city?: string;
  status?: string;
  search?: string;
}

export interface CinemaPayload extends Record<string, unknown> {
  cinemaName: string;
  address: string;
  city: string;
  description?: string;
  image?: string;
  contactNumber?: string;
  email?: string;
  status?: string;
}

export const fetchCinemas = async (params: CinemaQueryParams = {}): Promise<PaginatedResource<Cinema>> => {
  const { data } = await apiClient.get<PaginatedResource<Cinema>>('/cinemas', { params: removeEmpty(params) });
  return data;
};

export const fetchCinema = async (id: number): Promise<Cinema> => {
  const { data } = await apiClient.get<Cinema>(`/cinemas/${id}`);
  return data;
};

export const createCinema = async (payload: CinemaPayload): Promise<Cinema> => {
  const { data } = await apiClient.post<Cinema>('/cinemas', removeEmpty(payload));
  return data;
};

export const updateCinema = async (id: number, payload: Partial<CinemaPayload>): Promise<Cinema> => {
  const { data } = await apiClient.patch<Cinema>(`/cinemas/${id}`, removeEmpty(payload));
  return data;
};

export const deleteCinema = async (id: number): Promise<void> => {
  await apiClient.delete(`/cinemas/${id}`);
};
