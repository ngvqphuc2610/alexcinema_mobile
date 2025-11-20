import type { PaginatedResource, Screen } from '../types';
import apiClient from './client';
import { removeEmpty } from '../utils/api';

export interface ScreenQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  cinemaId?: number;
  screenTypeId?: number;
  status?: string;
  search?: string;
  minCapacity?: number;
}

export interface ScreenPayload extends Record<string, unknown> {
  idCinema?: number;
  idScreenType?: number;
  screenName: string;
  capacity: number;
  status?: string;
}

export const fetchScreens = async (params: ScreenQueryParams = {}): Promise<PaginatedResource<Screen>> => {
  const { data } = await apiClient.get<PaginatedResource<Screen>>('/screens', { params: removeEmpty(params) });
  return data;
};

export const fetchScreen = async (id: number): Promise<Screen> => {
  const { data } = await apiClient.get<Screen>(`/screens/${id}`);
  return data;
};

export const createScreen = async (payload: ScreenPayload): Promise<Screen> => {
  const { data } = await apiClient.post<Screen>('/screens', removeEmpty(payload));
  return data;
};

export const updateScreen = async (id: number, payload: Partial<ScreenPayload>): Promise<Screen> => {
  const { data } = await apiClient.patch<Screen>(`/screens/${id}`, removeEmpty(payload));
  return data;
};

export const deleteScreen = async (id: number): Promise<void> => {
  await apiClient.delete(`/screens/${id}`);
};
