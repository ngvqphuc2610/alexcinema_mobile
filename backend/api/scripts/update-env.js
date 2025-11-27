const fs = require('fs');
const path = require('path');
const fetchImpl = globalThis.fetch;
if (typeof fetchImpl !== 'function') {
  throw new Error(
    'Global fetch API is unavailable in this Node version. Please upgrade Node.js or install node-fetch.',
  );
}

const NGROK_API = 'http://127.0.0.1:4040/api/tunnels';
const API_ENV_PATH = path.resolve(__dirname, '..', '.env');
const FLUTTER_ENV_PATH = path.resolve(__dirname, '..', '..', '..', '.env');
const TARGET_ENV_CONFIGS = [
  {
    path: API_ENV_PATH,
    key: 'API_URL',
  },
  {
    path: FLUTTER_ENV_PATH,
    key: 'FLUTTER_API_URL',
  },
];

const ZALOPAY_CALLBACK_CONFIG = {
  path: API_ENV_PATH,
  key: 'ZP_CALLBACK_URL',
};

const ZALOPAY_REDIRECT_CONFIG = {
  path: API_ENV_PATH,
  key: 'ZP_REDIRECT_URL',
};

const VNPAY_RETURN_CONFIG = {
  path: API_ENV_PATH,
  key: 'VNP_RETURN_URL',
};

const MOMO_RETURN_CONFIG = {
  path: API_ENV_PATH,
  key: 'MOMO_RETURN_URL',
};

const MOMO_NOTIFY_CONFIG = {
  path: API_ENV_PATH,
  key: 'MOMO_NOTIFY_URL',
};

async function fetchHttpsTunnel() {
  const response = await fetchImpl(NGROK_API);

  if (!response.ok) {
    throw new Error(`Unable to query ngrok API: ${response.status} ${response.statusText}`);
  }

  const data = await response.json();
  const httpsTunnel = data.tunnels?.find((tunnel) =>
    typeof tunnel.public_url === 'string' && tunnel.public_url.startsWith('https://'),
  );

  if (!httpsTunnel) {
    throw new Error('No https ngrok tunnel is currently running.');
  }

  return httpsTunnel.public_url;
}

function updateEnvFile(envPath, key, value) {
  let content = '';
  if (fs.existsSync(envPath)) {
    content = fs.readFileSync(envPath, 'utf8');
  }

  const pattern = new RegExp(`^${key}=.*$`, 'm');
  const replacement = `${key}=${value}`;

  if (pattern.test(content)) {
    content = content.replace(pattern, replacement);
  } else {
    const trimmed = content.trimEnd();
    content = trimmed.length > 0 ? `${trimmed}\n${replacement}\n` : `${replacement}\n`;
  }

  fs.writeFileSync(envPath, content);
}

function updateEnvWithUrl(publicUrl) {
  if (typeof publicUrl !== 'string' || publicUrl.trim().length === 0) {
    throw new Error('Invalid public URL provided to updateEnvWithUrl.');
  }

  const apiUrl = `${publicUrl.replace(/\/$/, '')}/api`;

  // Update API_URL and FLUTTER_API_URL
  TARGET_ENV_CONFIGS.forEach(({ path: envPath, key }) => {
    updateEnvFile(envPath, key, apiUrl);
    console.log(`Updated ${envPath} with ${key}=${apiUrl}`);
  });

  // Update ZP_CALLBACK_URL with ngrok URL
  const zpCallbackUrl = `${apiUrl}/payments/zalopay/callback`;
  updateEnvFile(ZALOPAY_CALLBACK_CONFIG.path, ZALOPAY_CALLBACK_CONFIG.key, zpCallbackUrl);
  console.log(`Updated ${ZALOPAY_CALLBACK_CONFIG.path} with ${ZALOPAY_CALLBACK_CONFIG.key}=${zpCallbackUrl}`);

  // Update ZP_REDIRECT_URL with ngrok URL (proxy endpoint)
  const zpRedirectUrl = `${apiUrl}/payments/zalopay/return`;
  updateEnvFile(ZALOPAY_REDIRECT_CONFIG.path, ZALOPAY_REDIRECT_CONFIG.key, zpRedirectUrl);
  console.log(`Updated ${ZALOPAY_REDIRECT_CONFIG.path} with ${ZALOPAY_REDIRECT_CONFIG.key}=${zpRedirectUrl}`);

  // Update VNP_RETURN_URL with ngrok URL
  const vnpReturnUrl = `${apiUrl}/payments/vnpay/return`;
  updateEnvFile(VNPAY_RETURN_CONFIG.path, VNPAY_RETURN_CONFIG.key, vnpReturnUrl);
  console.log(`Updated ${VNPAY_RETURN_CONFIG.path} with ${VNPAY_RETURN_CONFIG.key}=${vnpReturnUrl}`);

  // Update MOMO_RETURN_URL with ngrok URL
  const momoReturnUrl = `${apiUrl}/payments/momo/return`;
  updateEnvFile(MOMO_RETURN_CONFIG.path, MOMO_RETURN_CONFIG.key, momoReturnUrl);
  console.log(`Updated ${MOMO_RETURN_CONFIG.path} with ${MOMO_RETURN_CONFIG.key}=${momoReturnUrl}`);

  // Update MOMO_NOTIFY_URL with ngrok URL
  const momoNotifyUrl = `${apiUrl}/payments/momo/callback`;
  updateEnvFile(MOMO_NOTIFY_CONFIG.path, MOMO_NOTIFY_CONFIG.key, momoNotifyUrl);
  console.log(`Updated ${MOMO_NOTIFY_CONFIG.path} with ${MOMO_NOTIFY_CONFIG.key}=${momoNotifyUrl}`);

  return apiUrl;
}

async function runStandalone() {
  const publicUrl = await fetchHttpsTunnel();
  updateEnvWithUrl(publicUrl);
}

if (require.main === module) {
  runStandalone().catch((error) => {
    console.error('Failed to update .env with ngrok URL:', error.message);
    process.exitCode = 1;
  });
}

console.log(FLUTTER_ENV_PATH);

module.exports = {
  fetchHttpsTunnel,
  updateEnvFile,
  updateEnvWithUrl,
};
