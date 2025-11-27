import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/datasources/cinema_remote_data_source.dart';
import '../../data/datasources/entertainment_remote_data_source.dart';
import '../../data/datasources/movie_remote_data_source.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/datasources/promotion_remote_data_source.dart';
import '../../data/datasources/screen_remote_data_source.dart';
import '../../data/datasources/screen_type_remote_data_source.dart';
import '../../data/datasources/showtime_remote_data_source.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/cinema_repository.dart';
import '../../data/repositories/entertainment_repository.dart';
import '../../data/datasources/membership_remote_data_source.dart';
import '../../data/repositories/membership_repository.dart';
import '../../domain/services/membership_service.dart';
import '../../presentation/bloc/membership/membership_bloc.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/promotion_repository.dart';
import '../../data/repositories/screen_repository.dart';
import '../../data/repositories/screen_type_repository.dart';
import '../../data/repositories/showtime_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/api_client.dart';
import '../../data/services/token_storage.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/booking_service.dart';
import '../../domain/services/cinema_service.dart';
import '../../domain/services/entertainment_service.dart';
import '../../domain/services/movie_service.dart';
import '../../domain/services/payment_method_service.dart';
import '../../domain/services/payment_service.dart';
import '../../domain/services/product_service.dart';
import '../../domain/services/promotion_service.dart';
import '../../domain/services/screen_service.dart';
import '../../domain/services/screen_type_service.dart';
import '../../domain/services/showtime_service.dart';
import '../../domain/services/user_service.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/cinema/cinema_bloc.dart';
import '../../presentation/bloc/entertainment/entertainment_bloc.dart';
import '../../presentation/bloc/movie/movie_bloc.dart';
import '../../presentation/bloc/payment_method/payment_method_cubit.dart';
import '../../presentation/bloc/payment/payment_cubit.dart';
import '../../presentation/bloc/promotion/promotion_bloc.dart';
import '../../presentation/bloc/screen/screen_bloc.dart';
import '../../presentation/bloc/screen_type/screen_type_bloc.dart';
import '../../presentation/bloc/showtime/showtime_bloc.dart';
import '../../presentation/bloc/two_factor/two_factor_cubit.dart';
import '../../presentation/bloc/user/user_bloc.dart';
import '../../data/datasources/two_factor_remote_data_source.dart';
import '../../data/datasources/payment_method_remote_data_source.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import '../../data/repositories/two_factor_repository.dart';
import '../../data/repositories/payment_method_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../domain/services/two_factor_service.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (!dotenv.isInitialized) {
    try {
      await dotenv.load();
    } catch (_) {
      // Ignore dotenv errors; fall back to defaults.
    }
  }

  _registerExternal();
  _registerDataSources();
  _registerRepositories();
  _registerServices();
  _registerBlocs();
}

void _registerExternal() {
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton<http.Client>(() => http.Client());
  }

  if (!sl.isRegistered<TokenStorage>()) {
    sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  }

  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(baseUrl: _resolveBaseUrl(), httpClient: sl()),
    );
  }
}

void _registerDataSources() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CinemaRemoteDataSource>(
    () => CinemaRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<EntertainmentRemoteDataSource>(
    () => EntertainmentRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<MembershipRemoteDataSource>(
    () => MembershipRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ScreenRemoteDataSource>(
    () => ScreenRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ScreenTypeRemoteDataSource>(
    () => ScreenTypeRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ShowtimeRemoteDataSource>(
    () => ShowtimeRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<TwoFactorRemoteDataSource>(
    () => TwoFactorRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PaymentMethodRemoteDataSource>(
    () => PaymentMethodRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSource(sl()),
  );
}

void _registerRepositories() {
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      apiClient: sl(),
    ),
  );
  sl.registerLazySingleton<BookingRepository>(() => BookingRepository(sl()));
  sl.registerLazySingleton<CinemaRepository>(() => CinemaRepository(sl()));
  sl.registerLazySingleton<EntertainmentRepository>(
    () => EntertainmentRepository(sl()),
  );
  sl.registerLazySingleton<MovieRepository>(() => MovieRepository(sl()));
  sl.registerLazySingleton<ProductRepository>(() => ProductRepository(sl()));
  sl.registerLazySingleton<PromotionRepository>(
    () => PromotionRepository(sl()),
  );
  sl.registerLazySingleton<MembershipRepository>(
    () => MembershipRepository(sl()),
  );
  sl.registerLazySingleton<ScreenRepository>(() => ScreenRepository(sl()));
  sl.registerLazySingleton<ScreenTypeRepository>(
    () => ScreenTypeRepository(sl()),
  );
  sl.registerLazySingleton<ShowtimeRepository>(() => ShowtimeRepository(sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepository(sl()));
  sl.registerLazySingleton<TwoFactorRepository>(
    () => TwoFactorRepository(sl()),
  );
  sl.registerLazySingleton<PaymentMethodRepository>(
    () => PaymentMethodRepository(sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(() => PaymentRepository(sl()));
}

void _registerServices() {
  sl.registerLazySingleton<AuthService>(() => AuthService(sl()));
  sl.registerLazySingleton<BookingService>(() => BookingService(sl()));
  sl.registerLazySingleton<CinemaService>(() => CinemaService(sl()));
  sl.registerLazySingleton<EntertainmentService>(
    () => EntertainmentService(sl()),
  );
  sl.registerLazySingleton<MovieService>(() => MovieService(sl()));
  sl.registerLazySingleton<ProductService>(() => ProductService(sl()));
  sl.registerLazySingleton<PromotionService>(() => PromotionService(sl()));
  sl.registerLazySingleton<MembershipService>(() => MembershipService(sl()));
  sl.registerLazySingleton<ScreenService>(() => ScreenService(sl()));
  sl.registerLazySingleton<ScreenTypeService>(() => ScreenTypeService(sl()));
  sl.registerLazySingleton<ShowtimeService>(() => ShowtimeService(sl()));
  sl.registerLazySingleton<UserService>(() => UserService(sl()));
  sl.registerLazySingleton<TwoFactorService>(() => TwoFactorService(sl()));
  sl.registerLazySingleton<PaymentMethodService>(
    () => PaymentMethodService(sl()),
  );
  sl.registerLazySingleton<PaymentService>(() => PaymentService(sl()));
}

void _registerBlocs() {
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<CinemaBloc>(() => CinemaBloc(sl()));
  sl.registerFactory<EntertainmentBloc>(() => EntertainmentBloc(sl()));
  sl.registerFactory<MovieBloc>(() => MovieBloc(sl()));
  sl.registerFactory<PromotionBloc>(() => PromotionBloc(sl()));
  sl.registerFactory<ScreenBloc>(() => ScreenBloc(sl()));
  sl.registerFactory<ScreenTypeBloc>(() => ScreenTypeBloc(sl()));
  sl.registerFactory<ShowtimeBloc>(() => ShowtimeBloc(sl()));
  sl.registerFactory<UserBloc>(() => UserBloc(sl()));
  sl.registerFactory<TwoFactorCubit>(() => TwoFactorCubit(sl()));
  sl.registerFactory<MembershipBloc>(() => MembershipBloc(sl()));
  sl.registerFactory<PaymentMethodCubit>(() => PaymentMethodCubit(sl()));
  sl.registerFactory<PaymentCubit>(() => PaymentCubit(sl(), sl()));
}

String _resolveBaseUrl() {
  final env = dotenv.isInitialized ? dotenv.env : const <String, String>{};
  final candidates = <String?>[
    env['API_BASE_URL'],
    env['BASE_URL'],
    env['FLUTTER_API_URL'],
  ];

  for (final candidate in candidates) {
    if (candidate != null && candidate.isNotEmpty) {
      return candidate;
    }
  }

  return 'http://localhost:3000/api';
}
