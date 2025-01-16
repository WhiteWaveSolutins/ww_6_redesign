class Paywall {
  final String productId;
  final String title;
  final String buttonLabel;
  final String subtitle;
  final List<String> benefits;

  Paywall({
    required this.productId,
    required this.title,
    required this.buttonLabel,
    required this.benefits,
    required this.subtitle,
  });

  factory Paywall.fromJson({
    required Map<String, dynamic> data,
    required String productId,
  }) {
    final benefitsData = data['benefits'] as List?;
    final benefits = benefitsData?.map((e)=>e.toString()).toList();
    return Paywall(
      productId: productId,
      title: (data['title'] as String?) ?? 'Unlock all functions',
      subtitle: (data['subtitle'] as String?) ?? 'Get more features with Premium experience!',
      buttonLabel: (data['buttonLabel'] as String?) ?? 'Try Free & Subscribe',
      benefits: benefits ?? <String>[],
    );
  }
}
