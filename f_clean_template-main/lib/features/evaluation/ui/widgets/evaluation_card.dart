import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class PeerEvaluationData {
  final String subtitle;
  final String score;

  const PeerEvaluationData({required this.subtitle, required this.score});
}

class PeerEvaluationCard extends StatefulWidget {
  final String studentName;
  final String progressText;
  final bool initiallyExpanded;
  final IconData leadingIcon;
  final double width;
  final PeerEvaluationData puntualidad;
  final PeerEvaluationData contribucion;
  final PeerEvaluationData compromiso;
  final PeerEvaluationData actitud;
  final PeerEvaluationData general;

  final bool canExpand; // ✅ NUEVO

  const PeerEvaluationCard({
    super.key,
    required this.studentName,
    required this.progressText,
    required this.puntualidad,
    required this.contribucion,
    required this.compromiso,
    required this.actitud,
    required this.general,
    this.initiallyExpanded = false,
    this.leadingIcon = Icons.person_sharp,
    this.width = 330,
    this.canExpand = true, // ✅ NUEVO
  });

  @override
  State<PeerEvaluationCard> createState() => _PeerEvaluationCardState();
}

class _PeerEvaluationCardState extends State<PeerEvaluationCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggle() {
    if (!widget.canExpand) return; // 🔒 bloqueo

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
                      widget.studentName,
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
                  ],
                ),
              ),

              /// 🔽 ICONO CONTROLADO POR visibility
              GestureDetector(
                onTap: widget.canExpand ? _toggle : null,
                child: widget.canExpand
                    ? Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppTheme.textColor,
                      )
                    : const Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
              ),
            ],
          ),

          /// CONTENIDO
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: (_isExpanded && widget.canExpand)
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const SizedBox(height: 18),
                Divider(color: AppTheme.grayColor100),
                const SizedBox(height: 16),
                _EvaluationRow(
                  title: 'Puntualidad',
                  subtitle: widget.puntualidad.subtitle,
                  score: widget.puntualidad.score,
                ),
                const SizedBox(height: 18),
                _EvaluationRow(
                  title: 'Contribución',
                  subtitle: widget.contribucion.subtitle,
                  score: widget.contribucion.score,
                ),
                const SizedBox(height: 18),
                _EvaluationRow(
                  title: 'Compromiso',
                  subtitle: widget.compromiso.subtitle,
                  score: widget.compromiso.score,
                ),
                const SizedBox(height: 18),
                _EvaluationRow(
                  title: 'Actitud',
                  subtitle: widget.actitud.subtitle,
                  score: widget.actitud.score,
                ),
                const SizedBox(height: 18),
                Divider(color: AppTheme.grayColor100),
                const SizedBox(height: 18),
                _EvaluationRow(
                  title: 'General',
                  subtitle: widget.general.subtitle,
                  score: widget.general.score,
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

class _EvaluationRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String score;

  const _EvaluationRow({
    required this.title,
    required this.subtitle,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyL.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.bodyS.copyWith(color: const Color(0xFF718096)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.grayColor100, width: 1),
          ),
          child: Text(
            score,
            style: AppTheme.bodyM.copyWith(
              color: const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
