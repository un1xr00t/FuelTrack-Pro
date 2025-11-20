// lib/services/receipt_parser_service.dart
import 'package:flutter/foundation.dart';

class ReceiptParserService {
  static Map<String, dynamic> parseReceipt(String text) {
    final Map<String, dynamic> data = {};
    
    debugPrint('\n=== PARSING RECEIPT ===');
    debugPrint('Raw text length: ${text.length} characters');
    
    // Clean up text
    final cleanText = text.toUpperCase();
    final lines = cleanText.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    debugPrint('Number of lines: ${lines.length}');
    debugPrint('Lines:\n${lines.join('\n')}');
    
    // Extract date
    final date = _extractDate(lines);
    if (date != null) {
      data['date'] = date;
      debugPrint('✓ Extracted date: $date');
    } else {
      debugPrint('✗ Could not extract date');
    }
    
    // Extract gallons
    final gallons = _extractGallons(lines, cleanText);
    if (gallons != null) {
      data['gallons'] = gallons;
      debugPrint('✓ Extracted gallons: $gallons');
    } else {
      debugPrint('✗ Could not extract gallons');
    }
    
    // Extract total cost
    final totalCost = _extractTotalCost(lines, cleanText);
    if (totalCost != null) {
      data['totalCost'] = totalCost;
      debugPrint('✓ Extracted total cost: \$$totalCost');
    } else {
      debugPrint('✗ Could not extract total cost');
    }
    
    // Extract price per gallon
    final pricePerGallon = _extractPricePerGallon(lines, cleanText);
    if (pricePerGallon != null) {
      data['pricePerGallon'] = pricePerGallon;
      debugPrint('✓ Extracted price per gallon: \$$pricePerGallon');
    } else {
      debugPrint('✗ Could not extract price per gallon');
    }
    
    // Extract fuel grade
    final fuelGrade = _extractFuelGrade(lines, cleanText);
    if (fuelGrade != null) {
      data['fuelGrade'] = fuelGrade;
      debugPrint('✓ Extracted fuel grade: $fuelGrade');
    } else {
      debugPrint('✗ Could not extract fuel grade');
    }
    
    // Extract location/station name
    final location = _extractLocation(lines);
    if (location != null) {
      data['location'] = location;
      debugPrint('✓ Extracted location: $location');
    } else {
      debugPrint('✗ Could not extract location');
    }
    
    // Try to determine payment method
    final paymentMethod = _extractPaymentMethod(lines, cleanText);
    if (paymentMethod != null) {
      data['paymentMethod'] = paymentMethod;
      debugPrint('✓ Extracted payment method: $paymentMethod');
    } else {
      debugPrint('✗ Could not extract payment method');
    }
    
    debugPrint('=== PARSING COMPLETE ===\n');
    
    return data;
  }
  
  static DateTime? _extractDate(List<String> lines) {
    // More comprehensive date patterns
    final datePatterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'), // MM/DD/YYYY or MM-DD-YYYY
      RegExp(r'(\d{2,4})[/-](\d{1,2})[/-](\d{1,2})'), // YYYY/MM/DD or YYYY-MM-DD
      RegExp(r'(\d{1,2})\s+(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)[A-Z]*\s+(\d{2,4})'),
      RegExp(r'(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)[A-Z]*\s+(\d{1,2})[,\s]+(\d{2,4})'),
    ];
    
    for (final line in lines) {
      debugPrint('Checking date in line: $line');
      
      // Special handling for dates that might have OCR errors or extra numbers after
      final cleanedLine = line.split(' ').first; // Get first part before spaces
      
      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(cleanedLine.isNotEmpty ? cleanedLine : line);
        if (match != null) {
          try {
            if (match.groupCount >= 3) {
              int? month, day, year;
              
              // Check if it's a month name pattern
              if (line.contains('JAN') || line.contains('FEB') || line.contains('MAR') ||
                  line.contains('APR') || line.contains('MAY') || line.contains('JUN') ||
                  line.contains('JUL') || line.contains('AUG') || line.contains('SEP') ||
                  line.contains('OCT') || line.contains('NOV') || line.contains('DEC')) {
                
                // Pattern: Day MonthName Year or MonthName Day Year
                if (int.tryParse(match.group(1)!) != null) {
                  day = int.tryParse(match.group(1)!);
                  month = _monthNameToNumber(match.group(2)!);
                  year = int.tryParse(match.group(3)!);
                } else {
                  month = _monthNameToNumber(match.group(1)!);
                  day = int.tryParse(match.group(2)!);
                  year = int.tryParse(match.group(3)!);
                }
              } else {
                var part1 = int.tryParse(match.group(1)!);
                var part2 = int.tryParse(match.group(2)!);
                var part3 = int.tryParse(match.group(3)!);
                
                if (part1 != null && part2 != null && part3 != null) {
                  // Handle OCR error where day might be 0 (should be 01)
                  if (part2 == 0) {
                    part2 = 1;
                  }
                  
                  // Determine format based on values
                  if (part1 > 31) {
                    // YYYY-MM-DD
                    year = part1;
                    month = part2;
                    day = part3;
                  } else if (part3 > 31 || part3 < 100) {
                    // MM-DD-YYYY or MM-DD-YY
                    month = part1;
                    day = part2;
                    year = part3;
                  } else {
                    // Assume MM/DD/YY
                    month = part1;
                    day = part2;
                    year = part3;
                  }
                }
              }
              
              if (month != null && day != null && year != null) {
                // Handle 2-digit years
                if (year < 100) {
                  year += 2000;
                }
                
                // Handle day = 0 (OCR error)
                if (day == 0) {
                  day = 1;
                }
                
                if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
                  debugPrint('  → Matched date: $month/$day/$year');
                  return DateTime(year, month, day);
                }
              }
            }
          } catch (e) {
            debugPrint('  → Date parse error: $e');
            continue;
          }
        }
      }
    }
    
    // If no date found, use today
    return DateTime.now();
  }
  
  static int _monthNameToNumber(String monthName) {
    const months = {
      'JAN': 1, 'JANUARY': 1,
      'FEB': 2, 'FEBRUARY': 2,
      'MAR': 3, 'MARCH': 3,
      'APR': 4, 'APRIL': 4,
      'MAY': 5,
      'JUN': 6, 'JUNE': 6,
      'JUL': 7, 'JULY': 7,
      'AUG': 8, 'AUGUST': 8,
      'SEP': 9, 'SEPT': 9, 'SEPTEMBER': 9,
      'OCT': 10, 'OCTOBER': 10,
      'NOV': 11, 'NOVEMBER': 11,
      'DEC': 12, 'DECEMBER': 12,
    };
    return months[monthName.toUpperCase()] ?? 1;
  }
  
  static double? _extractGallons(List<String> lines, String fullText) {
    debugPrint('\n=== EXTRACTING GALLONS ===');
    
    // Stage 1: Direct keyword patterns with numbers (most reliable)
    final directPatterns = [
      RegExp(r'(\d+\.\d{1,3})\s*GAL', caseSensitive: false), // 10.099 GAL
      RegExp(r'(\d+)\.\s*(\d{3})\s*G\b', caseSensitive: false), // 10. 099G (with space)
      RegExp(r'(\d+)\.(\d{3})G\b', caseSensitive: false), // 10.099G (no space)
      RegExp(r'GALLON[S]?[:\s]+(\d+\.\d+)', caseSensitive: false), // GALLONS: 10.099
      RegExp(r'FUEL\s*VOL[UME]*[:\s]*(\d+\.\d+)', caseSensitive: false), // FUEL VOLUME: X.XX
      RegExp(r'VOLUME[:\s]+(\d+\.\d+)', caseSensitive: false), // VOLUME: X.XX
      RegExp(r'PRODUCT[:\s]+(\d+\.\d+)\s*GAL', caseSensitive: false), // PRODUCT: X.XX GAL
      RegExp(r'QTY[:\s]+(\d+\.\d+)', caseSensitive: false), // QTY: X.XX
      RegExp(r'QUANTITY[:\s]+(\d+\.\d+)', caseSensitive: false), // QUANTITY: X.XX
    ];
    
    // Try direct patterns first
    for (final line in lines) {
      for (final pattern in directPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          double? value;
          // Handle special split format (10. 099G -> 10.099)
          if (match.groupCount >= 2 && pattern.pattern.contains(r'(\d+)\.\s*(\d{')) {
            final whole = match.group(1)!;
            final decimal = match.group(2)!;
            value = double.tryParse('$whole.$decimal');
          } else {
            value = double.tryParse(match.group(1)!);
          }
          
          if (value != null && value > 0.5 && value < 100) {
            debugPrint('  → Direct pattern match: $value in line: $line');
            return value;
          }
        }
      }
    }
    
    // Stage 2: Context-based extraction (look for GALLON keyword, then nearby numbers)
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Check if line contains "GALLONS" keyword (case insensitive)
      if (line.toUpperCase().contains('GALLON')) {
        debugPrint('  → Found GALLONS line at index $i: $line');
        
        // Try same line first with various formats
        final numberMatch = RegExp(r'(\d+\.?\d+)').firstMatch(line);
        if (numberMatch != null) {
          final value = double.tryParse(numberMatch.group(1)!);
          if (value != null && value > 0.5 && value < 100) {
            debugPrint('  → Extracted gallons from same line: $value');
            return value;
          }
        }
        
        // Check next several lines, skipping non-numeric lines
        for (int j = i + 1; j < lines.length && j < i + 10; j++) {
          final nextLine = lines[j];
          
          // Skip lines that are just keywords or labels
          if (nextLine.toUpperCase().contains('PRICE') || 
              nextLine.toUpperCase().contains('SUBTOTAL') ||
              nextLine.toUpperCase().contains('TAX') ||
              nextLine.toUpperCase().contains('TOTAL') ||
              nextLine.toUpperCase().contains('PUMP') ||
              nextLine.length < 2) {
            debugPrint('  → Skipping keyword line: $nextLine');
            continue;
          }
          
          debugPrint('  → Checking line $j for gallons: $nextLine');
          
          // Look for a standalone decimal number (gallons are typically X.XXX format)
          final nextLineNumber = RegExp(r'^(\d+\.\d+)$').firstMatch(nextLine.trim());
          if (nextLineNumber != null) {
            final value = double.tryParse(nextLineNumber.group(1)!);
            if (value != null && value > 0.5 && value < 100) {
              debugPrint('  → Extracted gallons from line $j: $value');
              return value;
            }
          }
        }
      }
    }
    
    // Stage 3: Fallback patterns for various receipt formats
    debugPrint('  → Trying fallback gallon detection...');
    for (final line in lines) {
      // Match standalone numbers with 3 decimal places (like 4.137, 10.099)
      if (RegExp(r'^\d+\.\d{3}$').hasMatch(line.trim())) {
        final value = double.tryParse(line.trim());
        if (value != null && value > 0.5 && value < 50) {
          debugPrint('  → Found gallon value (3 decimals): $value in line: $line');
          return value;
        }
      }
      
      // Check for patterns like "10. 099G" or "10.099G" with G suffix
      final gallonWithGMatch = RegExp(r'(\d+)\.\s*(\d+)G').firstMatch(line);
      if (gallonWithGMatch != null) {
        final whole = gallonWithGMatch.group(1)!;
        final decimal = gallonWithGMatch.group(2)!;
        final value = double.tryParse('$whole.$decimal');
        if (value != null && value > 0.5 && value < 50) {
          debugPrint('  → Found gallon value with G suffix: $value in line: $line');
          return value;
        }
      }
      
      // Standard 2 decimal fallback (but stricter range)
      if (RegExp(r'^\d+\.\d{2}$').hasMatch(line.trim())) {
        final value = double.tryParse(line.trim());
        if (value != null && value > 2 && value < 40) {
          debugPrint('  → Found potential gallon value (2 decimals): $value in line: $line');
          return value;
        }
      }
    }
    
    return null;
  }
  
  static double? _extractTotalCost(List<String> lines, String fullText) {
    debugPrint('\n=== EXTRACTING TOTAL COST ===');
    
    // More comprehensive total cost patterns
    final totalPatterns = [
      RegExp(r'TOTAL[:\s]*\$?\s*(\d+\.?\d*)', caseSensitive: false), // TOTAL: $XX.XX
      RegExp(r'AMOUNT[:\s]*\$?\s*(\d+\.?\d*)', caseSensitive: false), // AMOUNT: $XX.XX
      RegExp(r'SALE[:\s]*\$?\s*(\d+\.?\d*)', caseSensitive: false), // SALE: $XX.XX
      RegExp(r'FUEL\s*SALE[:\s]*\$?\s*(\d+\.?\d*)', caseSensitive: false), // FUEL SALE: $XX.XX
      RegExp(r'\$\s*(\d+\.?\d*)\s*TOTAL', caseSensitive: false), // $XX.XX TOTAL
      RegExp(r'PURCHASE[:\s]*\$?\s*(\d+\.?\d*)', caseSensitive: false), // PURCHASE: $XX.XX
      RegExp(r'CHARGED[:\s]*\$?\s*(\d+\.?\d*)', caseSensitive: false), // CHARGED: $XX.XX
    ];
    
    double? largestAmount;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineUpper = line.toUpperCase();
      
      // Special handling for lines with FUEL SALE or DEBIT or TOTAL
      if (lineUpper.contains('FUEL') && lineUpper.contains('SALE') ||
          lineUpper.contains('DEBIT') ||
          lineUpper.contains('TOTAL')) {
        debugPrint('  → Found payment keyword line: $line');
        
        // Check same line and next 2 lines for dollar amount
        for (int j = i; j < lines.length && j < i + 3; j++) {
          final checkLine = lines[j];
          debugPrint('  → Checking line: $checkLine');
          final dollarMatch = RegExp(r'\$\s*(\d+\.?\d+)').firstMatch(checkLine);
          if (dollarMatch != null) {
            final value = double.tryParse(dollarMatch.group(1)!);
            if (value != null && value > 0 && value < 1000) {
              debugPrint('  → Extracted cost: $value');
              if (largestAmount == null || value > largestAmount) {
                largestAmount = value;
              }
            }
          }
        }
      }
      
      for (final pattern in totalPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final value = double.tryParse(match.group(1)!);
          if (value != null && value > 0 && value < 1000) {
            debugPrint('  → Found cost $value in line: $line');
            if (largestAmount == null || value > largestAmount) {
              largestAmount = value;
            }
          }
        }
      }
    }
    
    // Fallback: find the largest dollar amount that appears multiple times (likely the total)
    if (largestAmount == null) {
      debugPrint('  → Trying fallback cost detection...');
      final dollarAmounts = <double>[];
      for (final line in lines) {
        final matches = RegExp(r'\$?\s*(\d+\.\d{2})').allMatches(line);
        for (final match in matches) {
          final value = double.tryParse(match.group(1)!);
          if (value != null && value > 5 && value < 500) {
            dollarAmounts.add(value);
            debugPrint('  → Found dollar amount: $value');
          }
        }
      }
      
      // Find most common amount (likely the total that appears multiple times)
      if (dollarAmounts.isNotEmpty) {
        final counts = <double, int>{};
        for (final amount in dollarAmounts) {
          counts[amount] = (counts[amount] ?? 0) + 1;
        }
        // Get the amount that appears most or is largest
        largestAmount = counts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
        debugPrint('  → Selected most common amount as total: $largestAmount');
      }
    }
    
    return largestAmount;
  }
  
  static double? _extractPricePerGallon(List<String> lines, String fullText) {
    // More comprehensive price per gallon patterns
    final pricePatterns = [
      RegExp(r'PRICE[/\s]*GAL[:\s]*\$?\s*(\d+\.?\d*)'), // PRICE/GAL: $X.XX
      RegExp(r'\$?\s*(\d+\.?\d*)\s*/\s*GAL'), // $X.XX/GAL
      RegExp(r'RATE[:\s]*\$?\s*(\d+\.?\d*)'), // RATE: $X.XX
      RegExp(r'PPG[:\s]*\$?\s*(\d+\.?\d*)'), // PPG: $X.XX
      RegExp(r'UNIT\s*PRICE[:\s]*\$?\s*(\d+\.?\d*)'), // UNIT PRICE: $X.XX
    ];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Special handling for PRICE/GAL lines
      if (line.contains('PRICE') && line.contains('GAL')) {
        debugPrint('  → Found PRICE/GAL line: $line');
        
        // First check same line
        final priceMatch = RegExp(r'[S\$]\s*(\d+)\.(\d+)').firstMatch(line);
        if (priceMatch != null) {
          final wholePart = priceMatch.group(1)!;
          final decimalPart = priceMatch.group(2)!;
          final value = double.tryParse('$wholePart.$decimalPart');
          if (value != null && value > 1.0 && value < 10.0) {
            debugPrint('  → Extracted price/gal from same line: $value');
            return value;
          }
        }
        
        // Check next line
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          debugPrint('  → Checking next line for price: $nextLine');
          final nextLinePrice = RegExp(r'\$(\d+\.?\d+)').firstMatch(nextLine);
          if (nextLinePrice != null) {
            final value = double.tryParse(nextLinePrice.group(1)!);
            if (value != null && value > 1.0 && value < 10.0) {
              debugPrint('  → Extracted price/gal from next line: $value');
              return value;
            }
          }
        }
      }
      
      for (final pattern in pricePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final value = double.tryParse(match.group(1)!);
          // Gas prices typically between $1.50 and $7.00
          if (value != null && value > 1.0 && value < 10.0) {
            debugPrint('  → Matched price/gal in line: $line');
            return value;
          }
        }
      }
    }
    
    return null;
  }
  
  static String? _extractFuelGrade(List<String> lines, String fullText) {
    // More comprehensive fuel grade keywords
    final gradeKeywords = {
      'DIESEL': 'Diesel',
      'TRUCK DIESEL': 'Diesel',
      'REGULAR': '87 Regular',
      'REG': '87 Regular',
      'UNLEADED': '87 Regular',
      'PLUS': '89 Plus',
      'MID-GRADE': '89 Plus',
      'MIDGRADE': '89 Plus',
      'PREMIUM': '91 Premium',
      'SUPER': '91 Premium',
      'SUPREME': '91 Premium',
      'V-POWER': '93 Premium',
      'E85': 'E85',
      'ETHANOL': 'E85',
    };
    
    // First pass: look for explicit fuel type keywords
    for (final line in lines) {
      for (final keyword in gradeKeywords.keys) {
        if (line.toUpperCase().contains(keyword)) {
          debugPrint('  → Matched fuel grade "$keyword" in line: $line');
          return gradeKeywords[keyword];
        }
      }
    }
    
    // Second pass: look for grade numbers (87, 89, 91, 93) but only in context
    final numberGrades = {
      '87': '87 Regular',
      '89': '89 Plus',
      '91': '91 Premium',
      '93': '93 Premium',
    };
    
    for (final line in lines) {
      // Only match if the line is short and likely about fuel grade
      if (line.length < 20 && !line.contains('ZIP') && !line.contains('37919')) {
        for (final grade in numberGrades.keys) {
          if (line.contains(grade) && !RegExp(r'\d{5}').hasMatch(line)) {
            debugPrint('  → Matched fuel grade number "$grade" in line: $line');
            return numberGrades[grade];
          }
        }
      }
    }
    
    return '87 Regular'; // Default
  }
  
  static String? _extractLocation(List<String> lines) {
    // Try to get the first few lines which usually contain station name
    if (lines.isEmpty) return null;
    
    // Look for common gas station names (expanded list)
    final stationNames = [
      'SHELL', 'CHEVRON', 'EXXON', 'MOBIL', 'BP', 'ARCO', 
      'MARATHON', 'SUNOCO', 'VALERO', '76', 'CITGO', 'PHILLIPS',
      'COSTCO', 'SAM', 'SPEEDWAY', 'CIRCLE K', '7-ELEVEN', 'WAWA',
      'GULF', 'CONOCO', 'TEXACO', 'SINCLAIR', 'AMOCO', 'HESS',
      'LOVES', 'PILOT', 'FLYING J', 'RACETRAC', 'SHEETZ', 'QT',
      'QUICKTRIP', 'CASEY', 'KWIK', 'MAVERIK', 'HOLIDAY',
    ];
    
    for (final line in lines.take(8)) {
      for (final station in stationNames) {
        if (line.contains(station)) {
          final cleaned = _cleanLocationName(line);
          debugPrint('  → Matched location in line: $line');
          return cleaned;
        }
      }
    }
    
    // If no known station, try first non-empty line
    for (final line in lines.take(3)) {
      if (line.trim().length > 3 && 
          !line.contains('RECEIPT') && 
          !line.contains('THANK') &&
          !line.contains('TOTAL')) {
        final cleaned = _cleanLocationName(line);
        debugPrint('  → Using first line as location: $cleaned');
        return cleaned;
      }
    }
    
    return null;
  }
  
  static String _cleanLocationName(String name) {
    // Remove common receipt artifacts
    return name
        .replaceAll(RegExp(r'[#*@]'), '')
        .replaceAll(RegExp(r'\d{3,}'), '') // Remove long numbers
        .replaceAll(RegExp(r'STORE|STATION|NUMBER|NO\.'), '')
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(3) // Take first 3 words
        .join(' ');
  }
  
  static String? _extractPaymentMethod(List<String> lines, String fullText) {
    if (fullText.contains('CREDIT') || fullText.contains('CARD')) {
      return 'Card';
    } else if (fullText.contains('CASH')) {
      return 'Cash';
    } else if (fullText.contains('DEBIT')) {
      return 'Card';
    } else if (fullText.contains('VISA') || fullText.contains('MASTERCARD') || 
               fullText.contains('AMEX') || fullText.contains('DISCOVER')) {
      return 'Card';
    }
    
    return 'Card'; // Default
  }
}