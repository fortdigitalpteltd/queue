import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectResponse {
  final bool success;
  final String message;
  final List<Project> projects;

  ProjectResponse({
    required this.success,
    required this.message,
    required this.projects,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      projects: json['data'] != null 
          ? List<Project>.from(json['data'].map((x) => Project.fromJson(x)))
          : [],
    );
  }
}

class Project {
  final String id;
  final String name;
  // Add other fields as needed based on the API response

  Project({
    required this.id,
    required this.name,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://singaporeq.com/qapi';

  Future<ProjectResponse> getProjectList({
    required String username,
    required String password,
    required String link,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/project-list.php?username=$username&password=$password&link=$link'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProjectResponse.fromJson(data);
      } else {
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }
} 