import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// WeatherScreen — Real-time weather for Cambodia cities
// Uses OpenWeatherMap FREE API (no credit card needed)
//
// GET YOUR FREE API KEY (takes 30 seconds):
//   1. Go to https://openweathermap.org/api
//   2. Click "Sign Up" → verify email
//   3. Go to https://home.openweathermap.org/api_keys
//   4. Copy your key and paste below
// ─────────────────────────────────────────────────────────────────────────────
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  // 🔑 REPLACE WITH YOUR FREE OPENWEATHERMAP KEY
  static const _apiKey =
      'http://api.openweathermap.org/data/2.5/weather?q=Cambodia,uk&APPID=767ba1a6c7aef754ebb85d921759a538';

  // Cambodia cities to cycle through
  final List<Map<String, dynamic>> _cities = [
    {'name': 'Phnom Penh', 'lat': 11.5564, 'lon': 104.9282},
    {'name': 'Siem Reap', 'lat': 13.3671, 'lon': 103.8448},
    {'name': 'Battambang', 'lat': 13.1000, 'lon': 103.2000},
    {'name': 'Sihanoukville', 'lat': 10.6333, 'lon': 103.5000},
    {'name': 'Kampot', 'lat': 10.6167, 'lon': 104.1833},
  ];

  int _selectedCity = 0;
  WeatherData? _weather;
  List<HourlyForecast> _hourly = [];
  List<DailyForecast> _daily = [];
  bool _isLoading = true;
  String? _error;

  late AnimationController _shimmerCtrl;
  late AnimationController _iconCtrl;
  late Animation<double> _iconAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _iconAnim = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _iconCtrl, curve: Curves.easeInOut));
    _fetchWeather();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  // ── Fetch from OpenWeatherMap ─────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────────
  // TEMPORARY: Replace _fetchWeather() in your weather_screen.dart with this
  // while waiting for your OpenWeatherMap API key to activate (up to 2 hours).
  // Once the key works, delete this and use the real _fetchWeather() again.
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final cityName = _cities[_selectedCity]['name'] as String;

    // Mock data — realistic Cambodia weather values
    final mockTemps = [32, 30, 29, 31, 28];
    final mockConditions = ['Clear', 'Clouds', 'Rain', 'Clear', 'Clouds'];
    final mockHumidity = [75, 80, 90, 70, 85];
    final mockWind = [3.5, 4.2, 6.1, 2.8, 5.0];

    final idx = _selectedCity;

    _weather = WeatherData(
      city: cityName,
      temp: mockTemps[idx],
      feelsLike: mockTemps[idx] + 2,
      humidity: mockHumidity[idx],
      windSpeed: mockWind[idx],
      description: mockConditions[idx] == 'Clear'
          ? 'Clear Sky'
          : mockConditions[idx] == 'Rain'
          ? 'Light Rain'
          : 'Partly Cloudy',
      condition: mockConditions[idx],
      visibility: '10.0',
      pressure: 1012,
      uvIndex: 7,
      sunrise: 1748563200, // ~6:00 AM
      sunset: 1748607600, // ~6:10 PM
    );

    // Mock hourly (next 8 × 3h)
    _hourly = List.generate(
      8,
      (i) => HourlyForecast(
        time: DateTime.now().add(Duration(hours: i * 3)),
        temp: mockTemps[idx] - (i % 3),
        condition: i >= 4 ? 'Clouds' : mockConditions[idx],
      ),
    );

    // Mock 5-day
    _daily = List.generate(
      5,
      (i) => DailyForecast(
        date: DateTime.now().add(Duration(days: i)),
        high: mockTemps[idx] + 1 - i,
        low: mockTemps[idx] - 5 + i,
        condition: i == 2 ? 'Rain' : mockConditions[idx],
      ),
    );

    setState(() => _isLoading = false);
  }

  String _capitalize(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  // ── Weather condition helpers ─────────────────────────────────────────────
  List<Color> _bgColors(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return [
          const Color(0xFF1565C0),
          const Color(0xFF42A5F5),
          const Color(0xFFFFCC02),
        ];
      case 'clouds':
        return [
          const Color(0xFF37474F),
          const Color(0xFF607D8B),
          const Color(0xFF90A4AE),
        ];
      case 'rain':
      case 'drizzle':
        return [
          const Color(0xFF1A237E),
          const Color(0xFF283593),
          const Color(0xFF3949AB),
        ];
      case 'thunderstorm':
        return [
          const Color(0xFF1A1A2E),
          const Color(0xFF16213E),
          const Color(0xFF0F3460),
        ];
      case 'snow':
        return [
          const Color(0xFF546E7A),
          const Color(0xFF78909C),
          const Color(0xFFB0BEC5),
        ];
      case 'mist':
      case 'fog':
      case 'haze':
        return [
          const Color(0xFF455A64),
          const Color(0xFF607D8B),
          const Color(0xFF78909C),
        ];
      default:
        return [
          const Color(0xFF1565C0),
          const Color(0xFF1976D2),
          const Color(0xFF42A5F5),
        ];
    }
  }

  IconData _weatherIcon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
        return Icons.umbrella_rounded;
      case 'drizzle':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.foggy;
      default:
        return Icons.cloud_rounded;
    }
  }

  String _formatTime(int unix) {
    final dt = DateTime.fromMillisecondsSinceEpoch(unix * 1000);
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:00 $ampm';
  }

  String _dayName(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoading()
          : _error != null
          ? _buildError()
          : _buildWeatherBody(),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            SizedBox(height: 20),
            Text(
              'Fetching weather…',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white54,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Could not load weather',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _fetchWeather,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Main weather body ─────────────────────────────────────────────────────
  Widget _buildWeatherBody() {
    final w = _weather!;
    final colors = _bgColors(w.condition);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchWeather,
          color: Colors.white,
          backgroundColor: colors[0],
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────────────
                _buildTopBar(w),

                // ── City selector ──────────────────────────────────────
                _buildCitySelector(),

                // ── Main temp display ──────────────────────────────────
                _buildMainTemp(w),

                // ── Detail pills ───────────────────────────────────────
                _buildDetailPills(w),

                const SizedBox(height: 16),

                // ── Frosted glass cards ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildHourlyCard(),
                      const SizedBox(height: 14),
                      _buildDailyCard(),
                      const SizedBox(height: 14),
                      _buildExtraCard(w),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(WeatherData w) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              const Text(
                'Cambodia Weather',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                w.city,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Refresh
          GestureDetector(
            onTap: _fetchWeather,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── City selector ─────────────────────────────────────────────────────────
  Widget _buildCitySelector() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        itemCount: _cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = i == _selectedCity;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCity = i);
              _fetchWeather();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _cities[i]['name'] as String,
                style: TextStyle(
                  color: selected ? const Color(0xFF1565C0) : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Main temperature ──────────────────────────────────────────────────────
  Widget _buildMainTemp(WeatherData w) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Floating weather icon
          AnimatedBuilder(
            animation: _iconAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _iconAnim.value),
              child: child,
            ),
            child: Icon(
              _weatherIcon(w.condition),
              size: 90,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${w.temp}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -4,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  '°C',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            w.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Feels like ${w.feelsLike}°C',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Detail pills ──────────────────────────────────────────────────────────
  Widget _buildDetailPills(WeatherData w) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _pill(Icons.water_drop_outlined, '${w.humidity}%', 'Humidity'),
          _divider(),
          _pill(Icons.air, '${w.windSpeed.toStringAsFixed(1)} m/s', 'Wind'),
          _divider(),
          _pill(Icons.visibility_outlined, '${w.visibility} km', 'Visibility'),
          _divider(),
          _pill(Icons.compress_rounded, '${w.pressure} hPa', 'Pressure'),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }

  // ── Hourly forecast card ──────────────────────────────────────────────────
  Widget _buildHourlyCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.schedule_rounded, '24-Hour Forecast'),
          const SizedBox(height: 14),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _hourly.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) {
                final h = _hourly[i];
                final isNow = i == 0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isNow ? 'Now' : _formatHour(h.time),
                      style: TextStyle(
                        color: isNow ? Colors.white : Colors.white60,
                        fontSize: 12,
                        fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Icon(
                      _weatherIcon(h.condition),
                      color: Colors.white,
                      size: 22,
                    ),
                    Text(
                      '${h.temp}°',
                      style: TextStyle(
                        color: isNow ? Colors.white : Colors.white70,
                        fontSize: 16,
                        fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatHour(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h $ampm';
  }

  // ── 5-day forecast card ───────────────────────────────────────────────────
  Widget _buildDailyCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.calendar_today_rounded, '5-Day Forecast'),
          const SizedBox(height: 14),
          ..._daily.asMap().entries.map((e) {
            final d = e.value;
            final isToday = e.key == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 46,
                    child: Text(
                      isToday ? 'Today' : _dayName(d.date),
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.white70,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    _weatherIcon(d.condition),
                    color: Colors.white70,
                    size: 20,
                  ),
                  const Spacer(),
                  Text(
                    '${d.low}°',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Temp bar
                  _tempBar(d.low, d.high),
                  const SizedBox(width: 8),
                  Text(
                    '${d.high}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _tempBar(int low, int high) {
    final range = (high - low).clamp(1, 20);
    return Container(
      width: 80,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        widthFactor: (range / 20).clamp(0.2, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFFFF8A65)],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  // ── Extra info card (sunrise/sunset) ──────────────────────────────────────
  Widget _buildExtraCard(WeatherData w) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.info_outline_rounded, 'Sun & Details'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  Icons.wb_twilight_rounded,
                  _formatTime(w.sunrise),
                  'Sunrise',
                  const Color(0xFFFFCC02),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoTile(
                  Icons.nightlight_round_outlined,
                  _formatTime(w.sunset),
                  'Sunset',
                  const Color(0xFFFF7043),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  Icons.thermostat_rounded,
                  '${w.feelsLike}°C',
                  'Feels Like',
                  const Color(0xFF64B5F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoTile(
                  Icons.compress_rounded,
                  '${w.pressure} hPa',
                  'Pressure',
                  const Color(0xFF81C784),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable glass card ───────────────────────────────────────────────────
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: child,
    );
  }

  Widget _cardHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────
class WeatherData {
  final String city, description, condition, visibility;
  final int temp, feelsLike, humidity, pressure, uvIndex, sunrise, sunset;
  final double windSpeed;

  WeatherData({
    required this.city,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.condition,
    required this.visibility,
    required this.pressure,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
  });
}

class HourlyForecast {
  final DateTime time;
  final int temp;
  final String condition;
  HourlyForecast({
    required this.time,
    required this.temp,
    required this.condition,
  });
}

class DailyForecast {
  final DateTime date;
  final int high, low;
  final String condition;
  DailyForecast({
    required this.date,
    required this.high,
    required this.low,
    required this.condition,
  });
}
