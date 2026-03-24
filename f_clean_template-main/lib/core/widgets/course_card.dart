import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class CourseProjectItem {
  final String title;
  final String subtitle;
  final Function(BuildContext context, String courseTitle, String projectTitle)? onTap;

  const CourseProjectItem({
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class CourseCard extends StatefulWidget {
  final String title;
  final String progressText;
  final double progress;
  final List<CourseProjectItem> projects;
  final bool initiallyExpanded;
  final IconData leadingIcon;
  final double width;

  const CourseCard({
    super.key,
    required this.title,
    required this.progressText,
    required this.progress,
    required this.projects,
    this.initiallyExpanded = false,
    this.leadingIcon = Icons.api_rounded,
    this.width = 330,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: widget.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppTheme.secondaryColor500,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.leadingIcon,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.bodyL.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.progressText,
                      style: AppTheme.bodyS.copyWith(
                        color: AppTheme.grayColor100,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: widget.progress.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: AppTheme.grayColor100,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.secondaryColor100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _toggle,
                child: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 16),

                ...widget.projects.map(
                  (project) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CourseProjectRow(
                      item: project,
                      courseTitle: widget.title, // 🔥 dinámico
                    ),
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CourseProjectRow extends StatelessWidget {
  final CourseProjectItem item;
  final String courseTitle;

  const _CourseProjectRow({
    required this.item,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => item.onTap?.call(
        context,
        courseTitle,
        item.title, // 🔥 también dinámico
      ),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title),
                Text(item.subtitle),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
