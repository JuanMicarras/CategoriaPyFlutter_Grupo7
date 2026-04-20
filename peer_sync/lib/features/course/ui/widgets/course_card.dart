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
  final List<CourseProjectItem> projects;
  final bool initiallyExpanded;
  final IconData leadingIcon;
  final double width;
  final Function(BuildContext context)? onTap;

  const CourseCard({
    super.key,
    required this.title,
    required this.progressText,
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

  bool get _hasProjects => widget.projects.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded && _hasProjects;
  }

  @override
  void didUpdateWidget(covariant CourseCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_hasProjects && _isExpanded) {
      _isExpanded = false;
    }
  }

  void _toggle() {
    if (!_hasProjects) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

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
            color: isLight ? Colors.white : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? const Color(0x2E000000)
                    : const Color(0x1A000000),
                offset: const Offset(0, 2),
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
                    decoration: BoxDecoration(
                      color: isLight
                          ? AppTheme.secondaryColor500
                          : const Color(0xFF3F2A6B),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.leadingIcon,
                      color: isLight
                          ? AppTheme.primaryColor
                          : const Color(0xFFD1C4FF),
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
                            color: isLight
                                ? AppTheme.textColor
                                : AppTheme.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.progressText,
                          style: AppTheme.bodyS.copyWith(
                            color: isLight
                                ? AppTheme.grayColor100
                                : AppTheme.darkTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_hasProjects)
                    GestureDetector(
                      onTap: _toggle,
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: isLight
                            ? Colors.black87
                            : AppTheme.darkTextPrimary,
                      ),
                    ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: _isExpanded && _hasProjects
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: () => item.onTap?.call(context, courseTitle, item.title),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTheme.bodyM.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isLight
                        ? AppTheme.textColor
                        : AppTheme.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: AppTheme.bodyS.copyWith(
                    color: isLight
                        ? AppTheme.grayColor100
                        : AppTheme.darkTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isLight ? AppTheme.grayColor100 : AppTheme.darkBorder,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: isLight ? const Color(0xFF9CA3AF) : AppTheme.darkTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
