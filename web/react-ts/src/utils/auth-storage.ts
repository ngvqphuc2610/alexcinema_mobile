import type { AuthUser } from '../types';

const TOKEN_KEY = 'alexcinema_admin_token';
const USER_KEY = 'alexcinema_admin_user';

export const storeAuthSession = (token: string, user: AuthUser) => {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
};

export const getStoredAuthToken = (): string | null => {
  return localStorage.getItem(TOKEN_KEY);
};

export const getStoredAuthUser = (): AuthUser | null => {
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) {
    return null;
  }
  try {
    return JSON.parse(raw) as AuthUser;
  } catch (error) {
    localStorage.removeItem(USER_KEY);
    return null;
  }
};

export const clearStoredAuth = () => {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
};

export const clearStoredAuthToken = () => {
  localStorage.removeItem(TOKEN_KEY);
};

export const updateStoredUser = (user: AuthUser) => {
  localStorage.setItem(USER_KEY, JSON.stringify(user));
};

