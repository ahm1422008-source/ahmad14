import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeTrackingPage extends StatefulWidget {
  const TimeTrackingPage({Key? key}) : super(key: key);

  @override
  State<TimeTrackingPage> createState() => _TimeTrackingPageState();
}

class _TimeTrackingPageState extends State<TimeTrackingPage>
    with TickerProviderStateMixin {

  // Controllers and Form
  final _formKey = GlobalKey<FormState>();
  final _hourlyRateController = TextEditingController();

  // Time tracking variables
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isWorking = false;
  Duration _totalWorkedTime = Duration.zero;
  double _hourlyRate = 0.0;
  double _dailyEarnings = 0.0;

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _loadSavedData() {
    // هنا يمكن تحميل البيانات المحفوظة من SharedPreferences أو قاعدة البيانات
    // For now, we'll use default values
    _hourlyRateController.text = '50'; // Default 50 شيكل per hour
    _hourlyRate = 50.0;
  }

  void _setHourlyRate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _hourlyRate = double.tryParse(_hourlyRateController.text) ?? 0.0;
      });

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('تم تعيين الراتب: ${_hourlyRate.toStringAsFixed(0)} شيكل/ساعة'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _toggleWork() {
    setState(() {
      if (!_isWorking) {
        // بدء العمل
        _startTime = DateTime.now();
        _isWorking = true;
        HapticFeedback.mediumImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white),
                const SizedBox(width: 8),
                Text('بدء العمل: ${_formatTime(_startTime!)}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        // انتهاء العمل
        _endTime = DateTime.now();
        _isWorking = false;

        if (_startTime != null) {
          Duration sessionTime = _endTime!.difference(_startTime!);
          _totalWorkedTime += sessionTime;
          _calculateDailyEarnings();

          HapticFeedback.heavyImpact();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stop, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('انتهاء العمل: ${_formatTime(_endTime!)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('مدة الجلسة: ${_formatDuration(sessionTime)}'),
                  Text('المكسب: ${(_hourlyRate * sessionTime.inMinutes / 60).toStringAsFixed(2)} شيكل'),
                ],
              ),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }

  void _calculateDailyEarnings() {
    double hoursWorked = _totalWorkedTime.inMinutes / 60.0;
    _dailyEarnings = _hourlyRate * hoursWorked;
  }

  void _resetDay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('إعادة تعيين اليوم', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل تريد إعادة تعيين بيانات اليوم؟ سيتم حذف جميع ساعات العمل والأرباح.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                _startTime = null;
                _endTime = null;
                _isWorking = false;
                _totalWorkedTime = Duration.zero;
                _dailyEarnings = 0.0;
              });
              Navigator.pop(context);

              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعادة تعيين بيانات اليوم'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('إعادة تعيين', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes ساعة';
  }

  String? _validateHourlyRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الراتب بالساعة';
    }
    double? rate = double.tryParse(value);
    if (rate == null || rate <= 0) {
      return 'الرجاء إدخال رقم صحيح أكبر من صفر';
    }
    return null;
  }

  @override
  void dispose() {
    _hourlyRateController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _calculateDailyEarnings();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000000),
              Color(0xFF1a1a2e),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Header Card
                      Card(
                        elevation: 25,
                        shadowColor: Colors.blue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        child: Container(
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1a1a2e), Color(0xFF000000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: const Color(0xFF007bff), width: 1),
                          ),
                          child: Column(
                            children: [
                              // Logo with pulse effect
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: _isWorking
                                              ? [Colors.green, Colors.green[700]!]
                                              : [const Color(0xFF007bff), const Color(0xFF0056b3)],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isWorking ? Colors.green : const Color(0xFF007bff)).withOpacity(0.5),
                                            blurRadius: 25,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isWorking ? Icons.work : Icons.access_time_filled_rounded,
                                        color: Colors.white,
                                        size: 45,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 30),

                              // Title
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: _isWorking
                                      ? [Colors.green, Colors.green[300]!]
                                      : [const Color(0xFF007bff), const Color(0xFF87ceeb)],
                                ).createShader(bounds),
                                child: Text(
                                  _isWorking ? 'WORKING...' : 'TIME TRACKING',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isWorking ? 'جاري العمل الآن' : 'تسجيل أوقات العمل',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isWorking ? Colors.green : Colors.blue,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Hourly Rate Setting Card
                      Card(
                        elevation: 15,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1a1a2e), Color(0xFF000000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: const Color(0xFF007bff).withOpacity(0.3), width: 1),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.payments, color: Colors.blue[300], size: 24),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'تحديد الراتب بالساعة',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _hourlyRateController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: 'الراتب (شيكل)',
                                          hintText: '50',
                                          prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF007bff)),
                                          filled: true,
                                          fillColor: Colors.black.withOpacity(0.3),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: const BorderSide(color: Color(0xFF007bff), width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: const BorderSide(color: Color(0xFF007bff), width: 2),
                                          ),
                                          labelStyle: const TextStyle(color: Colors.blue),
                                          hintStyle: TextStyle(color: Colors.grey[500]),
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: _validateHourlyRate,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _setHourlyRate,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF007bff),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        child: const Text('حفظ'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Work Status and Statistics Card
                      Card(
                        elevation: 15,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1a1a2e), Color(0xFF000000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: const Color(0xFF007bff).withOpacity(0.3), width: 1),
                          ),
                          child: Column(
                            children: [
                              // Statistics
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatCard(
                                    icon: Icons.schedule,
                                    title: 'إجمالي الساعات',
                                    value: _formatDuration(_totalWorkedTime),
                                    color: Colors.blue,
                                  ),
                                  _buildStatCard(
                                    icon: Icons.monetization_on,
                                    title: 'المكسب اليومي',
                                    value: '${_dailyEarnings.toStringAsFixed(2)} ₪',
                                    color: Colors.green,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // Work Toggle Button
                              SizedBox(
                                width: double.infinity,
                                height: 65,
                                child: ElevatedButton(
                                  onPressed: _toggleWork,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isWorking ? Colors.red : Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    shadowColor: (_isWorking ? Colors.red : Colors.green).withOpacity(0.5),
                                    elevation: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isWorking ? Icons.stop : Icons.play_arrow,
                                        size: 30,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _isWorking ? 'إنهاء العمل' : 'بدء العمل',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (_startTime != null) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: (_isWorking ? Colors.green : Colors.blue).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: (_isWorking ? Colors.green : Colors.blue).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'بداية العمل:',
                                            style: TextStyle(color: Colors.grey[300]),
                                          ),
                                          Text(
                                            _formatTime(_startTime!),
                                            style: TextStyle(
                                              color: _isWorking ? Colors.green : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!_isWorking && _endTime != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'نهاية العمل:',
                                              style: TextStyle(color: Colors.grey[300]),
                                            ),
                                            Text(
                                              _formatTime(_endTime!),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _resetDay,
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة تعيين اليوم'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.home),
                              label: const Text('الرئيسية'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF007bff),
                                side: const BorderSide(color: Color(0xFF007bff)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}