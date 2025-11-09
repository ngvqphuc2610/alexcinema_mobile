import { useState } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import Button from '../components/common/Button';
import FormField from '../components/forms/FormField';
import { useAuth } from '../hooks/useAuth';

const LoginPage = () => {
  const navigate = useNavigate();
  const { login, user, isLoading } = useAuth();
  const [credentials, setCredentials] = useState({ usernameOrEmail: '', password: '' });
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  if (user && !isLoading) {
    return <Navigate to="/dashboard" replace />;
  }

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await login(credentials);
      navigate('/dashboard', { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Dang nhap that bai, vui long thu lai.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="auth">
      <div className="auth__card">
        <div className="auth__header">
          <span className="auth__logo">AC</span>
          <h1 className="auth__title">Alex Cinema Admin</h1>
          <p className="auth__subtitle">Dang nhap de quan ly rap chieu phim</p>
        </div>

        <form className="auth__form" onSubmit={handleSubmit}>
          <FormField label="Email hoac ten dang nhap" htmlFor="login-username" required>
            <input
              id="login-username"
              autoComplete="username"
              placeholder="admin@alexcinema.vn"
              value={credentials.usernameOrEmail}
              onChange={(event) =>
                setCredentials((prev) => ({ ...prev, usernameOrEmail: event.target.value }))
              }
            />
          </FormField>

          <FormField label="Mat khau" htmlFor="login-password" required>
            <input
              id="login-password"
              type="password"
              autoComplete="current-password"
              placeholder="******"
              value={credentials.password}
              onChange={(event) => setCredentials((prev) => ({ ...prev, password: event.target.value }))}
            />
          </FormField>

          {error && <p className="auth__error">{error}</p>}

          <Button
            type="submit"
            fullWidth
            isLoading={submitting}
            disabled={!credentials.usernameOrEmail || !credentials.password}
          >
            Dang nhap
          </Button>
        </form>
      </div>
    </div>
  );
};

export default LoginPage;

