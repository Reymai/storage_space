class AppSpaceInfo {
  final int appUsedSpace;
  final int cacheSpace;
  final int userDataSpace;
  late final int? totalAppUsedSpace;

  AppSpaceInfo({
    required this.appUsedSpace,
    required this.cacheSpace,
    required this.userDataSpace,
  }) {
    totalAppUsedSpace = appUsedSpace + cacheSpace + userDataSpace;
  }

  factory AppSpaceInfo.fromMap(Map<dynamic, dynamic> map) {
    return AppSpaceInfo(
      appUsedSpace: map['appUsedSpace'] as int? ?? 0,
      cacheSpace: map['cacheSpace'] as int? ?? 0,
      userDataSpace: map['userDataSpace'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appUsedSpace': appUsedSpace,
      'cacheSpace': cacheSpace,
      'userDataSpace': userDataSpace,
    };
  }

  @override
  String toString() {
    return 'AppSpaceInfo{appUsed: $appUsedSpace, cacheSpace: $cacheSpace, userDataSpace: $userDataSpace}';
  }
}
