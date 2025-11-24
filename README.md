# FuelTrack Pro 🚗⛽

A modern, accurate fuel economy tracking app built with Flutter that uses the **gold standard tank-to-tank method** for MPG calculations. Features receipt scanning with OCR, multi-vehicle support, and comprehensive analytics with an adaptive UI that seamlessly transitions between iOS and Android.

<p align="center">
  <img src="https://github.com/user-attachments/assets/f9463b8a-4cb1-4c24-a846-6d870cbce334" width="30%" />
  <img src="https://github.com/user-attachments/assets/1a762da4-db9c-4a2a-ba9e-c609aed6fd2c" width="30%" />
  <img src="https://github.com/user-attachments/assets/06834093-7f7b-4fd5-a309-da939b515f8c" width="30%" />
  <img src="https://github.com/user-attachments/assets/b4bf7d2e-a1a1-40ba-a0c4-f56666240eb9" width="30%" />
</p>


## 🎯 What It Does

FuelTrack Pro helps you track your vehicle's real-world fuel economy with scientific accuracy. Unlike apps that rely on unreliable DTE (Distance to Empty) sensors or estimates, we use the proven tank-to-tank calculation method that matches EPA testing standards.

### Core Features

#### 📊 Accurate Fuel Tracking
- **Tank-to-Tank Method**: The gold standard for MPG calculation
```
  MPG = (Current Odometer - Previous Odometer) / Gallons Added
```
- **Smart Fill Detection**: Automatically separates full tank fills from partial fills for data accuracy
- **Optional DTE Monitoring**: Track Distance-to-Empty for real-time insights between fill-ups (not used for historical accuracy)
- **Detailed Records**: Store gallons, costs, locations, fuel grades, payment methods, and driving conditions

#### 📸 Receipt Scanning (OCR)
- **Auto-Extract Data**: Snap a photo of your gas receipt and automatically extract:
  - Date and time
  - Gallons purchased
  - Total cost
  - Price per gallon
  - Fuel grade
  - Station location
- **Smart Parsing**: Advanced algorithms handle various receipt formats from different gas stations
- **Manual Override**: Review and edit any extracted data before saving

#### 🚗 Multi-Vehicle Management
- **Unlimited Vehicles**: Track multiple cars, trucks, motorcycles
- **Vehicle Profiles**: Store make, model, year, EPA ratings, tank capacity
- **Vehicle Photos**: Add custom images for each vehicle
- **Quick Switching**: Easily switch between vehicles to log fill-ups
- **Individual Analytics**: Each vehicle maintains its own complete fuel history and statistics

#### 📈 Comprehensive Analytics
- **Real MPG vs EPA Ratings**: See how your actual fuel economy compares to manufacturer estimates
- **City/Highway Split Analysis**: Track driving patterns and their impact on efficiency
- **Cost Tracking**: Monitor fuel expenses, average cost per gallon, and cost per mile
- **Trend Visualization**: Beautiful charts showing MPG trends over time
- **Best/Worst Performance**: Identify your most and least efficient fill-ups
- **Efficiency Insights**: Track improvements or declines in fuel economy with smart alerts

#### 💡 Smart Insights
- **Driving Style Analysis**: Understand how your habits affect fuel consumption
- **Cost Optimization**: Compare your costs and efficiency against EPA ratings
- **Efficiency Trends**: Monitor patterns and receive alerts for unusual drops
- **Maintenance Indicators**: Spot efficiency drops that may indicate vehicle issues

### Modern UI/UX
- **Adaptive Design**: Native iOS Cupertino and Android Material Design interfaces
- **Dark Theme**: Beautiful dark mode with liquid glass aesthetics
- **Smooth Animations**: Fluid transitions and interactions throughout
- **Intuitive Navigation**: Bottom tab navigation with quick-access floating action buttons
- **Swipe Actions**: Edit or delete fill-ups with intuitive swipe gestures

## 🎨 Design Philosophy

### Why Tank-to-Tank is Superior

This app uses the **tank-to-tank method**, which is the most accurate way to calculate real-world MPG:

**The Method:**
```
MPG = (Current Odometer - Previous Odometer) / Gallons Added
```

**Why It Works:**
- ✅ Eliminates DTE sensor inaccuracies (sensors can be off by 10-20%)
- ✅ Accounts for real-world conditions (weather, traffic, terrain)
- ✅ Provides consistent, comparable data across all vehicles
- ✅ Matches EPA testing methodology
- ✅ Only requires two data points: odometer reading and gallons added

**Optional DTE Tracking:**
While not used for historical accuracy, DTE values are optionally tracked for:
- Real-time efficiency monitoring between fill-ups
- Predicting range on current tank
- Identifying sudden efficiency changes
- Early warning of potential issues

## 🛠 Tech Stack

- **Framework**: Flutter 3.x with Dart 3.x
- **UI Package**: [adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui) for seamless platform adaptation
- **Database**: SQLite with sqflite for local data persistence
- **OCR**: Google ML Kit Text Recognition for receipt scanning
- **Image Handling**: image_picker for camera/gallery access
- **Architecture**: Clean architecture with separated concerns
- **State Management**: StatefulWidget (easily expandable to Provider/Riverpod/Bloc)
- **Platform Support**: iOS 11+ and Android 5.0+ (API 21+)

## 📱 App Structure

### Screens
- **Home**: Dashboard showing current vehicle, combined MPG, and recent fill-ups
- **History**: Complete fill-up history with swipe-to-edit/delete actions
- **Stats**: Detailed analytics with charts, trends, and insights
- **Garage**: Multi-vehicle management with vehicle profiles and photos
- **Add Fill-Up**: Manual entry form with all fuel tracking fields
- **Receipt Scanner**: OCR-powered receipt scanning with auto-population
- **Onboarding**: First-time setup for adding your first vehicle

### Data Models
- **VehicleProfile**: Stores vehicle details, EPA ratings, and metadata
- **FillupRecord**: Complete fill-up data with MPG calculations
- **FuelStats**: Aggregated statistics and analytics per vehicle

## 🚀 Current Feature Status

### ✅ Implemented
- [x] Tank-to-tank MPG calculation
- [x] Full vs partial fill tracking
- [x] Multi-vehicle support with photos
- [x] Receipt scanning with OCR
- [x] SQLite database persistence
- [x] Comprehensive analytics and charts
- [x] City/Highway driving split
- [x] Cost tracking (per gallon, per mile, total)
- [x] EPA comparison
- [x] Swipe-to-edit/delete
- [x] Dark mode with adaptive UI
- [x] Onboarding flow

### 🔮 Future Roadmap
- [ ] Export data (CSV, PDF reports)
- [ ] Cloud backup & sync
- [ ] Home screen widgets
- [ ] Fuel price tracking & alerts
- [ ] Maintenance reminders based on mileage
- [ ] Trip computer integration
- [ ] Gamification (achievements, streaks)
- [ ] Social features (compare with friends)
- [ ] Weather impact correlation

## 📊 Why Accurate Tracking Matters

**For Your Wallet:**
- Identify inefficient driving patterns costing you money
- Track the true cost per mile of vehicle operation
- Compare fuel costs across different stations and grades

**For Your Vehicle:**
- Spot efficiency drops that indicate maintenance needs
- Monitor the impact of different fuel grades
- Track long-term vehicle performance

**For Your Knowledge:**
- Understand how driving style affects fuel economy
- See real-world MPG vs manufacturer claims
- Make informed decisions about future vehicle purchases

## 🎯 Who It's For

- **Daily Commuters**: Track how your daily driving affects fuel costs
- **Fleet Managers**: Monitor multiple vehicles' efficiency (future feature)
- **Car Enthusiasts**: Get detailed data on your vehicle's performance
- **Budget-Conscious Drivers**: Optimize fuel spending with data-driven insights
- **Anyone Who Cares**: About accuracy, data, and understanding their vehicle

## 📖 How to Use

1. **Add Your Vehicle**: Create a profile with make, model, year, and optional EPA ratings
2. **Log Fill-Ups**: Either:
   - Scan your receipt with the camera
   - Manually enter odometer, gallons, and cost
3. **Track Efficiency**: After 2+ full tank fills, see your accurate tank-to-tank MPG
4. **Analyze Trends**: View detailed statistics, charts, and insights
5. **Optimize**: Use the data to improve your fuel efficiency and reduce costs

## 💡 Pro Tips

- **Always fill to "full"** for most accurate MPG calculations
- **Partial fills are tracked separately** - they won't skew your data
- **DTE is optional** - it's helpful for real-time monitoring but not required
- **Log immediately** after filling up to avoid forgetting details
- **Use receipt scanning** to save time and reduce data entry errors
- **Track city/highway split** to understand different driving conditions

## ⚠️ Important Notes

- This app is designed for **personal fuel economy tracking**
- MPG calculations require at least 2 full tank fill-ups
- Partial fills are tracked but don't contribute to historical MPG
- DTE readings are estimates and may vary from actual range
- Always consult a professional mechanic for vehicle concerns

---

**Built with ❤️ using Flutter** | Dark mode liquid glass aesthetics | Adaptive iOS/Android UI
