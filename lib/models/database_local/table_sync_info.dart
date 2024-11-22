class TableSyncInfo{
  final String tableName;
  final String? lastLocalUpdate;
  final String? lastRemoteSync;

  const TableSyncInfo({
    required this.tableName,
    this.lastLocalUpdate,
    this.lastRemoteSync
  });

  factory TableSyncInfo.fromJson(Map<String, dynamic> json) => TableSyncInfo(
      tableName: json['tableName'],
      lastLocalUpdate: json['lastLocalUpdate'],
      lastRemoteSync: json['lastRemoteSync']
  );

  TableSyncInfo copyWith({
    String? tableName,
    String? lastLocalUpdate,
    String? lastRemoteSync,
  }){
    return TableSyncInfo(
      tableName: tableName ?? this.tableName,
      lastLocalUpdate: lastLocalUpdate ?? this.lastLocalUpdate,
      lastRemoteSync: lastRemoteSync ?? this.lastRemoteSync
    );
  }

  Map<String, dynamic> toJson() => {
    'tableName': tableName,
    'lastLocalUpdate': lastLocalUpdate,
    'lastRemoteSync': lastRemoteSync
  };
}