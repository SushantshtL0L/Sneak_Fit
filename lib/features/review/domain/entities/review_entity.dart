import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String? id;
  final String productId;
  final String userId;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  const ReviewEntity({
    this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, productId, userId, userName, userImage, rating, comment, createdAt];

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'rating': rating,
      'comment': comment,
    };
  }

  factory ReviewEntity.fromJson(Map<String, dynamic> json) {
    return ReviewEntity(
      id: json['_id'],
      productId: json['product'] is Map ? json['product']['_id'] : json['product'],
      userId: json['user'] is Map ? json['user']['_id'] : json['user'],
      userName: json['user'] is Map ? (json['user']['name'] ?? 'User') : 'User',
      userImage: json['user'] is Map ? json['user']['image'] : null,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
