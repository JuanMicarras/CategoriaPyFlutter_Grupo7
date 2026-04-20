class StudentReport {
  final String email;
  final String firstName;
  final String lastName;
  final int evaluationsGiven; // Cuántas evaluaciones ha hecho
  final int evaluationsReceived; // Cuántas le han hecho
  final double finalGrade; // Su nota promedio actual
  final bool isComplete; // ¿Ya evaluó a todos sus compañeros?

  StudentReport({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.evaluationsGiven,
    required this.evaluationsReceived,
    required this.finalGrade,
    required this.isComplete,
  });
}

class GroupReport {
  final String groupId;
  final String groupName;
  final List<StudentReport> students;

  GroupReport({
    required this.groupId,
    required this.groupName,
    required this.students,
  });
}