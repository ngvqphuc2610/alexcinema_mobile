import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/biometric_service.dart';
import '../../data/models/dto/auth_request_dto.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/common/bloc_status.dart';
import '../widgets/BiometricLoginButton.dart';
import '../widgets/buttons/btnRegisLogin.dart';
import 'forgotpassword_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _twoFactorController = TextEditingController();

  bool _submitting = false;
  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  List<BiometricAccount> _biometricAccounts = const [];
  bool _useBackupCode = false;

  @override
  void initState() {
    super.initState();
    _loadBiometric();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _twoFactorController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometric() async {
    final available = await BiometricAuth.canAuthenticate();
    final accounts = available ? await BiometricAuth.getAccounts() : <BiometricAccount>[];
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricAccounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.requires2FA != current.requires2FA,
          listener: (context, state) async {
            if (!_submitting) return;
            if (state.status.isFailure) {
              setState(() => _submitting = false);
              final message = state.errorMessage ?? 'Dang nhap that bai.';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
            } else if (state.status.isSuccess &&
                state.requires2FA &&
                state.sessionToken != null) {
              setState(() => _submitting = false);
              await _show2FADialog(state.sessionToken!);
            } else if (state.status.isSuccess && state.isAuthenticated) {
              if (_biometricAvailable &&
                  _usernameController.text.isNotEmpty &&
                  _passwordController.text.isNotEmpty) {
                final userId = state.user?.id.toString() ?? _usernameController.text.trim();
                await BiometricAuth.saveAccount(
                  BiometricAccount(
                    userId: userId,
                    email: _usernameController.text.trim(),
                    password: _passwordController.text.trim(),
                    fullName: state.user?.fullName ?? '',
                    role: state.user?.role ?? '',
                  ),
                );
                await BiometricAuth.setEnabled(userId, true);
                await _loadBiometric();
              }
              setState(() => _submitting = false);
              Navigator.of(context).pop();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dang nhap',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dang nhap bang tai khoan hoac email cua ban',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  if (_biometricAvailable) ...[
                    const SizedBox(height: 18),
                    BiometricLoginButton(
                      enabled: _biometricAccounts.isNotEmpty && !_submitting,
                      onPressed: _biometricAccounts.isNotEmpty && !_submitting
                          ? _loginWithBiometric
                          : null,
                      helperText: _biometricAccounts.isNotEmpty
                          ? 'Dang nhap nhanh bang van tay / Face ID.'
                          : 'Bat dang nhap sinh trac trong trang Tai khoan.',
                    ),
                  ],
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      context,
                      label: 'Tai khoan hoac Email',
                      hint: 'Nhap tai khoan hoac email cua ban',
                      icon: Icons.mail_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui long nhap tai khoan hoac email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      context,
                      label: 'Mat khau',
                      hint: 'Nhap mat khau',
                      icon: _obscurePassword ? Icons.lock_outline : Icons.lock_open,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui long nhap mat khau';
                      }
                      if (value.length < 6) {
                        return 'Mat khau phai co it nhat 6 ky tu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  RegisLoginButton(
                    label: _submitting ? 'Dang xu ly...' : 'Dang nhap',
                    onPressed: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _submitting ? null : () => _openForgotPassword(context),
                        child: const Text('Quen mat khau?'),
                      ),
                      Text(
                        '/',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black45),
                      ),
                      TextButton(
                        onPressed: _submitting ? null : () => _openRegister(context),
                        child: const Text('Tao tai khoan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginWithBiometric() async {
    if (_biometricAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chua co thong tin dang nhap dang van tay.')),
      );
      return;
    }
    final account = await _pickAccount();
    if (account == null) return;

    _usernameController.text = account.email;
    _passwordController.text = account.password;

    final approved = await BiometricAuth.authenticate(
      reason: 'Xac thuc de dang nhap bang van tay',
    );
    if (!approved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xac thuc sinh trac khong thanh cong.')),
      );
      return;
    }
    setState(() => _submitting = true);
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        LoginRequestDto(
          usernameOrEmail: account.email,
          password: account.password,
        ),
      ),
    );
  }

  Future<void> _show2FADialog(String sessionToken) async {
    _twoFactorController.clear();
    bool useBackup = _useBackupCode;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            final hasCode = _twoFactorController.text.trim().isNotEmpty;
            return AlertDialog(
              title: Text(useBackup ? 'Ma du phong' : 'Xac thuc 2FA'),
              content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  useBackup
                      ? 'Nhap ma du phong (backup code) cua ban.'
                      : 'Nhap ma xac thuc tu ung dung Authenticator.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _twoFactorController,
                  decoration: InputDecoration(
                    labelText: useBackup ? 'Ma du phong' : 'Ma 2FA',
                    hintText: useBackup ? 'ABCD-1234' : '000000',
                    border: const OutlineInputBorder(),
                    helperText: useBackup
                        ? 'Ma gom chu/so, khong gioi han 6 ky tu.'
                        : 'Ma 6 chu so tu app Authenticator.',
                  ),
                  keyboardType: useBackup ? TextInputType.text : TextInputType.number,
                  maxLength: useBackup ? null : 6,
                  autofocus: true,
                  onChanged: (_) => setDialogState(() {}),
                  textCapitalization:
                      useBackup ? TextCapitalization.characters : TextCapitalization.none,
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      useBackup = !useBackup;
                      _useBackupCode = useBackup;
                      _twoFactorController.clear();
                    });
                  },
                  child: Text(
                    useBackup
                        ? 'Dung ma 2FA thay vi backup code'
                        : 'Dung ma du phong thay vi ma 2FA',
                  ),
                ),
              ],
            ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Huy'),
                ),
                ElevatedButton(
                  onPressed: hasCode
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  child: const Text('Xac nhan'),
                ),
              ],
            );
        },
      ),
    );

    if (result == true && mounted) {
      setState(() => _submitting = true);
      final code = useBackup
          ? _twoFactorController.text.trim().toUpperCase()
          : _twoFactorController.text.trim();
      context.read<AuthBloc>().add(
        Auth2FARequested(
          sessionToken: sessionToken,
          token: code,
          usernameOrEmail: _usernameController.text.trim(),
        ),
      );
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        LoginRequestDto(
          usernameOrEmail: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  Future<void> _openRegister(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  Future<BiometricAccount?> _pickAccount() async {
    if (_biometricAccounts.length == 1) return _biometricAccounts.first;
    return showModalBottomSheet<BiometricAccount>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Chon tai khoan dang nhap',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              for (final acc in _biometricAccounts)
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: Text(acc.email),
                  subtitle: Text(acc.fullName.isNotEmpty ? acc.fullName : acc.role),
                  onTap: () => Navigator.of(context).pop(acc),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openForgotPassword(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context, {
  required String label,
  required String hint,
  IconData? icon,
}) {
  final theme = Theme.of(context);
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: color, width: 1.2),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    suffixIcon: icon != null ? Icon(icon, color: Colors.grey.shade600) : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: border(Colors.black12),
    enabledBorder: border(Colors.black26),
    focusedBorder: border(theme.primaryColor),
  );
}
