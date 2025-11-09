import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';
import type { ReactNode } from 'react';
import type { AuthUser } from '../types';
import * as authApi from '../api/auth';
import { AUTH_UNAUTHORIZED_EVENT, setAuthToken } from '../api/client';
import {
  clearStoredAuth,
  getStoredAuthToken,
  getStoredAuthUser,
  storeAuthSession,
  updateStoredUser,
} from '../utils/auth-storage';

interface AuthContextValue {
  user: AuthUser | null;
  token: string | null;
  isLoading: boolean;
  login: (params: { usernameOrEmail: string; password: string }) => Promise<void>;
  logout: () => void;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const logout = useCallback(() => {
    clearStoredAuth();
    setAuthToken(null);
    setUser(null);
    setToken(null);
  }, []);

  const initialize = useCallback(async () => {
    const storedToken = getStoredAuthToken();
    const storedUser = getStoredAuthUser();

    if (!storedToken) {
      setIsLoading(false);
      return;
    }

    setAuthToken(storedToken);
    setToken(storedToken);
    if (storedUser) {
      setUser(storedUser);
    }

    try {
      const profile = await authApi.getProfile();
      setUser(profile);
      updateStoredUser(profile);
    } catch (error) {
      logout();
    } finally {
      setIsLoading(false);
    }
  }, [logout]);

  useEffect(() => {
    initialize();
  }, [initialize]);

  useEffect(() => {
    const handleUnauthorized = () => {
      logout();
    };
    window.addEventListener(AUTH_UNAUTHORIZED_EVENT, handleUnauthorized);
    return () => window.removeEventListener(AUTH_UNAUTHORIZED_EVENT, handleUnauthorized);
  }, [logout]);

  const login = useCallback(
    async ({ usernameOrEmail, password }: { usernameOrEmail: string; password: string }) => {
      const normalized = usernameOrEmail.trim();
      const response = await authApi.login({ usernameOrEmail: normalized, password });
      if (response.user.role !== 'admin') {
        throw new Error('Tai khoan khong co quyen quan tri.');
      }
      storeAuthSession(response.accessToken, response.user);
      setAuthToken(response.accessToken);
      setUser(response.user);
      setToken(response.accessToken);
    },
    [],
  );

  const refreshProfile = useCallback(async () => {
    const profile = await authApi.getProfile();
    setUser(profile);
    updateStoredUser(profile);
  }, []);

  const value = useMemo(
    () => ({
      user,
      token,
      isLoading,
      login,
      logout,
      refreshProfile,
    }),
    [user, token, isLoading, login, logout, refreshProfile],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuthContext = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuthContext must be used within AuthProvider');
  }
  return context;
};
