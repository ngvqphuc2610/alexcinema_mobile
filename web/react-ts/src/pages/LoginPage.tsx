import { useState } from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import Button from '../components/common/Button';
import FormField from '../components/forms/FormField';
import { useAuth } from '../hooks/useAuth';

const LoginPage = () => {
  const navigate = useNavigate();
  const { login, verify2FA, user, isLoading } = useAuth();
  const [credentials, setCredentials] = useState({ usernameOrEmail: '', password: '' });
  const [twoFactorCode, setTwoFactorCode] = useState('');
  const [pendingSession, setPendingSession] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  if (user && !isLoading) {
    return <Navigate to="/dashboard" replace />;
  }

  const resetFlow = () => {
    setPendingSession(null);
    setTwoFactorCode('');
    setError(null);
  };

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      if (pendingSession) {
        await verify2FA({
          usernameOrEmail: credentials.usernameOrEmail,
          token: twoFactorCode.trim(),
          sessionToken: pendingSession,
        });
      } else {
        const response = await login(credentials);
        if (response.requires2FA && response.sessionToken) {
          setPendingSession(response.sessionToken);
          return;
        }
      }

      navigate('/dashboard', { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Dang nhap that bai, vui long thu lai.');
    } finally {
      setSubmitting(false);
    }
  };

  const isTwoFactorStep = Boolean(pendingSession);

  return (
    <div className="auth">
      <div className="auth__card">
        <div className="auth__header">
          <span className="auth__logo">AC</span>
          <h1 className="auth__title">Alex Cinema Admin</h1>
          <p className="auth__subtitle">
            {isTwoFactorStep
              ? 'Nhap ma 2FA hoac backup code de hoan tat dang nhap'
              : 'Dang nhap de quan ly rap chieu phim'}
          </p>
        </div>

        <form className="auth__form" onSubmit={handleSubmit}>
          {!isTwoFactorStep && (
            <>
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
                  onChange={(event) =>
                    setCredentials((prev) => ({ ...prev, password: event.target.value }))
                  }
                />
              </FormField>
            </>
          )}

          {isTwoFactorStep && (
            <>
              <FormField
                label="Ma 2FA hoac backup code"
                htmlFor="login-2fa"
                required
                description="Nhap ma tu ung dung Authenticator hoac 1 trong cac ma backup cua ban."
              >
                <input
                  id="login-2fa"
                  autoComplete="one-time-code"
                  inputMode="text"
                  placeholder="123456 hoac ABCD-EFGH"
                  value={twoFactorCode}
                  onChange={(event) => setTwoFactorCode(event.target.value)}
                  pattern="[0-9A-Za-z-]{6,32}"
                />
              </FormField>
              <Button type="button" variant="ghost" fullWidth onClick={resetFlow}>
                Dang nhap lai tai khoan khac
              </Button>
            </>
          )}

          {error && <p className="auth__error">{error}</p>}

          <Button
            type="submit"
            fullWidth
            isLoading={submitting}
            disabled={
              isTwoFactorStep
                ? !twoFactorCode
                : !credentials.usernameOrEmail || !credentials.password
            }
          >
            {isTwoFactorStep ? 'Xac minh & truy cap' : 'Dang nhap'}
          </Button>
        </form>
      </div>
    </div>
  );
};

export default LoginPage;
