'use client';

import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { useAuth } from './useAuth';

export const useProtectedRoute = () => {
  const auth = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!auth.loading && !auth.token) {
      router.replace('/login');
    }
  }, [auth.loading, auth.token, router]);

  return auth;
};
