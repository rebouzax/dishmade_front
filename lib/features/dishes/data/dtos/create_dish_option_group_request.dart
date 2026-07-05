class CreateDishOptionGroupRequest {
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;

  const CreateDishOptionGroupRequest({
    required this.name,
    required this.isRequired,
    required this.minSelection,
    required this.maxSelection,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'isRequired': isRequired,
      'minSelection': minSelection,
      'maxSelection': maxSelection,
    };
  }
}
