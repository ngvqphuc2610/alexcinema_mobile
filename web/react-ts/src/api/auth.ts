import type { AuthResponse, AuthUser } from '../types';
import apiClient, { setAuthToken } from './client';

export interface LoginPayload {
  usernameOrEmail: string;
  password: string;
}

export const login = async (payload: LoginPayload): Promise<AuthResponse> => {
  const { data } = await apiClient.post<AuthResponse>('/auth/login', payload);
  if (data.accessToken) {
    setAuthToken(data.accessToken);
  }
  return data;
};

export interface Verify2faPayload {
  usernameOrEmail: string;
  token: string;
  sessionToken: string;
}

export const verify2FA = async (payload: Verify2faPayload): Promise<AuthResponse> => {
  const { data } = await apiClient.post<AuthResponse>('/auth/verify-2fa', payload);
  if (data.accessToken) {
    setAuthToken(data.accessToken);
  }
  return data;
};

export const getProfile = async (): Promise<AuthUser> => {
  const { data } = await apiClient.get<AuthUser>('/auth/me');
  return data;
};
