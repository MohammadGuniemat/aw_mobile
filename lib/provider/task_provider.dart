import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aw_app/models/taskModel.dart';
import 'package:aw_app/models/taskConfigModel.dart';
import 'package:aw_app/server/apis.dart';
import 'package:http/http.dart' as http;

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  List<TaskModel> DetailedTasks = [];
  List<TaskConfigModel> _tasksConfigs = [];
  Map<int, Map<String, dynamic>> _tasksCounts = {};
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get error => _error;
  Map<int, Map<String, dynamic>> get tasksCounts => _tasksCounts;

  /// Fetch RF status configs (color, description)
  Future<void> getColorWithStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Api.get.getColorsAndTxtStatus();
      print('Raw API Response: ${response.body}');

      final data = jsonDecode(response.body);
      print('Decoded ColorStatusData: $data');

      if (response.statusCode == 200) {
        final _tasksConfigsList = data as List<dynamic>? ?? [];
        _tasksConfigs = _tasksConfigsList
            .map((e) => TaskConfigModel.fromJson(e))
            .toList();

        // Log readable info for each task config
        for (var cfg in _tasksConfigs) {
          print(
            'rFStatusID: ${cfg.rFStatusID}, statusDesc: ${cfg.statusDesc}, color: ${cfg.color}',
          );
        }

        _error = '';
      } else {
        _tasksConfigs = [];
        _error = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      _tasksConfigs = [];
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch tasks for a user
  Future<void> fetchTasks(String token, int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Api.get.userTasks(token, userId);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final taskList = data['tasks']?['recordset'] as List<dynamic>? ?? [];
        _tasks = taskList.map((e) => TaskModel.fromJson(e)).toList();

        // Print each task to the console
        for (var task in _tasks) {
          print(
            'taskQ ${task}',
          ); // Make sure TaskModel has a meaningful toString() method
        }

        _error = '';

        // Initialize counts for all RF statuses from _tasksConfigs (API)
        _tasksCounts = {};
        for (var cfg in _tasksConfigs) {
          _tasksCounts[cfg.rFStatusID] = {
            'desc': cfg.statusDesc,
            'color': _hexToColor(cfg.color),
            'icon': _getIconForStatus(cfg.rFStatusID),
            'count': 0,
          };
        }

        // Count tasks per status and map color/desc to tasks
        for (var task in _tasks) {
          final statusId = task.rFStatus ?? 0;

          // Increment count
          if (_tasksCounts.containsKey(statusId)) {
            _tasksCounts[statusId]!['count'] += 1;
          } else {
            _tasksCounts[statusId] = {
              'desc': task.statusDesc ?? 'N/A',
              'color': Colors.grey,
              'icon': Icons.task,
              'count': 1,
            };
          }

          // Map color and description to task
          final cfg = _tasksConfigs.firstWhere(
            (c) => c.rFStatusID == statusId,
            orElse: () => TaskConfigModel(
              rFStatusID: statusId,
              statusDesc: 'N/A',
              color: '#000000',
            ),
          );
          task.statusDesc = cfg.statusDesc;
          task.color = cfg.color;
        }

        debugPrint("✅ Tasks fetched successfully. Total: ${_tasks.length}");
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

  // Reload tasks
  Future<void> reloadTasks(String token, int userId) async {
    await fetchTasks(token, userId);
  }

  /// Helper: Convert hex color string to Color object
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // add alpha
    return Color(int.parse(hex, radix: 16));
  }

  /// Helper: Assign icon per RF status ID
  IconData _getIconForStatus(int statusId) {
    switch (statusId) {
      case 1:
        return Icons.pending;
      case 2:
        return Icons.receipt;
      case 3:
        return Icons.done;
      case 4:
        return Icons.admin_panel_settings;
      case 5:
        return Icons.block;
      case 6:
        return Icons.shutter_speed_rounded;
      default:
        return Icons.task;
    }
  }

  // Example: Load single user tasks with filter and pagination
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
          print('tasksData22 $tasksData');
          DetailedTasks = tasksData.map((t) => TaskModel.fromJson(t)).toList();
          return tasksData.map((t) => TaskModel.fromJson(t)).toList();
        } else {
          throw Exception('API Error: ${data['error']}');
        }
      } else {
        throw Exception(
          'Failed to load tasks. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    } finally {
      notifyListeners();
    }
  }
}
