// 보관함 폴더 아이템 위젯

import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ArchiveFolderItem extends StatefulWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final int? itemCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isNewlyCreated;

  const ArchiveFolderItem({
    super.key,
    required this.name,
    required this.color,
    required this.isSelected,
    this.itemCount,
    required this.onTap,
    this.onLongPress,
    this.isNewlyCreated = false,
  });

  @override
  State<ArchiveFolderItem> createState() => _ArchiveFolderItemState();
}

class _ArchiveFolderItemState extends State<ArchiveFolderItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // 새로 생성된 폴더면 애니메이션 실행
    if (widget.isNewlyCreated) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color.withValues(alpha: 0.1)
                : AppColors.surface,
            border: Border.all(
              color: widget.isSelected ? widget.color : AppColors.border,
              width: widget.isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder,
                color: widget.color,
                size: 32,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Text(
                  widget.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                        color: widget.isSelected ? widget.color : AppColors.textPrimary,
                        fontSize: 12,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              if (widget.itemCount != null && widget.itemCount! > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${widget.itemCount}개',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }
}

