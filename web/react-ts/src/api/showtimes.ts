import type { PaginatedResource, Showtime } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface ShowtimeQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  movieId?: number;
  screenId?: number;
  status?: string;
  format?: string;
  showDate?: string;
}

export interface ShowtimePayload extends Record<string, unknown> {
  idMovie?: number;
  idScreen?: number;
  showDate: string;
  startTime: string;
  endTime: string;
  format?: string;
  language?: string;
  subtitle?: string;
  status?: string;
  price: number;
}

export const fetchShowtimes = async (params: ShowtimeQueryParams = {}): Promise<PaginatedResource<Showtime>> => {
  const { data } = await apiClient.get<PaginatedResource<Showtime>>('/showtimes', { params: removeEmpty(params) });
  return data;
};

export const fetchShowtime = async (id: number): Promise<Showtime> => {
  const { data } = await apiClient.get<Showtime>(`/showtimes/${id}`);
  return data;
};

export const createShowtime = async (payload: ShowtimePayload): Promise<Showtime> => {
  const { data } = await apiClient.post<Showtime>('/showtimes', removeEmpty(payload));
  return data;
};

export const updateShowtime = async (id: number, payload: Partial<ShowtimePayload>): Promise<Showtime> => {
  const { data } = await apiClient.patch<Showtime>(`/showtimes/${id}`, removeEmpty(payload));
  return data;
};

export const deleteShowtime = async (id: number): Promise<void> => {
  await apiClient.delete(`/showtimes/${id}`);
};
