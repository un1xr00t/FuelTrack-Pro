// lib/models/fillup_record.dart
class FillupRecord {
  final String id;
  final DateTime date;
  final double odometer;
  final double? dteBeforeFillup;  // Optional - for real-time monitoring
  final double? dteAfterFillup;   // Optional - for real-time monitoring
  final double gallons;
  final double totalCost;
  final double cityDrivingPercent;
  final bool isFullTank;
  final String fuelGrade;
  final String? location;
  final String? paymentMethod;
  final double? latitude;
  final double? longitude;
  final double? temperature;
  
  FillupRecord({
    required this.id,
    required this.date,
    required this.odometer,
    this.dteBeforeFillup,    // Now optional
    this.dteAfterFillup,     // Now optional
    required this.gallons,
    required this.totalCost,
    required this.cityDrivingPercent,
    required this.isFullTank,
    required this.fuelGrade,
    this.location,
    this.paymentMethod,
    this.latitude,
    this.longitude,
    this.temperature,
  });

  // Calculate MPG using the gold standard tank-to-tank method
  // This is the CORRECT way to calculate MPG
  double calculateMPG(FillupRecord? previousFillup) {
    // Need a previous full-tank fill-up to calculate
    if (previousFillup == null) return 0;
    
    // Skip if either fill-up is partial (for accuracy)
    if (!isFullTank || !previousFillup.isFullTank) return 0;
    
    final milesDriven = odometer - previousFillup.odometer;
    
    // Simple, accurate: miles driven / gallons consumed
    return milesDriven / gallons;
  }

  // Estimate current MPG using DTE (for real-time monitoring between fill-ups)
  // This is NOT for historical accuracy, but for live feedback
  double? estimateCurrentMPG() {
    if (dteAfterFillup == null) return null;
    
    // Estimate: miles per gallon based on DTE and tank fill
    return dteAfterFillup! / gallons;
  }

  // Calculate efficiency change from DTE readings (optional feature)
  double? calculateEfficiencyChange(FillupRecord? previousFillup) {
    if (dteAfterFillup == null || 
        previousFillup?.dteAfterFillup == null) return null;
    
    final previousMPG = previousFillup!.dteAfterFillup! / previousFillup.gallons;
    final currentMPG = dteAfterFillup! / gallons;
    
    return ((currentMPG - previousMPG) / previousMPG) * 100; // Percentage change
  }

  // Calculate cost per gallon
  double get pricePerGallon => totalCost / gallons;

  // Calculate cost per mile (needs previous fillup for miles driven)
  double calculateCostPerMile(FillupRecord? previousFillup) {
    if (previousFillup == null) return 0;
    final milesDriven = odometer - previousFillup.odometer;
    return totalCost / milesDriven;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'dteBeforeFillup': dteBeforeFillup,
      'dteAfterFillup': dteAfterFillup,
      'gallons': gallons,
      'totalCost': totalCost,
      'cityDrivingPercent': cityDrivingPercent,
      'isFullTank': isFullTank ? 1 : 0,
      'fuelGrade': fuelGrade,
      'location': location,
      'paymentMethod': paymentMethod,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
    };
  }

  // Create from JSON
  factory FillupRecord.fromJson(Map<String, dynamic> json) {
    return FillupRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      odometer: json['odometer'],
      dteBeforeFillup: json['dteBeforeFillup'],
      dteAfterFillup: json['dteAfterFillup'],
      gallons: json['gallons'],
      totalCost: json['totalCost'],
      cityDrivingPercent: json['cityDrivingPercent'],
      isFullTank: json['isFullTank'] == 1,
      fuelGrade: json['fuelGrade'],
      location: json['location'],
      paymentMethod: json['paymentMethod'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      temperature: json['temperature'],
    );
  }

  FillupRecord copyWith({
    String? id,
    DateTime? date,
    double? odometer,
    double? dteBeforeFillup,
    double? dteAfterFillup,
    double? gallons,
    double? totalCost,
    double? cityDrivingPercent,
    bool? isFullTank,
    String? fuelGrade,
    String? location,
    String? paymentMethod,
    double? latitude,
    double? longitude,
    double? temperature,
  }) {
    return FillupRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      dteBeforeFillup: dteBeforeFillup ?? this.dteBeforeFillup,
      dteAfterFillup: dteAfterFillup ?? this.dteAfterFillup,
      gallons: gallons ?? this.gallons,
      totalCost: totalCost ?? this.totalCost,
      cityDrivingPercent: cityDrivingPercent ?? this.cityDrivingPercent,
      isFullTank: isFullTank ?? this.isFullTank,
      fuelGrade: fuelGrade ?? this.fuelGrade,
      location: location ?? this.location,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
    );
  }
}

class VehicleProfile {
  final String id;
  final String name;
  final String? make;
  final String? model;
  final int? year;
  final double? tankCapacity;
  final double? epaCity;
  final double? epaHighway;
  final double? epaCombined;
  
  VehicleProfile({
    required this.id,
    required this.name,
    this.make,
    this.model,
    this.year,
    this.tankCapacity,
    this.epaCity,
    this.epaHighway,
    this.epaCombined,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'tankCapacity': tankCapacity,
      'epaCity': epaCity,
      'epaHighway': epaHighway,
      'epaCombined': epaCombined,
    };
  }

  factory VehicleProfile.fromJson(Map<String, dynamic> json) {
    return VehicleProfile(
      id: json['id'],
      name: json['name'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      tankCapacity: json['tankCapacity'],
      epaCity: json['epaCity'],
      epaHighway: json['epaHighway'],
      epaCombined: json['epaCombined'],
    );
  }
}

class FuelStats {
  final double averageMPG;
  final double trueMPG;
  final double bestMPG;
  final double worstMPG;
  final double totalMiles;
  final double totalGallons;
  final double totalCost;
  final double averageCostPerGallon;
  final double averageCostPerMile;
  final int totalFillups;
  final double cityDrivingPercent;
  final double? comparedToEPA;
  
  FuelStats({
    required this.averageMPG,
    required this.trueMPG,
    required this.bestMPG,
    required this.worstMPG,
    required this.totalMiles,
    required this.totalGallons,
    required this.totalCost,
    required this.averageCostPerGallon,
    required this.averageCostPerMile,
    required this.totalFillups,
    required this.cityDrivingPercent,
    this.comparedToEPA,
  });
}