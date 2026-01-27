import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'app_image.dart';
import '../../models/review_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isMe = authProvider.currentUser?.id == review.userId;
    // Simple way to handle likes optimistically
    final isLiked = review.likedBy.contains(authProvider.currentUser?.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: (review.userAvatarUrl.isNotEmpty)
                    ? AppImage(
                        imageUrl: review.userAvatarUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Center(
                        child: Text(
                          review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: AppTheme.warningColor,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (authProvider.currentUser != null) {
                    Provider.of<ReviewProvider>(context, listen: false)
                        .toggleLike(review.attractionId, review.id, authProvider.currentUser!.id);
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isLiked ? AppTheme.errorColor : AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.likes} Likes', // Ideally handle plural
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple formatter, can use intl package
    return '${date.day}/${date.month}/${date.year}';
  }
}
