# FuelTrack Pro 🚗⛽

A modern, accurate fuel economy tracking app built with Flutter that uses the **gold standard tank-to-tank method** for MPG calculations. Features adaptive UI that seamlessly transitions between iOS and Android with native-feeling interfaces.

## 🎯 Key Features

### Accurate Fuel Tracking
- **Tank-to-Tank Method**: The scientifically accurate way to calculate real-world MPG
- **Full vs Partial Fills**: Smart tracking that separates partial fills for data accuracy
- **DTE Monitoring**: Optional Distance-to-Empty tracking for real-time efficiency insights
- **Detailed Fill-Up Records**: Track gallons, costs, locations, fuel grades, and payment methods

### Comprehensive Analytics
- **Real MPG vs EPA Ratings**: See how your actual fuel economy compares
- **City/Highway Split Analysis**: Track driving patterns and their impact on efficiency
- **Cost Tracking**: Monitor fuel expenses, cost per gallon, and cost per mile
- **Trend Visualization**: Beautiful charts showing MPG trends over time
- **Best/Worst Performance**: Identify your most and least efficient fill-ups

### Smart Insights
- **Efficiency Trends**: Track improvements or declines in fuel economy
- **Cost Optimization**: Compare your costs against average drivers
- **Driving Style Analysis**: Understand how your habits affect fuel consumption
- **Maintenance Alerts**: Get notified of efficiency drops that may indicate issues

### Modern UI/UX
- **Adaptive Design**: Native iOS Cupertino and Android Material Design
- **Dark Theme**: Beautiful dark mode with liquid glass aesthetics
- **Smooth Animations**: Fluid transitions and interactions
- **Intuitive Navigation**: Bottom tab navigation with floating action button

## 📱 Screenshots

> Coming soon - Add your screenshots here

## 🛠 Tech Stack

- **Framework**: Flutter 3.x
- **UI Package**: [adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui)
- **Architecture**: Clean architecture with separated concerns
- **State Management**: StatefulWidget (expandable to Provider/Riverpod)
- **Platform Support**: iOS, Android (with native platform adaptations)

## 📦 Installation

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- iOS: Xcode 14+ (for iOS development)
- Android: Android Studio with SDK 21+

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/fueltrack-pro.git
   cd fueltrack-pro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   ```

## 🏗 Project Structure

```
lib/
├── main.dart                    # App entry point & navigation
├── models/
│   └── fillup_record.dart       # Data models for fill-ups and vehicle profiles
└── screens/
    ├── home_screen.dart         # Dashboard with key stats
    ├── add_fillup_screen.dart   # Add new fill-up form
    ├── history_screen.dart      # Fill-up history list
    └── stats_screen.dart        # Detailed analytics and charts
```

## 🎨 Design Philosophy

### Accurate MPG Calculation
This app uses the **tank-to-tank method**, which is the most accurate way to calculate real-world MPG:

```
MPG = (Current Odometer - Previous Odometer) / Gallons Added
```

This method:
- ✅ Eliminates DTE sensor inaccuracies
- ✅ Accounts for real-world conditions
- ✅ Provides consistent, comparable data
- ✅ Matches EPA testing methodology

### Optional DTE Tracking
While not used for historical accuracy, DTE values are tracked for:
- Real-time efficiency monitoring between fill-ups
- Predicting range on current tank
- Identifying sudden efficiency changes
- Early warning of potential issues

## 🚀 Roadmap

- [ ] Local database persistence (SQLite)
- [ ] Multiple vehicle support
- [ ] Export data (CSV, PDF reports)
- [ ] Backup & sync (cloud storage)
- [ ] Widgets for at-a-glance stats
- [ ] Fuel price tracking & alerts
- [ ] Trip computer integration
- [ ] Gamification (achievements, streaks)
- [ ] Social features (compare with friends)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Commit Convention
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [adaptive_platform_ui](https://pub.dev/packages/adaptive_platform_ui) for seamless platform adaptation
- Flutter team for the amazing framework
- All fuel tracking enthusiasts who understand the importance of accurate data

## 📧 Contact

Your Name - [@yourtwitter](https://twitter.com/yourtwitter)

Project Link: [https://github.com/YOUR_USERNAME/fueltrack-pro](https://github.com/YOUR_USERNAME/fueltrack-pro)

---

**Note**: This app is designed for personal fuel economy tracking and should not be used as the sole indicator for vehicle health or performance issues. Always consult a professional mechanic for vehicle concerns.