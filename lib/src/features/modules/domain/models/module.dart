class Module {
  final String moduleId;
  final String moduleName;
  final String moduleDescription;
  final bool moduleIsVisible;
  final String moduleImage; // Assuming String (URL or asset path)
  final bool moduleIsActive;
  final String moduleCreatedAt; // Assuming String for now
  final String styleClass; // Renamed from 'class'
  final String moduleColor;
  final String moduleRoute;
  final String moduleButtonColor;
  final String moduleFontColor;
  final String color; // Potentially redundant with moduleColor
  final int moduleOrder;

  Module({
    required this.moduleId,
    required this.moduleName,
    required this.moduleDescription,
    required this.moduleIsVisible,
    required this.moduleImage,
    required this.moduleIsActive,
    required this.moduleCreatedAt,
    required this.styleClass,
    required this.moduleColor,
    required this.moduleRoute,
    required this.moduleButtonColor,
    required this.moduleFontColor,
    required this.color,
    required this.moduleOrder,
  });

  /// Factory constructor to create a Module instance from a JSON map.
  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      moduleId: json['moduleId'] as String? ?? '', // Handle potential nulls
      moduleName: json['moduleName'] as String? ?? 'Nombre no disponible',
      moduleDescription: json['moduleDescription'] as String? ?? '',
      moduleIsVisible: json['moduleIsVisible'] as bool? ?? false,
      moduleImage: json['moduleImage'] as String? ?? '', // Assuming image path/URL is string
      moduleIsActive: json['moduleIsActive'] as bool? ?? false,
      moduleCreatedAt: json['moduleCreatedAt'] as String? ?? '', // Keep as String for now
      styleClass: json['class'] as String? ?? '', // Use 'class' key from original model
      moduleColor: json['moduleColor'] as String? ?? '#CCCCCC', // Default color
      moduleRoute: json['moduleRoute'] as String? ?? '/', // Default route
      moduleButtonColor: json['moduleButtonColor'] as String? ?? '#CCCCCC',
      moduleFontColor: json['moduleFontColor'] as String? ?? '#000000',
      color: json['color'] as String? ?? '#CCCCCC', // Potentially redundant
      moduleOrder: json['moduleOrder'] as int? ?? 99, // Default order
    );
  }

  // Optional: Add toJson method if needed for sending data back to API
  // Map<String, dynamic> toJson() => {
  //   'moduleId': moduleId,
  //   'moduleName': moduleName,
  //   // ... other fields
  // };
}
