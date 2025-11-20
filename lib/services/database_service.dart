// lib/services/database_service.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fillup_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fueltrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incremented version for migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add imagePath column to vehicles table
      await db.execute('ALTER TABLE vehicles ADD COLUMN imagePath TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const nullableRealType = 'REAL';
    const nullableTextType = 'TEXT';

    // Vehicles table
    await db.execute('''
      CREATE TABLE vehicles (
        id $idType,
        name $textType,
        make $nullableTextType,
        model $nullableTextType,
        year INTEGER,
        tankCapacity $nullableRealType,
        epaCity $nullableRealType,
        epaHighway $nullableRealType,
        epaCombined $nullableRealType,
        isActive $intType,
        createdAt $textType,
        imagePath $nullableTextType
      )
    ''');

    // Fillups table
    await db.execute('''
      CREATE TABLE fillups (
        id $idType,
        vehicleId $textType,
        date $textType,
        odometer $realType,
        dteBeforeFillup $nullableRealType,
        dteAfterFillup $nullableRealType,
        gallons $realType,
        totalCost $realType,
        cityDrivingPercent $realType,
        isFullTank $intType,
        fuelGrade $textType,
        location $nullableTextType,
        paymentMethod $nullableTextType,
        latitude $nullableRealType,
        longitude $nullableRealType,
        temperature $nullableRealType,
        FOREIGN KEY (vehicleId) REFERENCES vehicles (id) ON DELETE CASCADE
      )
    ''');

    // App settings table for onboarding status
    await db.execute('''
      CREATE TABLE app_settings (
        key $textType,
        value $textType
      )
    ''');
  }

  // ==================== VEHICLE OPERATIONS ====================

  Future<VehicleProfile> createVehicle(VehicleProfile vehicle) async {
    final db = await database;
    
    debugPrint('=== DATABASE CREATE VEHICLE ===');
    debugPrint('Vehicle name: ${vehicle.name}');
    debugPrint('Image path to save: ${vehicle.imagePath}');
    
    await db.insert('vehicles', {
      'id': vehicle.id,
      'name': vehicle.name,
      'make': vehicle.make,
      'model': vehicle.model,
      'year': vehicle.year,
      'tankCapacity': vehicle.tankCapacity,
      'epaCity': vehicle.epaCity,
      'epaHighway': vehicle.epaHighway,
      'epaCombined': vehicle.epaCombined,
      'isActive': vehicle.isActive ? 1 : 0,
      'createdAt': vehicle.createdAt.toIso8601String(),
      'imagePath': vehicle.imagePath,
    });
    
    debugPrint('Vehicle saved to database');
    return vehicle;
  }

  Future<List<VehicleProfile>> getAllVehicles() async {
    final db = await database;
    final result = await db.query(
      'vehicles',
      orderBy: 'createdAt DESC',
    );
    
    debugPrint('=== DATABASE GET ALL VEHICLES ===');
    debugPrint('Found ${result.length} vehicles');
    for (var vehicleData in result) {
      debugPrint('  - ${vehicleData['name']}: imagePath = ${vehicleData['imagePath']}');
    }
    
    return result.map((json) => VehicleProfile.fromJson(json)).toList();
  }

  Future<VehicleProfile?> getActiveVehicle() async {
    final db = await database;
    final result = await db.query(
      'vehicles',
      where: 'isActive = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return VehicleProfile.fromJson(result.first);
  }

  Future<void> setActiveVehicle(String vehicleId) async {
    final db = await database;
    // Deactivate all vehicles
    await db.update('vehicles', {'isActive': 0});
    // Activate selected vehicle
    await db.update(
      'vehicles',
      {'isActive': 1},
      where: 'id = ?',
      whereArgs: [vehicleId],
    );
  }

  Future<void> updateVehicle(VehicleProfile vehicle) async {
    final db = await database;
    await db.update(
      'vehicles',
      {
        'name': vehicle.name,
        'make': vehicle.make,
        'model': vehicle.model,
        'year': vehicle.year,
        'tankCapacity': vehicle.tankCapacity,
        'epaCity': vehicle.epaCity,
        'epaHighway': vehicle.epaHighway,
        'epaCombined': vehicle.epaCombined,
        'imagePath': vehicle.imagePath,
      },
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final db = await database;
    await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [vehicleId],
    );
  }

  // ==================== FILLUP OPERATIONS ====================

  Future<FillupRecord> createFillup(FillupRecord fillup) async {
    final db = await database;
    await db.insert('fillups', fillup.toJson());
    return fillup;
  }

  Future<List<FillupRecord>> getFillupsByVehicle(String vehicleId) async {
    final db = await database;
    final result = await db.query(
      'fillups',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return result.map((json) => FillupRecord.fromJson(json)).toList();
  }

  Future<FillupRecord?> getLastFillup(String vehicleId) async {
    final db = await database;
    final result = await db.query(
      'fillups',
      where: 'vehicleId = ? AND isFullTank = ?',
      whereArgs: [vehicleId, 1],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return FillupRecord.fromJson(result.first);
  }

  Future<void> updateFillup(FillupRecord fillup) async {
    final db = await database;
    await db.update(
      'fillups',
      fillup.toJson(),
      where: 'id = ?',
      whereArgs: [fillup.id],
    );
  }

  Future<void> deleteFillup(String fillupId) async {
    final db = await database;
    await db.delete(
      'fillups',
      where: 'id = ?',
      whereArgs: [fillupId],
    );
  }

  // ==================== STATS CALCULATIONS ====================

  Future<FuelStats> calculateStats(String vehicleId) async {
    final fillups = await getFillupsByVehicle(vehicleId);
    
    if (fillups.isEmpty) {
      return FuelStats(
        averageMPG: 0,
        trueMPG: 0,
        bestMPG: 0,
        worstMPG: 0,
        totalMiles: 0,
        totalGallons: 0,
        totalCost: 0,
        averageCostPerGallon: 0,
        averageCostPerMile: 0,
        totalFillups: 0,
        cityDrivingPercent: 0,
      );
    }

    // Get only full tank fillups for accurate MPG
    final fullTankFillups = fillups.where((f) => f.isFullTank).toList();
    
    double totalMiles = 0;
    double totalGallons = 0;
    double totalCost = 0;
    double totalCityPercent = 0;
    List<double> mpgValues = [];

    // Calculate MPG for each consecutive full-tank pair
    for (int i = 0; i < fullTankFillups.length - 1; i++) {
      final current = fullTankFillups[i];
      final previous = fullTankFillups[i + 1]; // Earlier fillup
      
      final miles = current.odometer - previous.odometer;
      final mpg = miles / current.gallons;
      
      if (mpg > 0 && mpg < 100) { // Sanity check
        mpgValues.add(mpg);
        totalMiles += miles;
      }
      
      totalGallons += current.gallons;
      totalCost += current.totalCost;
      totalCityPercent += current.cityDrivingPercent;
    }

    // Add the most recent fillup's stats (even if we can't calculate MPG yet)
    if (fullTankFillups.isNotEmpty) {
      totalGallons += fullTankFillups.first.gallons;
      totalCost += fullTankFillups.first.totalCost;
      totalCityPercent += fullTankFillups.first.cityDrivingPercent;
    }

    final avgMPG = mpgValues.isNotEmpty 
        ? mpgValues.reduce((a, b) => a + b) / mpgValues.length 
        : 0.0;
    final trueMPG = totalMiles > 0 ? totalMiles / totalGallons : 0.0;
    final bestMPG = mpgValues.isNotEmpty ? mpgValues.reduce((a, b) => a > b ? a : b) : 0.0;
    final worstMPG = mpgValues.isNotEmpty ? mpgValues.reduce((a, b) => a < b ? a : b) : 0.0;
    final avgCostPerGallon = totalGallons > 0 ? totalCost / totalGallons : 0.0;
    final avgCostPerMile = totalMiles > 0 ? totalCost / totalMiles : 0.0;
    final avgCityPercent = fillups.isNotEmpty ? totalCityPercent / fillups.length : 0.0;

    return FuelStats(
      averageMPG: avgMPG,
      trueMPG: trueMPG,
      bestMPG: bestMPG,
      worstMPG: worstMPG,
      totalMiles: totalMiles,
      totalGallons: totalGallons,
      totalCost: totalCost,
      averageCostPerGallon: avgCostPerGallon,
      averageCostPerMile: avgCostPerMile,
      totalFillups: fillups.length,
      cityDrivingPercent: avgCityPercent,
    );
  }

  // ==================== APP SETTINGS ====================

  Future<void> setOnboardingComplete() async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': 'onboarding_complete', 'value': 'true'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isOnboardingComplete() async {
    final db = await database;
    final result = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['onboarding_complete'],
    );
    return result.isNotEmpty && result.first['value'] == 'true';
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}