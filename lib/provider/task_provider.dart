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

  // RF Status map with description and color
  Map<int, Map<String, dynamic>> rfStatusMap = {
    1: {
      'desc': 'PENDING',
      'color': Color.fromARGB(255, 117, 4, 83),
      'icon': Icons.pending,
    },
    2: {'desc': 'RECEIVED', 'color': Color(0xFFFAAD14), 'icon': Icons.receipt},
    3: {'desc': 'SUBMITTED', 'color': Color(0xFF3A8A13), 'icon': Icons.done},
    4: {
      'desc': 'APPROVED',
      'color': Color.fromARGB(255, 2, 2, 2),
      'icon': Icons.admin_panel_settings,
    },
    5: {'desc': 'BLOCKED', 'color': Color(0xFFF44336), 'icon': Icons.block},
    6: {
      'desc': 'HOLD',
      'color': Color.fromARGB(255, 195, 21, 218),
      'icon': Icons.shutter_speed_rounded,
    },
  };

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

        // Initialize counts for all rfStatusMap entries with 0
        _tasksCounts = {};
        rfStatusMap.forEach((key, value) {
          _tasksCounts[key] = {
            'desc': value['desc'],
            'color': value['color'],
            'icon': value['icon'], // copy the icon from rfStatusMap
            'count': 0,
          };
        });

        // Count tasks per rFStatus if it exists in rfStatusMap
        for (var task in _tasks) {
          if (rfStatusMap.containsKey(task.rFStatus)) {
            _tasksCounts[task.rFStatus]!['count'] += 1;
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

  // reload task on refresh
  Future<void> reloadTasks(String token, int userId) async {
    await fetchTasks(token, userId);
  }

  // Example call from your Flutter widget
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

          // Convert API response to TaskModel objects
          List<TaskModel> tasks = tasksData.map((taskJson) {
            return TaskModel.fromJson(taskJson);
          }).toList();

          return tasks;
        } else {
          throw Exception('API Error: ${data['error']}');
        }
      } else {
        throw Exception(
          'Failed to load tasks. Status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('JSON parsing error: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
