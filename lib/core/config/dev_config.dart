
class DevConfig {
  DevConfig._();

  static const bool useFakeAuth = bool.fromEnvironment(
    'DEV_FAKE_AUTH',
    defaultValue: false,
  );


  static const String fakeUserEmail = String.fromEnvironment(
    'DEV_USER_EMAIL',
    defaultValue: 'dev@visionprice.local',
  );

  static const String fakeUserName = String.fromEnvironment(
    'DEV_USER_NAME',
    defaultValue: 'Dev User',
  );

  static const String fakeUserId = String.fromEnvironment(
    'DEV_USER_ID',
    defaultValue: 'dev-user-0001',
  );
}
