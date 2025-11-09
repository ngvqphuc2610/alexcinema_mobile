import '../../../data/services/api_exception.dart';

String mapErrorMessage(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  return error.toString();
}
