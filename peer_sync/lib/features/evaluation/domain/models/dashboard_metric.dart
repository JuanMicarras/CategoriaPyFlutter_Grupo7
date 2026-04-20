class DashboardMetric {
  final String title;
  final String value;
  final String? subtitle;

  const DashboardMetric({
    required this.title,
    required this.value,
    this.subtitle,
  });
}
