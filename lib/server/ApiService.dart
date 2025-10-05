import 'dart:convert';
import 'package:http/http.dart' as http;

// Import all your models
import 'package:aw_app/models/dataStaticModel/AnalysisType.dart';
import 'package:aw_app/models/dataStaticModel/area.dart';
import 'package:aw_app/models/dataStaticModel/Department.dart';
import 'package:aw_app/models/dataStaticModel/WaterSourceType.dart';
import 'package:aw_app/models/dataStaticModel/governorate.dart';
import 'package:aw_app/models/dataStaticModel/MethodUsed.dart';
import 'package:aw_app/models/dataStaticModel/RFStatus.dart';
import 'package:aw_app/models/dataStaticModel/sector.dart';
import 'package:aw_app/models/dataStaticModel/status.dart';
import 'package:aw_app/models/dataStaticModel/unit.dart';
import 'package:aw_app/models/dataStaticModel/WaterSourceName.dart';
import 'package:aw_app/models/dataStaticModel/WaterType.dart';
import 'package:aw_app/models/dataStaticModel/Weather.dart';
import 'package:aw_app/models/dataStaticModel/User.dart';
import 'package:aw_app/models/dataStaticModel/FormWaterSourceType.dart';

class ApiService {
  static const String baseUrl = 'http://10.10.15.21:3003/api/getData';

  // -----------------------
  // Generic fetch method
  // -----------------------
  static Future<List<T>> fetchData<T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    String columns = '*',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?columns=$columns&table=$table'),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load $table. Status: ${response.statusCode}',
        );
      }

      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching $table: $e');
      return <T>[]; // Return empty list if any error occurs
    }
  }

  // -----------------------
  // Fetch specific columns
  // -----------------------
  static Future<List<T>> fetchSpecificColumns<T>({
    required String table,
    required List<String> columns,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final columnsString = columns.join(',');
    return fetchData<T>(
      table: table,
      columns: columnsString,
      fromJson: fromJson,
    );
  }

  // -----------------------
  // Individual fetches
  // -----------------------
  static Future<List<User>> fetchUsers() async {
    final users = await fetchSpecificColumns<User>(
      table: 'users',
      columns: ['user_id', 'userName', 'account_status', 'role'],
      fromJson: (json) => User.fromJson(json),
    );

    print("✅ Users fetched: ${users.length}");
    for (var u in users) {
      print(" - ${u.userId} | ${u.userName} | ${u.role}");
    }
    return users;
  }

  static Future<List<AnalysisType>> fetchAnalysisTypes() => fetchData(
    table: 'AnalysisTypes',
    fromJson: (json) => AnalysisType.fromJson(json),
  );

  static Future<List<Area>> fetchAreas() =>
      fetchData(table: 'Areas', fromJson: (json) => Area.fromJson(json));

  static Future<List<Department>> fetchDepartments() => fetchData(
    table: 'Departments',
    fromJson: (json) => Department.fromJson(json),
  );

  static Future<List<FormWaterSourceType>> fetchFormWaterSourceTypes() => fetchData(
    table: 'FormWaterSourceType',
    fromJson: (json) => FormWaterSourceType.fromJson(json),
  );

  static Future<List<Governorate>> fetchGovernorates() => fetchData(
    table: 'Governorates',
    fromJson: (json) => Governorate.fromJson(json),
  );

  static Future<List<MethodUsed>> fetchMethodUsed() => fetchData(
    table: 'MethodUsed',
    fromJson: (json) => MethodUsed.fromJson(json),
  );

  static Future<List<RFStatus>> fetchRFStatus() => fetchData(
    table: 'RF_Status',
    fromJson: (json) => RFStatus.fromJson(json),
  );

  static Future<List<Sector>> fetchSectors() =>
      fetchData(table: 'Sectors', fromJson: (json) => Sector.fromJson(json));

  static Future<List<Status>> fetchStatus() =>
      fetchData(table: 'Status', fromJson: (json) => Status.fromJson(json));

  static Future<List<Unit>> fetchUnits() =>
      fetchData(table: 'Units', fromJson: (json) => Unit.fromJson(json));

  static Future<List<WaterSourceName>> fetchWaterSourceNames() => fetchData(
    table: 'WaterSourceName',
    fromJson: (json) => WaterSourceName.fromJson(json),
  );

  static Future<List<WaterSourceType>> fetchWaterSourceTypes() => fetchData(
    table: 'WaterSourceTypes',
    fromJson: (json) => WaterSourceType.fromJson(json),
  );

  static Future<List<WaterType>> fetchWaterTypes() => fetchData(
    table: 'WaterType',
    fromJson: (json) => WaterType.fromJson(json),
  );

  static Future<List<Weather>> fetchWeather() =>
      fetchData(table: 'Weather', fromJson: (json) => Weather.fromJson(json));

  // -----------------------
  // Batch fetch all data
  // -----------------------
  static Future<Map<String, dynamic>> fetchAllData() async {
    print('🔄 fetchAllData() started');

    try {
      // Create a list of futures, each with catchError to prevent nulls
      final futures = [
        fetchAnalysisTypes().catchError((_) => <AnalysisType>[]),
        fetchAreas().catchError((_) => <Area>[]),
        fetchDepartments().catchError((_) => <Department>[]),
        fetchFormWaterSourceTypes().catchError((_) => <FormWaterSourceType>[]),
        fetchGovernorates().catchError((_) => <Governorate>[]),
        fetchMethodUsed().catchError((_) => <MethodUsed>[]),
        fetchRFStatus().catchError((_) => <RFStatus>[]),
        fetchSectors().catchError((_) => <Sector>[]),
        fetchStatus().catchError((_) => <Status>[]),
        fetchUnits().catchError((_) => <Unit>[]),
        fetchWaterSourceNames().catchError((_) => <WaterSourceName>[]),
        fetchWaterSourceTypes().catchError((_) => <WaterSourceType>[]),
        fetchWaterTypes().catchError((_) => <WaterType>[]),
        fetchWeather().catchError((_) => <Weather>[]),
        fetchUsers().catchError((_) => <User>[]),
      ];

      final results = await Future.wait(futures);

      // Return results as a map. Types are guaranteed non-null
      return {
        'analysisTypes': results[0],
        'areas': results[1],
        'departments': results[2],
        'formWaterSourceTypes': results[3],
        'governorates': results[4],
        'methodUsed': results[5],
        'rfStatus': results[6],
        'sectors': results[7],
        'status': results[8],
        'units': results[9],
        'waterSourceNames': results[10],
        'waterSourceTypes': results[11],
        'waterTypes': results[12],
        'weather': results[13],
        'users': results[14] ?? <User>[], // ✅ provide default empty list
      };
    } catch (e) {
      print('❌ Unexpected error in fetchAllData: $e');
      return {}; // return empty map on unexpected error
    } finally {
      print('✅ fetchAllData() finished');
    }
  }
}
