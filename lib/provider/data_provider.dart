import 'package:flutter/foundation.dart';
import 'package:aw_app/server/ApiService.dart';
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
import 'package:flutter/material.dart';

class DataProvider with ChangeNotifier {
  // Data lists
  List<AnalysisType> _analysisTypes = [];
  List<Area> _areas = [];
  List<Department> _departments = [];
  List<WaterSourceType> _formWaterSourceTypes = [];
  List<Governorate> _governorates = [];
  List<MethodUsed> _methodUsed = [];
  List<RFStatus> _rfStatus = [];
  List<Sector> _sectors = [];
  List<Status> _status = [];
  List<Unit> _units = [];
  List<WaterSourceName> _waterSourceNames = [];
  List<WaterSourceType> _waterSourceTypes = [];
  List<WaterType> _waterTypes = [];
  List<Weather> _weather = [];

  // State variables
  bool _isLoading = false;
  String _error = '';
  bool _isInitialized = false;

  // Getters for data
  List<AnalysisType> get analysisTypes => _analysisTypes;
  List<Area> get areas => _areas;
  List<Department> get departments => _departments;
  List<WaterSourceType> get formWaterSourceTypes => _formWaterSourceTypes;
  List<Governorate> get governorates => _governorates;
  List<MethodUsed> get methodUsed => _methodUsed;
  List<RFStatus> get rfStatus => _rfStatus;
  List<Sector> get sectors => _sectors;
  List<Status> get status => _status;
  List<Unit> get units => _units;
  List<WaterSourceName> get waterSourceNames => _waterSourceNames;
  List<WaterSourceType> get waterSourceTypes => _waterSourceTypes;
  List<WaterType> get waterTypes => _waterTypes;
  List<Weather> get weather => _weather;

  // State getters
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isInitialized => _isInitialized;

  // Statistics getters
  int get totalAreas => _areas.length;
  int get totalGovernorates => _governorates.length;
  int get totalWaterSources => _waterSourceNames.length;
  int get totalAnalysisTypes => _analysisTypes.length;

  Future<void> init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("✅ test from provider All after first frame");
      fetchAllData();
    });
  }

  // Fetch all data at once
  Future<void> fetchAllData() async {
    if (_isLoading) {
      print("Already loading, skipping fetch.");
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    print("Begin fetching all data...");

    try {
      final allData = await ApiService.fetchAllData();
      print("Data fetched successfully from API.");

      // Update all data lists with debug prints
      _analysisTypes = allData['analysisTypes'] as List<AnalysisType>;
      print("Loaded analysisTypes: ${_analysisTypes.length}");

      _areas = allData['areas'] as List<Area>;
      print("Loaded areas: ${_areas.length}");

      _departments = allData['departments'] as List<Department>;
      print("Loaded departments: ${_departments.length}");

      _formWaterSourceTypes =
          allData['formWaterSourceTypes'] as List<WaterSourceType>;
      print("Loaded formWaterSourceTypes: ${_formWaterSourceTypes.length}");

      _governorates = allData['governorates'] as List<Governorate>;
      print("Loaded governorates: ${_governorates.length}");

      _methodUsed = allData['methodUsed'] as List<MethodUsed>;
      print("Loaded methodUsed: ${_methodUsed.length}");

      _rfStatus = allData['rfStatus'] as List<RFStatus>;
      print("Loaded rfStatus: ${_rfStatus.length}");

      _sectors = allData['sectors'] as List<Sector>;
      print("Loaded sectors: ${_sectors.length}");

      _status = allData['status'] as List<Status>;
      print("Loaded status: ${_status.length}");

      _units = allData['units'] as List<Unit>;
      print("Loaded units: ${_units.length}");

      _waterSourceNames = allData['waterSourceNames'] as List<WaterSourceName>;
      print("Loaded waterSourceNames: ${_waterSourceNames.length}");

      _waterSourceTypes = allData['waterSourceTypes'] as List<WaterSourceType>;
      print("Loaded waterSourceTypes: ${_waterSourceTypes.length}");

      _waterTypes = allData['waterTypes'] as List<WaterType>;
      print("Loaded waterTypes: ${_waterTypes.length}");

      _weather = allData['weather'] as List<Weather>;
      print("Loaded weather: ${_weather.length}");

      _isInitialized = true;
      _error = '';
      print("All data initialized successfully.");
    } catch (e) {
      _error = 'Failed to load data: $e';
      print('❌ Error fetching all data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print("Finished fetchAllData()");
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchAllData();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Helper methods to find items by ID
  Area? findAreaById(int? areaId) {
    try {
      return _areas.firstWhere((area) => area.areaID == areaId);
    } catch (e) {
      return null;
    }
  }

  Governorate? findGovernorateById(int? governorateId) {
    try {
      return _governorates.firstWhere(
        (gov) => gov.governorateID == governorateId,
      );
    } catch (e) {
      return null;
    }
  }

  WaterSourceType? findWaterSourceTypeById(int typeId) {
    try {
      return _waterSourceTypes.firstWhere(
        (type) => type.waterSourceTypeID == typeId,
      );
    } catch (e) {
      return null;
    }
  }

  WaterSourceName? findWaterSourceNameById(int nameId) {
    try {
      return _waterSourceNames.firstWhere(
        (name) => name.waterSourceNameID == nameId,
      );
    } catch (e) {
      return null;
    }
  }

  Status? findStatusById(int? statusID) {
    try {
      return _status.firstWhere((s) => s.statusID == statusID);
    } catch (e) {
      return null;
    }
  }

  Weather? getWeatherById(int? wID) {
    print("🔎 getWeatherById called with: $wID (${wID.runtimeType})");

    try {
      return _weather.firstWhere((s) => s.weatherID == wID);
    } catch (e) {
      return null;
    }
  }

  // Get related data
  List<Area> getAreasByGovernorate(int governorateId) {
    return _areas.where((area) => area.governorateID == governorateId).toList();
  }

  List<WaterSourceName> getWaterSourcesByArea(int areaId) {
    return _waterSourceNames
        .where((source) => source.areaID == areaId)
        .toList();
  }

  List<WaterSourceName> getWaterSourcesByType(int typeId) {
    return _waterSourceNames
        .where((source) => source.waterSourceTypeID == typeId)
        .toList();
  }

  String getGovernorateName(int governorateId) {
    final governorate = findGovernorateById(governorateId);
    return governorate?.governorateName ?? 'Unknown';
  }

  String getAreaName(int areaId) {
    final area = findAreaById(areaId);
    return area?.areaName ?? 'Unknown';
  }

  String getWaterSourceTypeName(int typeId) {
    final type = findWaterSourceTypeById(typeId);
    return type?.waterSourceTypesName ?? 'Unknown';
  }

  // Get filtered lists
  List<WaterSourceName> getDrinkingWaterSources() {
    return _waterSourceNames.where((source) {
      final type = findWaterSourceTypeById(source.waterSourceTypeID);
      return type?.waterTypeID == 1; // Drinking water
    }).toList();
  }

  List<WaterSourceName> getWasteWaterSources() {
    return _waterSourceNames.where((source) {
      final type = findWaterSourceTypeById(source.waterSourceTypeID);
      return type?.waterTypeID == 2; // Waste water
    }).toList();
  }

  // Check if data is available
  bool get hasData =>
      _isInitialized && _areas.isNotEmpty && _governorates.isNotEmpty;

  // Get data summary
  Map<String, int> getDataSummary() {
    return {
      'Governorates': _governorates.length,
      'Areas': _areas.length,
      'Water Sources': _waterSourceNames.length,
      'Analysis Types': _analysisTypes.length,
      'Units': _units.length,
      'Methods': _methodUsed.length,
    };
  }
}
