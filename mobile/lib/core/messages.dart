import '../cloud_service.dart';
import '../l10n/generated/app_localizations.dart';

String errorMessage(Object error, AppLocalizations l) {
  if (error is ApiException) {
    return switch (error.status) {
      401 => l.sessionExpired,
      429 => l.quotaError,
      503 => l.notConfigured,
      400 || 413 || 422 => l.invalidRequest,
      502 => l.providerError,
      _ => l.networkError,
    };
  }
  return l.networkError;
}
