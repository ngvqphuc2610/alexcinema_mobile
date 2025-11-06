'use client';

import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react';
import { apiFetch } from '@/lib/api';

interface AuthUser {
  id_users: number;
  username: string;
  email: string;
  role: string;
  full_name: string;
}

interface AuthResponse {
  accessToken: string;
  expiresIn: string;
  user: AuthUser;
}

interface AuthContextValue {
  user: AuthUser | null;
  token: string | null;
  loading: boolean;
  login: (usernameOrEmail: string, password: string) => Promise<void>;
  logout: () => void;
}

const STORAGE_KEY = 'cinema_admin_auth';

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const restoreSession = async () => {
      setLoading(true);
      try {
        const stored = typeof window !== 'undefined' ? localStorage.getItem(STORAGE_KEY) : null;
        if (!stored) {
          setLoading(false);
          return;
        }

        const parsed = JSON.parse(stored) as { token: string; user: AuthUser };
        setToken(parsed.token);
        setUser(parsed.user);

        const me = await apiFetch<AuthUser>('/auth/me', { method: 'GET' }, parsed.token);
        if (me.role !== 'admin') {
          throw new Error('Not admin');
        }
        setUser(me);
        if (typeof window !== 'undefined') {
          localStorage.setItem(STORAGE_KEY, JSON.stringify({ token: parsed.token, user: me }));
        }
      } catch {
        logout();
      } finally {
        setLoading(false);
      }
    };

    restoreSession();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const login = useCallback(async (usernameOrEmail: string, password: string) => {
    const response = await apiFetch<AuthResponse>(
      '/auth/login',
      {
        method: 'POST',
        body: JSON.stringify({ usernameOrEmail, password }),
      },
      null,
    );

    if (response.user.role !== 'admin') {
      throw new Error('Tài khoản không có quyền quản trị');
    }

    setToken(response.accessToken);
    setUser(response.user);
    if (typeof window !== 'undefined') {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({ token: response.accessToken, user: response.user }));
    }
  }, []);

  const logout = useCallback(() => {
    setToken(null);
    setUser(null);
    if (typeof window !== 'undefined') {
      localStorage.removeItem(STORAGE_KEY);
    }
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      token,
      loading,
      login,
      logout,
    }),
    [user, token, loading, login, logout],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuthContext = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuthContext must be used within an AuthProvider');
  }
  return context;
};
