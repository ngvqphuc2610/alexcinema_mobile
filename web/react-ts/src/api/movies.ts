import type { Movie, PaginatedResource } from '../types';
import apiClient from './client';

export interface MovieQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  status?: string;
  search?: string;
}

export interface MoviePayload extends Record<string, unknown> {
  title: string;
  originalTitle?: string;
  director?: string;
  actors?: string;
  duration: number;
  releaseDate: string;
  endDate?: string;
  language?: string;
  subtitle?: string;
  country?: string;
  description?: string;
  posterImage?: string;
  bannerImage?: string;
  trailerUrl?: string;
  ageRestriction?: string;
  status: string;
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

export const fetchMovies = async (params: MovieQueryParams = {}): Promise<PaginatedResource<Movie>> => {
  const { data } = await apiClient.get<PaginatedResource<Movie>>('/movies', { params: removeEmpty(params) });
  return data;
};

export const fetchMovie = async (id: number): Promise<Movie> => {
  const { data } = await apiClient.get<Movie>(`/movies/${id}`);
  return data;
};

export const createMovie = async (payload: MoviePayload): Promise<Movie> => {
  const { data } = await apiClient.post<Movie>('/movies', removeEmpty(payload));
  return data;
};

export const updateMovie = async (id: number, payload: Partial<MoviePayload>): Promise<Movie> => {
  const { data } = await apiClient.patch<Movie>(`/movies/${id}`, removeEmpty(payload));
  return data;
};

export const deleteMovie = async (id: number): Promise<void> => {
  await apiClient.delete(`/movies/${id}`);
};
