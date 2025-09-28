import 'dart:convert';
import 'package:http/http.dart' as http;

// Import all your models
import 'package:aw_app/models/dataStaticModel/AnalysisType.dart';
import 'package:aw_app/models/dataStaticModel/area.dart';
import 'package:aw_app/models/dataStaticModel/department.dart';
import 'package:aw_app/models/dataStaticModel/WaterSourceType.dart';
import 'package:aw_app/models/dataStaticModel/governorate.dart';
import 'package:aw_app/models/dataStaticModel/MethodUsed.dart';
import 'package:aw_app/models/dataStaticModel/RFStatus.dart';
import 'package:aw_app/models/dataStaticModel/sector.dart';
import 'package:aw_app/models/dataStaticModel/status.dart';
import 'package:aw_app/models/dataStaticModel/unit.dart';
import 'package:aw_app/models/dataStaticModel/WaterSourceName.dart';
// import 'package:aw_app/models/dataStaticModel/WaterSourceType.dart';
import 'package:aw_app/models/dataStaticModel/WaterType.dart';
import 'package:aw_app/models/dataStaticModel/weather.dart';

class ApiService {
  static const String baseUrl = 'http://10.10.15.21:3003/api/getData';

  // Generic method to fetch data from any table
  static Future<List<T>> fetchData<T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    String columns = '*',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?columns=$columns&table=$table'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to load data from $table. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching data from $table: $e');
    }
  }

  // AnalysisTypes
  static Future<List<AnalysisType>> fetchAnalysisTypes() async {
    return fetchData<AnalysisType>(
      table: 'AnalysisTypes',
      fromJson: (json) => AnalysisType.fromJson(json),
    );
  }

  // Areas
  static Future<List<Area>> fetchAreas() async {
    return fetchData<Area>(
      table: 'Areas',
      fromJson: (json) => Area.fromJson(json),
    );
  }

  // Departments
  static Future<List<Department>> fetchDepartments() async {
    return fetchData<Department>(
      table: 'Departments',
      fromJson: (json) => Department.fromJson(json),
    );
  }

  // FormWaterSourceType
  static Future<List<WaterSourceType>> fetchFormWaterSourceTypes() async {
    return fetchData<WaterSourceType>(
      table: 'FormWaterSourceType',
      fromJson: (json) => WaterSourceType.fromJson(json),
    );
  }

  // Governorates
  static Future<List<Governorate>> fetchGovernorates() async {
    return fetchData<Governorate>(
      table: 'Governorates',
      fromJson: (json) => Governorate.fromJson(json),
    );
  }

  // MethodUsed
  static Future<List<MethodUsed>> fetchMethodUsed() async {
    return fetchData<MethodUsed>(
      table: 'MethodUsed',
      fromJson: (json) => MethodUsed.fromJson(json),
    );
  }

  // RF_Status
  static Future<List<RFStatus>> fetchRFStatus() async {
    return fetchData<RFStatus>(
      table: 'RF_Status',
      fromJson: (json) => RFStatus.fromJson(json),
    );
  }

  // Sectors
  static Future<List<Sector>> fetchSectors() async {
    return fetchData<Sector>(
      table: 'Sectors',
      fromJson: (json) => Sector.fromJson(json),
    );
  }

  // Status
  static Future<List<Status>> fetchStatus() async {
    return fetchData<Status>(
      table: 'Status',
      fromJson: (json) => Status.fromJson(json),
    );
  }

  // Units
  static Future<List<Unit>> fetchUnits() async {
    return fetchData<Unit>(
      table: 'Units',
      fromJson: (json) => Unit.fromJson(json),
    );
  }

  // WaterSourceName
  static Future<List<WaterSourceName>> fetchWaterSourceNames() async {
    return fetchData<WaterSourceName>(
      table: 'WaterSourceName',
      fromJson: (json) => WaterSourceName.fromJson(json),
    );
  }

  // WaterSourceTypes
  static Future<List<WaterSourceType>> fetchWaterSourceTypes() async {
    return fetchData<WaterSourceType>(
      table: 'WaterSourceTypes',
      fromJson: (json) => WaterSourceType.fromJson(json),
    );
  }

  // WaterType
  static Future<List<WaterType>> fetchWaterTypes() async {
    return fetchData<WaterType>(
      table: 'WaterType',
      fromJson: (json) => WaterType.fromJson(json),
    );
  }

  // Weather
  static Future<List<Weather>> fetchWeather() async {
    return fetchData<Weather>(
      table:
          'Weather', // Note: This uses WaterSourceTypes table for weather data
      fromJson: (json) => Weather.fromJson(json),
    );
  }

  // Batch fetch all data (useful for initial app load)
  static Future<Map<String, dynamic>> fetchAllData() async {
    print('🔄 fetchAllData() started');

    try {
      final results = await Future.wait([
        fetchAnalysisTypes(),
        fetchAreas(),
        fetchDepartments(),
        fetchFormWaterSourceTypes(),
        fetchGovernorates(),
        fetchMethodUsed(),
        fetchRFStatus(),
        fetchSectors(),
        fetchStatus(),
        fetchUnits(),
        fetchWaterSourceNames(),
        fetchWaterSourceTypes(),
        fetchWaterTypes(),
        fetchWeather(),
      ]);

      return {
        'analysisTypes': results[0] as List<AnalysisType>,
        'areas': results[1] as List<Area>,
        'departments': results[2] as List<Department>,
        'formWaterSourceTypes': results[3] as List<WaterSourceType>,
        'governorates': results[4] as List<Governorate>,
        'methodUsed': results[5] as List<MethodUsed>,
        'rfStatus': results[6] as List<RFStatus>,
        'sectors': results[7] as List<Sector>,
        'status': results[8] as List<Status>,
        'units': results[9] as List<Unit>,
        'waterSourceNames': results[10] as List<WaterSourceName>,
        'waterSourceTypes': results[11] as List<WaterSourceType>,
        'waterTypes': results[12] as List<WaterType>,
        'weather': results[13] as List<Weather>,
      };
    } catch (e) {
      throw Exception('Error fetching all data: $e');
    }
  }

  // Helper method to fetch specific columns from a table
  static Future<List<Map<String, dynamic>>> fetchSpecificColumns({
    required String table,
    required List<String> columns,
  }) async {
    try {
      final columnsString = columns.join(',');
      final response = await http.get(
        Uri.parse('$baseUrl?columns=$columnsString&table=$table'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Failed to load data from $table. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching specific columns from $table: $e');
    }
  }
}
