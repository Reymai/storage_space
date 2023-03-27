class AppSpaceInfo {
  final int appUsedSpace;
  final int cacheSpace;
  final int userDataSpace;
  late int totalAppUsedSpace;

  AppSpaceInfo({
    required this.appUsedSpace,
    required this.cacheSpace,
    required this.userDataSpace,
  }) {
    totalAppUsedSpace = appUsedSpace + cacheSpace + userDataSpace;
  }

  factory AppSpaceInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppSpaceInfo(
      appUsedSpace: map['appUsedSpace'] as int,
      cacheSpace: map['cacheSpace'] as int,
      userDataSpace: map['userDataSpace'] as int,
    );
  }

  @override
  String toString() {
    return 'AppSpaceInfo{appUsed: $appUsedSpace, cacheSpace: $cacheSpace, userDataSpace: $userDataSpace}';
  }
}
