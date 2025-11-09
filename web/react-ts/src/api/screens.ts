import type { PaginatedResource, Screen } from '../types';
import apiClient from './client';

export interface ScreenQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  cinemaId?: number;
  screenTypeId?: number;
  status?: string;
  search?: string;
  minCapacity?: number;
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

export const fetchScreens = async (params: ScreenQueryParams = {}): Promise<PaginatedResource<Screen>> => {
  const { data } = await apiClient.get<PaginatedResource<Screen>>('/screens', { params: removeEmpty(params) });
  return data;
};
