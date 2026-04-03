import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class CourseProjectItem {
  final String title;
  final String subtitle;
  final Function(BuildContext context, String courseTitle, String projectTitle)?
      onTap;

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
  final Function(BuildContext context)? onTap;

  const CourseCard({
    super.key,
    required this.title,
    required this.progressText,
    required this.progress,
    required this.projects,
    this.initiallyExpanded = false,
    this.leadingIcon = Icons.api_rounded,
    this.width = 330,
    this.onTap,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onTap?.call(context),
        child: AnimatedContainer(
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

              /// 🔥 EXPANSIÓN
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

                    /// 🔥 LISTA DE CATEGORÍAS
                    ...widget.projects.map(
                      (project) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CourseProjectRow(
                          item: project,
                          courseTitle: widget.title,
                        ),
                      ),
                    ),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseProjectRow extends StatelessWidget {
  final CourseProjectItem item;
  final String courseTitle;

  const _CourseProjectRow({required this.item, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => item.onTap?.call(context, courseTitle, item.title),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.grayColor100, width: 1),
            ),
            child: const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
