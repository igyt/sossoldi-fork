/// Web OAuth client ID from Google Cloud Console.
///
/// Create a *Web application* OAuth client (not only the Android one) and
/// paste its client ID here, or pass `--dart-define=GOOGLE_OAUTH_WEB_CLIENT_ID=...`
/// when building. Android still needs a separate Android OAuth client whose
/// package is `com.bltr.sossoldi` and whose SHA-1 matches your keystore.
const String kGoogleOAuthWebClientId = String.fromEnvironment(
  'GOOGLE_OAUTH_WEB_CLIENT_ID',
  defaultValue: '',
);

class DriveOAuthConfig {
  static String get webClientId => kGoogleOAuthWebClientId;

  static bool get isConfigured => webClientId.isNotEmpty;
}
