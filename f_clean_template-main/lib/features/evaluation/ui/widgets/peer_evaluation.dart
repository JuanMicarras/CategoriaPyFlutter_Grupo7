import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';

class EditablePeerEvaluationCard extends StatefulWidget {
  final String studentName;
  final String progressText;
  final bool initiallyExpanded;
  final IconData leadingIcon;
  final double width;
  final bool isReadOnly;

  final double? initialPuntualidad;
  final double? initialContribucion;
  final double? initialCompromiso;
  final double? initialActitud;

  final ValueChanged<Map<String, double?>>? onScoresChanged;

  /// ✅ NUEVO
  final bool canExpand;

  const EditablePeerEvaluationCard({
    super.key,
    required this.studentName,
    required this.progressText,
    this.initiallyExpanded = false,
    this.leadingIcon = Icons.person_sharp,
    this.width = 330,
    this.isReadOnly = false,
    this.initialPuntualidad,
    this.initialContribucion,
    this.initialCompromiso,
    this.initialActitud,
    this.onScoresChanged,

    /// ✅ NUEVO (por defecto true)
    this.canExpand = true,
  });

  @override
  State<EditablePeerEvaluationCard> createState() =>
      _EditablePeerEvaluationCardState();
}

class _EditablePeerEvaluationCardState
    extends State<EditablePeerEvaluationCard> {
  late bool _isExpanded;

  double? _puntualidad;
  double? _contribucion;
  double? _compromiso;
  double? _actitud;

  static const List<double> _scoreOptions = [2.0, 3.0, 4.0, 5.0];

  static final Map<String, Map<double, String>> _criteriaDescriptions = {
    'Puntualidad': {
      2.0: 'Llegó tarde a todas las sesiones o se estuvo ausentando constantemente lo cual afectó el trabajo del equipo.',
      3.0: 'Llegó tarde con mucha frecuencia y se ausentó varias veces del trabajo del equipo.',
      4.0: 'En la mayoría de las sesiones llegó puntualmente y no se ausentó con frecuencia.',
      5.0: 'Acudió puntualmente a todas las sesiones de trabajo.',
    },
    'Contribución': {
      2.0: 'En todo momento estuvo como observador y no aportó al trabajo del equipo.',
      3.0: 'En algunas ocasiones participó dentro del equipo y en los intercambios generales.',
      4.0: 'Hizo varios aportes al equipo; sin embargo, puede ser más crítico y propositivo.',
      5.0: 'Sus aportes fueron muy acertados y enriquecieron en todo momento el trabajo del equipo.',
    },
    'Compromiso': {
      2.0: 'Mostró poco compromiso con las tareas y roles asignados tanto por el profesor como por los miembros del equipo.',
      3.0: 'En algunos momentos observamos que su compromiso con el trabajo disminuyó.',
      4.0: 'La mayor parte del tiempo asumió tareas con responsabilidad y compromiso.',
      5.0: 'Mostró en todo momento un compromiso serio con las tareas asignadas.',
    },
    'Actitud': {
      2.0: 'Mantuvo una actitud negativa hacia las actividades del taller.',
      3.0: 'En algunas oportunidades tuvo una actitud abierta y positiva.',
      4.0: 'La mayor parte del tiempo muestra actitud positiva.',
      5.0: 'Su actitud es positiva y demuestra deseos de calidad.',
    },
  };

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _puntualidad = widget.initialPuntualidad;
    _contribucion = widget.initialContribucion;
    _compromiso = widget.initialCompromiso;
    _actitud = widget.initialActitud;
  }

  @override
  void didUpdateWidget(covariant EditablePeerEvaluationCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialPuntualidad != widget.initialPuntualidad ||
        oldWidget.initialContribucion != widget.initialContribucion ||
        oldWidget.initialCompromiso != widget.initialCompromiso ||
        oldWidget.initialActitud != widget.initialActitud) {
      _puntualidad = widget.initialPuntualidad;
      _contribucion = widget.initialContribucion;
      _compromiso = widget.initialCompromiso;
      _actitud = widget.initialActitud;
    }
  }

  /// ✅ SOLO EXPANDE SI canExpand ES TRUE
  void _toggle() {
    if (!widget.canExpand) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _updateScore(String criterion, double value) {
    setState(() {
      switch (criterion) {
        case 'Puntualidad':
          _puntualidad = value;
          break;
        case 'Contribución':
          _contribucion = value;
          break;
        case 'Compromiso':
          _compromiso = value;
          break;
        case 'Actitud':
          _actitud = value;
          break;
      }
    });

    widget.onScoresChanged?.call({
      'puntualidad': _puntualidad,
      'contribucion': _contribucion,
      'compromiso': _compromiso,
      'actitud': _actitud,
    });
  }

  String _descriptionFor(String criterion, double? score) {
    if (score == null) return 'Sin descripción';
    return _criteriaDescriptions[criterion]?[score] ?? 'Sin descripción';
  }

  ({Color background, Color text, Color border}) _tagColors(String value) {
    final normalized = value.toLowerCase().trim();

    if (normalized.contains('completado')) {
      return (
        background: const Color(0xFFF3EDFF),
        text: const Color(0xFF7F56D9),
        border: const Color(0xFFE4D7FF),
      );
    }

    if (normalized.contains('pendiente')) {
      return (
        background: const Color(0xFFF3F4F6),
        text: const Color(0xFF6B7280),
        border: const Color(0xFFE5E7EB),
      );
    }

    if (normalized.contains('cerrada')) {
      return (
        background: const Color(0xFFFDECEC),
        text: Color.fromARGB(255, 193, 95, 95),
        border: const Color(0xFFF6D0D0),
      );
    }

    return (
      background: const Color(0xFFF3F4F6),
      text: const Color(0xFF667085),
      border: const Color(0xFFE5E7EB),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagStyle = _tagColors(widget.progressText);

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
                      style: AppTheme.bodyL.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),

              /// ✅ SOLO MUESTRA FLECHA SI PUEDE EXPANDIR
              if (widget.canExpand)
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

          /// ✅ SOLO MUESTRA CONTENIDO SI PUEDE EXPANDIR
          if (widget.canExpand)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  const SizedBox(height: 18),
                  Divider(color: AppTheme.grayColor100),
                  const SizedBox(height: 16),

                  /// ... TODO LO DEMÁS IGUAL (no lo toqué)
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
