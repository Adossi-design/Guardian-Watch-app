abstract final class AppStrings {
  // App
  static const String appName = 'GuardianWatch';
  static const String wakeWord = 'Hey Guardian';

  // Auth
  static const String signIn = 'Sign In';
  static const String signUp = 'Create Account';
  static const String signOut = 'Sign Out';
  static const String email = 'Email address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm password';
  static const String fullName = 'Full name';
  static const String phoneNumber = 'Phone number';
  static const String forgotPassword = 'Forgot password?';
  static const String verificationCode = 'Verification code';
  static const String verifyCode = 'Verify code';
  static const String resendCode = 'Resend code';
  static const String mfaTitle = 'Two-Factor Authentication';
  static const String mfaSubtitle = 'Enter the 6-digit code from your authenticator app';
  static const String biometricPrompt = 'Authenticate to continue';

  // Roles
  static const String rolePrimary = 'Primary User';
  static const String roleMonitor = 'Connected Monitor';
  static const String roleAdmin = 'Administrator';

  // Onboarding
  static const String inviteCode = 'Invite code';
  static const String enterInviteCode = 'Enter invite code';
  static const String generateInvite = 'Generate invite link';
  static const String inviteSent = 'Invitation sent';
  static const String inviteExpiry = 'Expires in 48 hours';

  // Emergency
  static const String fallDetected = 'Fall detected';
  static const String iAmOk = 'I AM OK';
  static const String sosActive = 'SOS ACTIVE';
  static const String sosCancel = 'Cancel SOS';
  static const String emergencyContacts = 'Notifying emergency contacts…';
  static const String callEmergencyServices = 'Call Emergency Services';
  static const String iAmHandlingIt = "I'm handling it";

  // Health
  static const String heartRate = 'Heart Rate';
  static const String heartRateUnit = 'bpm';
  static const String oxygenLevel = 'Oxygen Level';
  static const String oxygenUnit = '%';
  static const String steps = 'Steps';
  static const String sleep = 'Sleep';
  static const String activity = 'Activity';
  static const String lastSeen = 'Last seen';
  static const String normal = 'Normal';
  static const String abnormal = 'Abnormal';

  // Geofencing
  static const String safeZone = 'Safe Zone';
  static const String approachingBoundary = 'You are approaching the edge of your safe zone';
  static const String exitedSafeZone = 'has left the safe zone';
  static const String returnedToSafeZone = 'has returned to the safe zone';

  // Errors
  static const String unknownError = 'An unexpected error occurred. Please try again.';
  static const String networkError = 'No internet connection. Check your connection and try again.';
  static const String authError = 'Authentication failed. Please check your credentials.';
  static const String permissionDenied = 'Permission denied.';

  // General
  static const String loading = 'Loading…';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String skip = 'Skip';
}
