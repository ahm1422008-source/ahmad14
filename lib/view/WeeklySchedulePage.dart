import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeeklySchedulePage extends StatefulWidget {
  const WeeklySchedulePage({Key? key}) : super(key: key);

  @override
  State<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Schedule data structure - [rowIndex][day] = employeeName
  Map<int, Map<String, String>> weeklySchedule = {};

  // Time slots - now editable
  Map<int, String> timeSlots = {};

  // Days of the week
  List<String> weekDays = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  // Employee colors mapping
  Map<String, Color> employeeColors = {};
  List<Color> availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.pink,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
  ];
  int colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSchedule();
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

  void _initializeSchedule() {
    // Initialize empty schedule
    for (int i = 0; i < 7; i++) {
      timeSlots[i] = '';
      weeklySchedule[i] = {};
      for (String day in weekDays) {
        weeklySchedule[i]![day] = '';
      }
    }
  }

  Color _getEmployeeColor(String employeeName) {
    if (employeeName.isEmpty) return Colors.transparent;

    if (!employeeColors.containsKey(employeeName)) {
      employeeColors[employeeName] = availableColors[colorIndex % availableColors.length];
      colorIndex++;
    }
    return employeeColors[employeeName]!;
  }

  void _editCell(int rowIndex, String day) {
    TextEditingController controller = TextEditingController();
    controller.text = weeklySchedule[rowIndex]![day]!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'تعديل: $day',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'اسم الموظف',
            hintText: 'أدخل اسم الموظف أو اتركه فارغاً',
            prefixIcon: const Icon(Icons.person, color: Color(0xFF007bff)),
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
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007bff),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                weeklySchedule[rowIndex]![day] = controller.text.trim();
              });
              Navigator.pop(context);
              HapticFeedback.selectionClick();
            },
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editTimeSlot(int rowIndex) {
    TextEditingController controller = TextEditingController();
    controller.text = timeSlots[rowIndex]!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'تعديل الساعات',
          style: TextStyle(color: Colors.white),
        ),
        content: TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'ساعات العمل',
            hintText: 'مثال: 09:00-17:00',
            prefixIcon: const Icon(Icons.access_time, color: Color(0xFF007bff)),
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
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007bff),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                timeSlots[rowIndex] = controller.text.trim();
              });
              Navigator.pop(context);
              HapticFeedback.selectionClick();
            },
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('مسح الجدول', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل تريد مسح جميع البيانات من الجدول؟',
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
                _initializeSchedule();
                employeeColors.clear();
                colorIndex = 0;
              });
              Navigator.pop(context);
              HapticFeedback.heavyImpact();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح الجدول بنجاح'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('مسح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _printSchedule() {
    // Here you can implement printing functionality
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.print, color: Colors.white),
            SizedBox(width: 8),
            Text('جاري تحضير الجدول للطباعة...'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 25,
                      shadowColor: Colors.blue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
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
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF007bff), Color(0xFF0056b3)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF007bff).withOpacity(0.5),
                                          blurRadius: 25,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.view_week_rounded,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // Title
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF007bff), Color(0xFF87ceeb)],
                              ).createShader(bounds),
                              child: const Text(
                                'الجدول الأسبوعي',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'جدول مواعيد العمل التفاعلي',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Control buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _clearSchedule,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('مسح الكل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _printSchedule,
                            icon: const Icon(Icons.print),
                            label: const Text('طباعة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007bff),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Schedule Table
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                  (states) => const Color(0xFF34495e),
                            ),
                            headingTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            dataRowHeight: 60,
                            headingRowHeight: 50,
                            columnSpacing: 20,
                            columns: [
                              const DataColumn(
                                label: SizedBox(
                                  width: 100,
                                  child: Text(
                                    'ساعات العمل',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              ...weekDays.map((day) => DataColumn(
                                label: SizedBox(
                                  width: 100,
                                  child: Text(
                                    day,
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )),
                            ],
                            rows: List.generate(7, (rowIndex) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    GestureDetector(
                                      onTap: () => _editTimeSlot(rowIndex),
                                      child: Container(
                                        width: 100,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFecf0f1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[400]!),
                                        ),
                                        child: Text(
                                          timeSlots[rowIndex]!.isEmpty
                                              ? 'اضغط للوقت'
                                              : timeSlots[rowIndex]!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: timeSlots[rowIndex]!.isEmpty
                                                ? Colors.grey[600]
                                                : const Color(0xFF2c3e50),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...weekDays.map((day) {
                                    String employeeName = weeklySchedule[rowIndex]![day]!;
                                    Color cellColor = _getEmployeeColor(employeeName);

                                    return DataCell(
                                      GestureDetector(
                                        onTap: () => _editCell(rowIndex, day),
                                        child: Container(
                                          width: 100,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: employeeName.isNotEmpty
                                                ? cellColor.withOpacity(0.7)
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: employeeName.isNotEmpty
                                                  ? cellColor
                                                  : Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              employeeName.isEmpty ? 'اضغط للكتابة' : employeeName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: employeeName.isNotEmpty
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Back Button
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('العودة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF007bff),
                          side: const BorderSide(color: Color(0xFF007bff)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}