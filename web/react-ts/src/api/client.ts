import axios from 'axios';
import { clearStoredAuthToken, getStoredAuthToken } from '../utils/auth-storage';

const API_BASE_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:3000';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
});

let authToken: string | null = getStoredAuthToken();

export const AUTH_UNAUTHORIZED_EVENT = 'auth:unauthorized';

export const setAuthToken = (token: string | null) => {
  authToken = token;
};

apiClient.interceptors.request.use((config) => {
  if (authToken) {
    // eslint-disable-next-line no-param-reassign
    config.headers.Authorization = `Bearer ${authToken}`;
  } else {
    // eslint-disable-next-line no-param-reassign
    delete config.headers.Authorization;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      clearStoredAuthToken();
      setAuthToken(null);
      window.dispatchEvent(new CustomEvent(AUTH_UNAUTHORIZED_EVENT));
    }
    return Promise.reject(error);
  },
);

export default apiClient;

