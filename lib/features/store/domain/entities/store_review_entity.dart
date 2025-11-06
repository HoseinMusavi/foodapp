// lib/features/store/domain/entities/store_review_entity.dart

import 'package:equatable/equatable.dart';

class StoreReviewEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final int rating;
  final String? comment;
  final String customerName;
  final String? customerAvatarUrl;

  const StoreReviewEntity({
    required this.id,
    required this.createdAt,
    required this.rating,
    this.comment,
    required this.customerName,
    this.customerAvatarUrl,
  });

  // متد کمکی برای ساخت از JSON (خروجی RPC)
  factory StoreReviewEntity.fromJson(Map<String, dynamic> json) {
    return StoreReviewEntity(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      customerName: json['customer_name'] as String? ?? 'کاربر ناشناس',
      customerAvatarUrl: json['customer_avatar_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        rating,
        comment,
        customerName,
        customerAvatarUrl,
      ];
}