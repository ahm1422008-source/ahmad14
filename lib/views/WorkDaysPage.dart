import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// نموذج البيانات
class WorkRequest {
  final String id;
  final String employeeName;
  final String employeeId;
  final Map<String, bool> workSchedule;
  final String notes;
  final DateTime submittedAt;
  WorkRequestStatus status;

  WorkRequest({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.workSchedule,
    required this.notes,
    required this.submittedAt,
    this.status = WorkRequestStatus.pending,
  });
}

enum WorkRequestStatus { pending, approved, rejected }

// الكلاس الأساسي لإدارة البيانات (Singleton)
class WorkRequestManager {
  static final WorkRequestManager _instance = WorkRequestManager._internal();
  factory WorkRequestManager() => _instance;
  WorkRequestManager._internal();

  final List<WorkRequest> _requests = [];

  List<WorkRequest> get requests => List.unmodifiable(_requests);

  void addRequest(WorkRequest request) {
    _requests.add(request);
  }

  void updateRequestStatus(String id, WorkRequestStatus status) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _requests[index].status = status;
    }
  }

  void removeRequest(String id) {
    _requests.removeWhere((r) => r.id == id);
  }

  List<WorkRequest> getPendingRequests() {
    return _requests.where((r) => r.status == WorkRequestStatus.pending).toList();
  }

  List<WorkRequest> getApprovedRequests() {
    return _requests.where((r) => r.status == WorkRequestStatus.approved).toList();
  }
}

// كلاس صفحة المدير - مبسط للاستيراد
class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({Key? key}) : super(key: key);

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  final WorkRequestManager _requestManager = WorkRequestManager();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _requestManager.getPendingRequests().length;
    final approvedCount = _requestManager.getApprovedRequests().length;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  Card(
                    elevation: 25,
                    shadowColor: Colors.purple.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1a1a2e), Color(0xFF000000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: const Color(0xFF8e2de2), width: 1),
                      ),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8e2de2), Color(0xFF4a00e0)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8e2de2).withOpacity(0.5),
                                        blurRadius: 25,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF8e2de2), Color(0xFFff6ec7)],
                            ).createShader(bounds),
                            child: const Text(
                              'MANAGER DASHBOARD',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'إدارة طلبات العمال وجداول العمل',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'الطلبات المعلقة',
                          value: '$pendingCount',
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          title: 'الطلبات المعتمدة',
                          value: '$approvedCount',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Recent Requests
                  if (_requestManager.requests.isNotEmpty) ...[
                    Card(
                      elevation: 15,
                      shadowColor: Colors.blue.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.history, color: Colors.blue, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'آخر الطلبات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            ..._requestManager.requests.take(3).map((request) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(request.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _getStatusColor(request.status).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: _getStatusColor(request.status).withOpacity(0.2),
                                      child: Text(
                                        request.employeeName.split(' ').map((e) => e[0]).take(2).join(),
                                        style: TextStyle(
                                          color: _getStatusColor(request.status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            request.employeeName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _getTimeAgo(request.submittedAt),
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(request.status),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getStatusText(request.status),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                            const SizedBox(height: 10),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  // إظهار جميع الطلبات - يمكن تطويره لاحقاً
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('ميزة عرض جميع الطلبات قيد التطوير'),
                                      backgroundColor: Color(0xFF8e2de2),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'عرض جميع الطلبات',
                                  style: TextStyle(color: Color(0xFF8e2de2)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Empty State
                    Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1a1a2e), Color(0xFF000000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 60,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'لا توجد طلبات حتى الآن',
                              style: TextStyle(
                                color: Colors.grey.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ستظهر هنا طلبات الموظفين عندما يتم إرسالها',
                              style: TextStyle(
                                color: Colors.grey.withOpacity(0.5),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF8e2de2)),
                      label: const Text(
                        'العودة',
                        style: TextStyle(color: Color(0xFF8e2de2)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8e2de2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 10,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(WorkRequestStatus status) {
    switch (status) {
      case WorkRequestStatus.pending:
        return Colors.orange;
      case WorkRequestStatus.approved:
        return Colors.green;
      case WorkRequestStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(WorkRequestStatus status) {
    switch (status) {
      case WorkRequestStatus.pending:
        return 'معلق';
      case WorkRequestStatus.approved:
        return 'معتمد';
      case WorkRequestStatus.rejected:
        return 'مرفوض';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}د';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}س';
    } else {
      return '${difference.inDays}ي';
    }
  }
}

// صفحة العامل الرئيسية
class WorkDaysPage extends StatefulWidget {
  const WorkDaysPage({Key? key}) : super(key: key);

  @override
  State<WorkDaysPage> createState() => _WorkDaysPageState();
}

class _WorkDaysPageState extends State<WorkDaysPage>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  // Work schedule data (simplified - no times)
  Map<String, bool> workSchedule = {
    'الأحد': true,
    'الإثنين': true,
    'الثلاثاء': true,
    'الأربعاء': true,
    'الخميس': true,
    'الجمعة': false,
    'السبت': false,
  };

  String selectedEmployeeName = '';
  String savedNotes = '';
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDefaultSchedule();
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

    _floatController = AnimationController(
      duration: const Duration(seconds: 6),
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

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: -5.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _loadDefaultSchedule() {
    selectedEmployeeName = 'أحمد محمد';
    _employeeNameController.text = selectedEmployeeName;
  }

  void _toggleWorkDay(String dayName) {
    setState(() {
      workSchedule[dayName] = !workSchedule[dayName]!;
    });
    HapticFeedback.selectionClick();
  }

  void _openNotesModal() {
    _notesController.text = savedNotes;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1a1a2e), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8e2de2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8e2de2).withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note, color: Color(0xFF8e2de2), size: 24),
                        SizedBox(width: 10),
                        Text(
                          'إضافة ملاحظات',
                          style: TextStyle(
                            color: Color(0xFF8e2de2),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Textarea
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF8e2de2), width: 2),
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'اكتب ملاحظاتك هنا...\nمثل:\n• يفضل العمل من المنزل يوم الخميس\n• لديه موعد طبي يوم الثلاثاء\n• متاح للعمل الإضافي',
                      hintStyle: TextStyle(color: Colors.grey, height: 1.5),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildAnimatedButton(
                        onPressed: () {
                          setState(() {
                            savedNotes = _notesController.text.trim();
                          });
                          Navigator.of(context).pop();
                          _showNotesConfirmation();
                        },
                        text: 'حفظ الملاحظات',
                        icon: Icons.save,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00c851), Color(0xFF00a844)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.cancel, color: Colors.grey),
                        label: const Text(
                          'إلغاء',
                          style: TextStyle(color: Colors.grey),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotesConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('تم حفظ الملاحظات بنجاح'),
          ],
        ),
        backgroundColor: const Color(0xFF00c851),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _saveSchedule() {
    if (selectedEmployeeName.isEmpty) {
      _showErrorMessage('الرجاء إدخال اسم الموظف');
      return;
    }

    HapticFeedback.heavyImpact();

    // إنشاء طلب جديد وإرساله للمدير
    final newRequest = WorkRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeName: selectedEmployeeName,
      employeeId: 'EMP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      workSchedule: Map.from(workSchedule),
      notes: savedNotes,
      submittedAt: DateTime.now(),
    );

    // إضافة الطلب إلى مدير الطلبات
    WorkRequestManager().addRequest(newRequest);

    int workDaysCount = workSchedule.values.where((isWorkDay) => isWorkDay).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.send, color: Colors.green, size: 30),
            SizedBox(width: 12),
            Text('تم إرسال الطلب بنجاح', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الموظف: $selectedEmployeeName',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('عدد أيام العمل: $workDaysCount أيام',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('عدد أيام الإجازة: ${7 - workDaysCount} أيام',
                style: const TextStyle(color: Colors.white70)),
            if (savedNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'الملاحظات: ${savedNotes.length > 50 ? '${savedNotes.substring(0, 50)}...' : savedNotes}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Text(
                'تم إرسال طلبك إلى المدير وسيتم مراجعته قريباً',
                style: TextStyle(color: Colors.blue, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8e2de2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showManagerDashboardOption();
            },
            icon: const Icon(Icons.dashboard, color: Colors.white, size: 18),
            label: const Text('عرض لوحة المدير', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showManagerDashboardOption() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFF8e2de2), size: 24),
            SizedBox(width: 12),
            Text('لوحة المدير', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'هل تريد الانتقال إلى لوحة المدير لمراجعة الطلبات؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8e2de2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManagerDashboard(),
                ),
              );
            },
            child: const Text('انتقال', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('إعادة تعيين الجدول', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل تريد إعادة تعيين جدول العمل إلى الإعدادات الافتراضية؟',
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
                workSchedule = {
                  'الأحد': true,
                  'الإثنين': true,
                  'الثلاثاء': true,
                  'الأربعاء': true,
                  'الخميس': true,
                  'الجمعة': false,
                  'السبت': false,
                };
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعادة تعيين الجدول'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('إعادة تعيين', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int workDaysCount = workSchedule.values.where((isWorkDay) => isWorkDay).length;

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
                                        Icons.calendar_month_rounded,
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
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF007bff), Color(0xFF87ceeb)],
                                ).createShader(bounds),
                                child: const Text(
                                  'WORK SCHEDULE',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'تعبئة أيام العمل',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Employee Info Card (with floating animation)
                      AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: child!,
                          );
                        },
                        child: Card(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.blue[300], size: 24),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'معلومات الموظف',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                TextFormField(
                                  controller: _employeeNameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'اسم الموظف',
                                    hintText: 'أدخل اسم الموظف',
                                    prefixIcon: const Icon(Icons.badge, color: Color(0xFF007bff)),
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
                                  onChanged: (value) {
                                    setState(() {
                                      selectedEmployeeName = value;
                                    });
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Statistics Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: Icons.work,
                                        title: 'أيام العمل',
                                        value: '$workDaysCount',
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: Icons.weekend,
                                        title: 'أيام الإجازة',
                                        value: '${7 - workDaysCount}',
                                        color: Colors.orange,
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

                      // Work Schedule Card (with floating animation)
                      AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value * 0.5),
                            child: child!,
                          );
                        },
                        child: Card(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.schedule, color: Colors.blue[300], size: 24),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'جدول العمل الأسبوعي',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Notes indicator
                                    if (savedNotes.isNotEmpty)
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF8e2de2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit_note,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Days List (simplified - no times)
                                ...workSchedule.entries.map((entry) {
                                  return _buildSimplifiedDayCard(entry.key, entry.value);
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Notes Button (beautiful gradient)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: _buildAnimatedButton(
                          onPressed: _openNotesModal,
                          text: 'إضافة ملاحظات',
                          icon: Icons.edit_note,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8e2de2), Color(0xFF4a00e0)],
                          ),
                        ),
                      ),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnimatedButton(
                              onPressed: _saveSchedule,
                              text: 'إرسال الطلب',
                              icon: Icons.send,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF007bff), Color(0xFF0056b3)],
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _resetSchedule,
                              icon: const Icon(Icons.refresh, color: Colors.orange),
                              label: const Text(
                                'إعادة تعيين',
                                style: TextStyle(color: Colors.orange),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.orange),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Manager Dashboard Button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ManagerDashboard(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.admin_panel_settings, color: Color(0xFF8e2de2)),
                          label: const Text(
                            'لوحة المدير',
                            style: TextStyle(color: Color(0xFF8e2de2)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF8e2de2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),

                      // Back Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF007bff)),
                          label: const Text(
                            'العودة للرئيسية',
                            style: TextStyle(color: Color(0xFF007bff)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF007bff)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
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

  Widget _buildSimplifiedDayCard(String dayName, bool isWorkDay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWorkDay
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isWorkDay
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isWorkDay ? Icons.work : Icons.weekend,
                color: isWorkDay ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                dayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Switch(
            value: isWorkDay,
            onChanged: (_) => _toggleWorkDay(dayName),
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            activeTrackColor: Colors.green.withOpacity(0.3),
            inactiveTrackColor: Colors.red.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
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
    return Container(
      padding: const EdgeInsets.all(16),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}