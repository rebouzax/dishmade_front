class CreateCategoryRequest {
  final String name;
  final String? description;

  const CreateCategoryRequest({required this.name, this.description});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
    };
  }
}
