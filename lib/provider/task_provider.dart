import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/server/apis.dart';
import 'package:http/http.dart' as http;

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  Map<int, Map<String, dynamic>> _tasksCounts = {};
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get error => _error;
  Map<int, Map<String, dynamic>> get tasksCounts => _tasksCounts;

  // Fetch tasks from API
  Future<void> fetchTasks(String token, int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Api.get.userTasks(token, userId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final taskList = data['tasks']?['recordset'] as List<dynamic>? ?? [];
        _tasks = taskList.map((e) => TaskModel.fromJson(e)).toList();
        _error = '';

        // Clear previous counts
        _tasksCounts = {};

        // Count tasks per rFStatus and get color/desc from tasks themselves
        for (var task in _tasks) {
          if (task.rFStatus != null) {
            // If we haven't seen this status yet, initialize it
            if (!_tasksCounts.containsKey(task.rFStatus)) {
              _tasksCounts[task.rFStatus!] = {
                'desc': task.rFStatusDesc ?? 'Unknown Status',
                'color': _parseColorFromTask(task), // Get color from task
                'icon': _getIconForStatus(task.rFStatus), // Get appropriate icon
                'count': 0,
              };
            }
            
            // Increment count
            _tasksCounts[task.rFStatus!]!['count'] += 1;
          }
        }

        final message = data['message'] ?? '';
        debugPrint("✅ API Success: $message");
      } else if (response.statusCode == 401) {
        _tasks = [];
        _tasksCounts = {};
        _error = 'Unauthorized - Invalid token';
      } else {
        _tasks = [];
        _tasksCounts = {};
        _error = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      _tasks = [];
      _tasksCounts = {};
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Parse color from task (handles both HEX strings and integer values)
  Color _parseColorFromTask(TaskModel task) {
    try {
      // First try to get color from task's color field (if it's HEX)
      if (task.color != null && task.color!.isNotEmpty) {
        String hex = task.color!.replaceFirst('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      }
      
      // If no color field, fall back to status-based colors
      return _getColorForStatus(task.rFStatus);
    } catch (e) {
      return _getColorForStatus(task.rFStatus); // Fallback to status color
    }
  }

  // Fallback color mapping based on status ID
  Color _getColorForStatus(int? statusId) {
    switch (statusId) {
      case 1: return const Color.fromARGB(255, 117, 4, 83);
      case 2: return const Color(0xFFFAAD14);
      case 3: return const Color(0xFF3A8A13);
      case 4: return Colors.black;
      case 5: return const Color(0xFFF44336);
      case 6: return const Color.fromARGB(255, 195, 21, 218);
      default: return Colors.grey;
    }
  }

  // Get appropriate icon based on status
  IconData _getIconForStatus(int? statusId) {
    switch (statusId) {
      case 1: return Icons.pending;
      case 2: return Icons.receipt;
      case 3: return Icons.done;
      case 4: return Icons.admin_panel_settings;
      case 5: return Icons.block;
      case 6: return Icons.shutter_speed_rounded;
      default: return Icons.task;
    }
  }

  // reload task on refresh
  Future<void> reloadTasks(String token, int userId) async {
    await fetchTasks(token, userId);
  }

  // Get filtered tasks for detailed view
  Future<List<TaskModel>> loadUserSingleFilteredTasks(
    String token,
    int userId,
    String statusFilter,
    int pageNumber,
    int pageSize,
  ) async {
    try {
      final response = await Api.get.userSingleFilteredTasks(
        token,
        userId,
        statusFilter,
        pageNumber,
        pageSize,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> tasksData = data['data'];
          return tasksData.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
        } else {
          throw Exception('API Error: ${data['error']}');
        }
      } else {
        throw Exception('Failed to load tasks. Status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('JSON parsing error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Helper method to get color for UI (if you need it elsewhere)
  Color getStatusColor(TaskModel task) {
    return _parseColorFromTask(task);
  }

  // Helper method to get description for UI
  String getStatusDescription(TaskModel task) {
    return task.rFStatusDesc ?? 'Unknown Status';
  }
}