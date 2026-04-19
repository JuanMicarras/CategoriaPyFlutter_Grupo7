# <img width="5%" alt="logo-removebg-preview" src="https://github.com/user-attachments/assets/2ea73b6a-b107-451e-90c9-b0aed4f233c3" /> PeerSync: Structured Peer Assessment App
Aplicación móvil desarrollada en **Flutter** que permite la coevaluación estructurada entre pares en entornos académicos colaborativos, facilitando el análisis del desempeño individual dentro de trabajos en grupo mediante métricas claras y visualizaciones intuitivas.

<br>

## 👩‍💻 Equipo de Desarrollo
**Equipo #7**
* Juan Miguel Carrasquilla Escobar ( [jmcarrasquilla@uninorte.edu.co](mailto:jmcarrasquilla@uninorte.edu.co) )
* Elvira Elena Florez Carbonell ( [elviraf@uninorte.edu.co](mailto:elviraf@uninorte.edu.co) )
* Keiver De Jesus Miranda Lemus ( [mkeiver@uninorte.edu.co](mailto:mkeiver@uninorte.edu.co) )
* Alejandra Valencia Rua ( [alejandrarua@uninorte.edu.co](mailto:alejandrarua@uninorte.edu.co) )

<br>

## 📋 Tabla de Contenidos
1. [Descripción de la Aplicación](#descripción-de-la-aplicación)
   * [Propósito del Proyecto](#propósito-del-proyecto)
   * [Objetivos](#objetivos)
   * [Funcionalidades Principales](#funcionalidades-principales)
   * [Roles del Sistema](#roles-del-sistema)
   * [Tecnologías Utilizadas](#tecnologías-utilizadas)
   * [Alcance](#alcance)
2. [Demos de la Aplicación](#demos-de-la-aplicación)
3. [Instalación](#instalación)
4. [Estructura del proyecto](#estructura_del_proyecto)
5. [¿Cómo surge PeerSync?](#cómo-surge-peersync)
   * [Referentes y Análisis del Contexto Actual](#referentes-y-análisis-del-contexto-actual)
6. [Referencias](#referencias)


<br>

## 📌 Descripción de la Aplicación

### ✍🏼 Propósito del Proyecto
PeerSync tiene como propósito **transformar** los procesos tradicionales de evaluación en trabajos grupales, permitiendo que los estudiantes participen activamente en la valoración del desempeño de sus compañeros. La aplicación busca mejorar la equidad, transparencia y retroalimentación continua en contextos educativos universitarios.

<br>

### 🎯 Objetivos
**Objetivo General:** 

Desarrollar una aplicación móvil que permita a estudiantes evaluar el desempeño y compromiso de sus compañeros en actividades grupales, mediante un sistema de coevaluación estructurado que proporcione métricas claras y visualizaciones detalladas para docentes y estudiantes.

**Objetivos Específicos:**
* Diseñar un sistema de gestión de cursos que permita la creación y administración de espacios académicos colaborativos.
* Implementar la importación de grupos de trabajo a partir de información estructurada extraída de Brightspace.
* Desarrollar un módulo de evaluaciones configurables que permita definir criterios, ventanas de tiempo y reglas de visibilidad.
* Implementar un sistema de coevaluación entre pares que evite la autoevaluación y garantice la integridad de los datos.
* Desarrollar algoritmos para el cálculo automático de métricas de desempeño individual y grupal.
* Diseñar visualizaciones gráficas que faciliten la interpretación de resultados para docentes y estudiantes. 

<br>

### ⚙️ Funcionalidades Principales
* Autenticación de usuarios (login y registro)
* Gestión de cursos (creación y unión mediante código)
* Importación de grupos (archivos csv generados desde Brightspace)
* Creación de evaluaciones (assessments) con criterios definidos
* Evaluación entre pares sin autoevaluación
* Control de ventana de tiempo para evaluaciones
* Configuración de visibilidad (resultados públicos o privados)
* Visualización de resultados mediante gráficas
* Cálculo automático de métricas de desempeño

<br>

### 👥 Roles del Sistema

La aplicación contempla dos tipos de usuarios:

**👩‍🏫 Teacher**
- Crear y gestionar cursos
- Invitar estudiantes
- Importar categorías de grupos desde Brightspace
- Crear evaluaciones
- Configurar visibilidad de evaluaciones
- Visualizar métricas globales y detalladas

**👨‍🎓 Student**
- Unirse a cursos
- Visualizar sus grupos
- Evaluar a sus compañeros
- Consultar resultados (si la evaluación es pública)

<br>

### 📱 Tecnologías Utilizadas
- Flutter
- Roble (Authentication & Storage)
- Brightspace (Importación de grupos)

<br>

### 📏 Alcance
PeerSync permite gestionar el proceso completo de coevaluación en actividades académicas grupales dentro de un entorno móvil. La aplicación cubre desde la creación de cursos y configuración de evaluaciones, hasta la recolección de respuestas, cálculo automático de métricas y visualización de resultados diferenciados por rol (docente y estudiante).

El sistema incluye control de acceso mediante códigos de curso, definición de ventanas de tiempo para las evaluaciones y configuración de visibilidad de resultados. Además, contempla la importación de grupos a partir de archivos externos como csv que incluyen la información de Brightspace.

La solución está diseñada para contextos universitarios y soporta múltiples cursos, usuarios y evaluaciones de manera concurrente.

<br>

## 🎥 Demos de la Aplicación

A continuación se presentan demostraciones funcionales del sistema:

### 🔐 Gestión Académica
https://youtube.com/

### 📝 Evaluación y Reportes
https://youtube.com/

### 🧩 Pruebas de Widget
https://youtube.com/

### 📈 Pruebas de Integración
https://youtube.com/

### 💾 Implementación de Caché
https://youtube.com/

### 🗃️ Revisión del código (Arquitectura Limpia)
https://youtube.com/

<br>

## ⚙️ Instalación

Sigue estos pasos para ejecutar el proyecto localmente:

```bash
# Clonar repositorio
git clone https://github.com/JuanMicarras/CategoriaPyFlutter_Grupo7.git
# Entrar al proyecto
cd peersync

# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run
```

<br>

## 🧱 Estructura del Proyecto
La aplicación sigue principios de **Clean Architecture**, separando responsabilidades en capas.

```bash
lib/
│
├── core/
│ ├── themes/
│ ├── utils/
│ └── widgets/
│
├── features/
│ ├── auth/
│ │ ├── data/
│ │ ├── domain/
│ │ │ ├── models/
│ │ │ └── repositories/
│ │ └── ui/
│ │ │ ├── bindings/
│ │ │ ├── viewmodels/
│ │ │ ├── views/
│ │ │ └── widgets/
│ │ 
│ ├── category/
│ │ ├── data/
│ │ ├── domain/
│ │ │ ├── models/
│ │ │ └── repositories/
│ │ └── ui/
│ │ │ ├── bindings/
│ │ │ ├── viewmodels/
│ │ │ ├── views/
│ │ │ └── widgets/
│ │
│ ├── course/...
│ ├── evaluation/...
│ ├── groups/...
│ ├── notifications/...
│ ├── student/...
│ └── teacher/...
│
└── 
```

La aplicación utiliza un enfoque **feature-first**, donde cada módulo (auth, course, evaluation, etc.) contiene sus propias capas internas. Esto permite:
- Alta escalabilidad
- Separación clara de responsabilidades
- Mantenibilidad del código
- Desarrollo modular por funcionalidades

<br>

## 💡 ¿Cómo surge PeerSync?
En la educación universitaria, el trabajo colaborativo constituye una estrategia pedagógica clave para el desarrollo de competencias técnicas, sociales y profesionales. Sin embargo, los modelos tradicionales de evaluación en el aula suelen basarse principalmente en calificaciones asignadas exclusivamente por el docente, lo que limita la participación activa del estudiante y no siempre permite capturar de manera precisa el desempeño individual dentro de actividades grupales. Este enfoque centrado únicamente en la evaluación docente puede generar percepciones de inequidad cuando la nota final de un proyecto colaborativo no refleja el aporte real de cada integrante del equipo. Además, la concentración de la evaluación en momentos específicos del curso (como entregas finales o exámenes) incrementa la presión académica y reduce las oportunidades de retroalimentación continua.
De acuerdo con Moreno Pabón (2023), los procesos evaluativos en la educación superior deben evolucionar hacia modelos más dinámicos y participativos que fomenten la responsabilidad, la reflexión crítica y la transparencia en el aprendizaje. La autora resalta la importancia de integrar prácticas que permitan observar el progreso del estudiante y fortalecer su implicación activa en los procesos formativos.

En la misma línea, Basurto-Mendoza et al. (2021) sostienen que las prácticas de coevaluación constituyen enfoques innovadores dentro de la práctica pedagógica, ya que favorecen la identificación de vacíos de conocimiento, incrementan la motivación y promueven el desarrollo de habilidades críticas. Asimismo, estas metodologías proporcionan a los docentes información más auténtica sobre el progreso real de los estudiantes en contextos colaborativos Esta fragmentación tecnológica limita la posibilidad de implementar procesos de retroalimentación continua y análisis comparativo del desempeño.

En este contexto, se identifica la necesidad de desarrollar una solución tecnológica que permita formalizar la evaluación colaborativa mediante una aplicación móvil estructurada. De esta manera, **PeerSync** surge como respuesta a estas limitaciones, para transformar los procesos tradicionales de evaluación en entornos universitarios, integrando fundamentos pedagógicos contemporáneos con una solución tecnológica estructurada y sostenible.

<br>

### 🔍 Referentes y Análisis del Contexto Actual
Con el fin de fundamentar la propuesta, se realizaron reuniones con profesores del Departamento de Ingeniería de Sistemas de la Universidad del Norte, quienes implementan actividades colaborativas dentro de sus cursos y utilizan distintos mecanismos para evaluar el desempeño individual en trabajos grupales.

A partir de estas entrevistas, se identificaron las siguientes herramientas actualmente utilizadas en procesos de coevaluación:

[![FeedbackFruits](https://img.shields.io/badge/FeedbackFruits--purple)](http://feedbackfruits.com/rubrics/evaluate-contributions-to-teamwork)

FeedbackFruits es una plataforma integrada comúnmente en sistemas LMS que permite implementar dinámicas de retroalimentación entre pares.

**Ventajas identificadas:**
- Permite evaluación estructurada por criterios.
- Facilita la asignación de retroalimentación entre estudiantes.
- Ofrece cierto nivel de automatización en la recopilación de respuestas.

**Limitaciones observadas:**
- Dependencia del LMS institucional (como Brisghtspace).
- Interfaz no siempre optimizada para dispositivos móviles.
- Configuración avanzada puede resultar compleja.
- Visualización de métricas no siempre personalizada por curso o actividad.

[![Google / Microsoft Forms](https://img.shields.io/badge/Google%20Forms%20/%20Microsoft%20Forms--purple)]()

Según los docentes consultados, una de las prácticas más frecuentes es la creación de formularios personalizados con escalas estimativas (por ejemplo, de 1 a 5) para que los estudiantes evalúen a sus compañeros.

**Ventajas:**
- Fácil creación y distribución.
- Accesibilidad multiplataforma.
- Flexibilidad en la definición de preguntas.

**Limitaciones:**
- Consolidación manual o semiautomática de resultados.
- Ausencia de trazabilidad histórica integrada.
- No existe diferenciación estructurada por rol.
- No hay cálculo automático de métricas por grupo, curso o estudiante.
- No se integran ventanas de tiempo controladas desde la lógica del sistema.  

<br>

Además de las herramientas mencionadas por los docentes consultados, se realizó una revisión exploratoria de soluciones implementadas en contextos universitarios a nivel internacional. Esta búsqueda permitió identificar plataformas especializadas en la evaluación del trabajo en equipo que cuentan con respaldo académico y uso documentado en instituciones de educación superior. A continuación, se presentan dos referentes adicionales relevantes para el análisis comparativo de la propuesta.

[![CATME](https://img.shields.io/badge/CATME--purple)](https://info.catme.org/features/peer-evaluation/)

CATME (Comprehensive Assessment for Team-Member Effectiveness) es una herramienta ampliamente utilizada en educación superior para evaluar la efectividad de los miembros en equipos de trabajo, desorrallad por por un equipo de investigadores, destacando Matthew W. Ohland, Misty L. Loughry, y Richard A. Layton, con apoyo de la National Science Foundation (NSF) y la Universidad de Purdue.

**Ventajas:**
- Sistema validado académicamente.
- Evaluación por múltiples dimensiones de desempeño.
- Reportes estructurados para docentes.

**Limitaciones:**
- Plataforma externa con suscripciones institucionales.
- Menor flexibilidad para personalización específica del curso.
- No siempre integrada a flujos académicos internos.
- Interfaz menos intuitiva para uso móvil continuo.


[![Moodle](https://img.shields.io/badge/Moodle%20Workshop%20Module--purple)](https://youtu.be/witnwTevtAk?si=b094PRJXUPdGb_52)

El módulo Workshop de Moodle permite implementar procesos de evaluación entre pares dentro del entorno LMS.

**Ventajas:**
- Integración directa con cursos existentes.
- Gestión automática de asignaciones de evaluación.
- Configuración de rúbricas estructuradas.

**Limitaciones:**
- Curva de configuración compleja.
- Experiencia de usuario poco optimizada para móviles.
- Interfaz centrada en entorno web.
- Visualización analítica limitada en comparación con herramientas especializadas.

<br>

**Hallazgos Generales:**

A partir del análisis de estas herramientas y de las entrevistas con docentes, se identifican patrones comunes:

- La mayoría de soluciones no están diseñadas específicamente como aplicaciones móviles nativas.
- La visualización de métricas suele ser limitada o requiere exportación manual de datos.
- No existe una integración clara entre creación de curso, gestión de grupos, generación de actividades y análisis estadístico en una sola herramienta ligera.
- Las soluciones actuales priorizan la recopilación de datos, pero no siempre la visualización analítica estructurada y diferenciada por rol.

<br>

## 📖 Referencias

* Basurto-Mendoza, S. T., Moreira-Cedeño, J. A., Velásquez-Espinales, A. N., & Rodríguez, M. (2021). Autoevaluación, coevaluación y heteroevaluación como enfoque innovador en la práctica pedagógica y su efecto en el proceso de enseñanza-aprendizaje.

* Moreno Pabón, C. (2023). Importancia de la evaluación, coevaluación y autoevaluación en la educación universitaria: Experiencias en la Educación Artística. HUMAN Review, 2023(2), 1–12. 

* Ohland, M. W., Loughry, M. L., Woehr, D. J., Bullard, L. G., Felder, R. M., Finelli, C. J., Layton, R. A., Pomeranz, H. R., & Schmucker, D. G. (2012). The comprehensive assessment of team member effectiveness: Development of a behaviorally anchored rating scale for self- and peer evaluation. Academy of Management Learning & Education, 11(4), 609–630. https://doi.org/10.5465/amle.2010.0177
