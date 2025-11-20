import type { PaginatedResource, Seat } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface SeatQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  screenId?: number;
  seatTypeId?: number;
  status?: string;
  seatRow?: string;
  seatNumber?: number;
}

export interface SeatPayload extends Record<string, unknown> {
  idScreen?: number;
  idSeatType?: number;
  seatRow: string;
  seatNumber: number;
  status?: string;
}

export const fetchSeats = async (params: SeatQueryParams = {}): Promise<PaginatedResource<Seat>> => {
  const { data } = await apiClient.get<PaginatedResource<Seat>>('/seats', { params: removeEmpty(params) });
  return data;
};

export const fetchSeat = async (id: number): Promise<Seat> => {
  const { data } = await apiClient.get<Seat>(`/seats/${id}`);
  return data;
};

export const createSeat = async (payload: SeatPayload): Promise<Seat> => {
  const { data } = await apiClient.post<Seat>('/seats', removeEmpty(payload));
  return data;
};

export const updateSeat = async (id: number, payload: Partial<SeatPayload>): Promise<Seat> => {
  const { data } = await apiClient.patch<Seat>(`/seats/${id}`, removeEmpty(payload));
  return data;
};

export const deleteSeat = async (id: number): Promise<void> => {
  await apiClient.delete(`/seats/${id}`);
};
