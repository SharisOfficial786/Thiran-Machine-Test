/// class for handling the SQFLite db data
class DetailsDbModel {
  final int? id;
  final String? nodeId;
  final String? name;
  final String? fullName;
  final String? avatarUrl;

  DetailsDbModel({
    this.id,
    this.nodeId,
    this.name,
    this.fullName,
    this.avatarUrl,

  });

  factory DetailsDbModel.fromJson(Map<String, dynamic> json) => DetailsDbModel(
        id: json["id"],
        nodeId: json["node_id"],
        name: json["name"],
        fullName: json["full_name"],
        avatarUrl: json["avatar_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "node_id": nodeId,
        "name": name,
        "full_name": fullName,
        "avatar_url": avatarUrl,
      };
}
