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

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({Key? key}) : super(key: key);

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  final WorkRequestManager _requestManager = WorkRequestManager();
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSampleData(); // بيانات تجريبية
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
      duration: const Duration(seconds: 4),
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
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: -8.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _loadSampleData() {
    // بيانات تجريبية - في التطبيق الحقيقي ستأتي من قاعدة البيانات
    _requestManager.addRequest(
      WorkRequest(
        id: '1',
        employeeName: 'أحمد محمد',
        employeeId: 'EMP001',
        workSchedule: {
          'الأحد': true,
          'الإثنين': true,
          'الثلاثاء': true,
          'الأربعاء': true,
          'الخميس': false,
          'الجمعة': false,
          'السبت': false,
        },
        notes: 'يفضل العمل من المنزل يوم الخميس إذا أمكن، ولديه موعد طبي يوم الثلاثاء في المساء',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    );

    _requestManager.addRequest(
      WorkRequest(
        id: '2',
        employeeName: 'فاطمة علي',
        employeeId: 'EMP002',
        workSchedule: {
          'الأحد': true,
          'الإثنين': true,
          'الثلاثاء': true,
          'الأربعاء': true,
          'الخميس': true,
          'الجمعة': false,
          'السبت': true,
        },
        notes: 'متاحة للعمل يوم السبت حسب الحاجة، تفضل البدء المبكر في الصباح',
        submittedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    );

    _requestManager.addRequest(
      WorkRequest(
        id: '3',
        employeeName: 'محمد خالد',
        employeeId: 'EMP003',
        workSchedule: {
          'الأحد': true,
          'الإثنين': true,
          'الثلاثاء': false,
          'الأربعاء': true,
          'الخميس': true,
          'الجمعة': false,
          'السبت': false,
        },
        notes: 'لا يمكنني العمل يوم الثلاثاء بسبب دورة تدريبية، متاح للعمل الإضافي',
        submittedAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: WorkRequestStatus.approved,
      ),
    );

    _requestManager.addRequest(
      WorkRequest(
        id: '4',
        employeeName: 'سارة أحمد',
        employeeId: 'EMP004',
        workSchedule: {
          'الأحد': false,
          'الإثنين': true,
          'الثلاثاء': true,
          'الأربعاء': true,
          'الخميس': true,
          'الجمعة': true,
          'السبت': false,
        },
        notes: 'أفضل العمل من الإثنين للجمعة، الأحد والسبت للراحة العائلية',
        submittedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
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
                  _buildHeader(),

                  // Tab Navigation
                  _buildTabNavigation(),

                  // Content
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 25,
        shadowColor: Colors.purple.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(28),
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
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              title: 'الطلبات المعلقة',
              icon: Icons.pending_actions,
              count: _requestManager.getPendingRequests().length,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTabButton(
              index: 1,
              title: 'الطلبات المعتمدة',
              icon: Icons.check_circle,
              count: _requestManager.getApprovedRequests().length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String title,
    required IconData icon,
    required int count,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF8e2de2), Color(0xFF4a00e0)],
          )
              : LinearGradient(
            colors: [
              Colors.grey.withOpacity(0.2),
              Colors.grey.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF8e2de2).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFF8e2de2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF8e2de2) : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final requests = _selectedTabIndex == 0
        ? _requestManager.getPendingRequests()
        : _requestManager.getApprovedRequests();

    if (requests.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value * (index % 2 == 0 ? 1 : -1)),
              child: _buildRequestCard(requests[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedTabIndex == 0 ? Icons.inbox : Icons.check_circle_outline,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedTabIndex == 0 ? 'لا توجد طلبات معلقة' : 'لا توجد طلبات معتمدة',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _selectedTabIndex == 0
                ? 'ستظهر هنا الطلبات الجديدة من الموظفين'
                : 'ستظهر هنا الطلبات التي تم اعتمادها',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(WorkRequest request) {
    final workDaysCount = request.workSchedule.values.where((day) => day).length;
    final statusColor = _getStatusColor(request.status);
    final statusText = _getStatusText(request.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 15,
      shadowColor: statusColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Text(
                      request.employeeName.split(' ').map((e) => e[0]).take(2).join(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.employeeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${request.employeeId}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatContainer(
                          icon: Icons.work,
                          title: 'أيام العمل',
                          value: '$workDaysCount',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatContainer(
                          icon: Icons.weekend,
                          title: 'أيام الإجازة',
                          value: '${7 - workDaysCount}',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatContainer(
                          icon: Icons.access_time,
                          title: 'منذ',
                          value: _getTimeAgo(request.submittedAt),
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // جدول العمل الأسبوعي المحسن
                  _buildWeeklySchedule(request.workSchedule),

                  const SizedBox(height: 20),

                  // ملخص سريع للأيام
                  _buildWorkDaysSummary(request.workSchedule),

                  // Notes
                  if (request.notes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'الملاحظات:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Text(
                        request.notes,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],

                  // Action Buttons (only for pending requests)
                  if (request.status == WorkRequestStatus.pending) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            onPressed: () => _approveRequest(request),
                            text: 'اعتماد',
                            icon: Icons.check,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            onPressed: () => _rejectRequest(request),
                            text: 'رفض',
                            icon: Icons.close,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            onPressed: () => _showScheduleDetails(request),
                            text: 'تفاصيل',
                            icon: Icons.info_outline,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // جدول العمل الأسبوعي المحسن
  Widget _buildWeeklySchedule(Map<String, bool> workSchedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_view_week, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'جدول العمل الأسبوعي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // عرض الأيام في شكل جدول
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            children: workSchedule.entries.map((entry) {
              final isWorkDay = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.purple.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // أيقونة اليوم
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isWorkDay
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isWorkDay
                              ? Colors.green.withOpacity(0.5)
                              : Colors.red.withOpacity(0.5),
                        ),
                      ),
                      child: Icon(
                        isWorkDay ? Icons.work : Icons.free_breakfast,
                        color: isWorkDay ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 15),

                    // اسم اليوم
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // حالة اليوم
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isWorkDay
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isWorkDay ? 'يعمل' : 'إجازة',
                        style: TextStyle(
                          color: isWorkDay ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // أيقونة الحالة
                    Icon(
                      isWorkDay ? Icons.check_circle : Icons.cancel,
                      color: isWorkDay ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ملخص سريع للأيام
  Widget _buildWorkDaysSummary(Map<String, bool> workSchedule) {
    final workDays = workSchedule.entries.where((e) => e.value).map((e) => e.key).toList();
    final restDays = workSchedule.entries.where((e) => !e.value).map((e) => e.key).toList();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text(
                'ملخص الجدول',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // أيام العمل
          if (workDays.isNotEmpty) ...[
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[300], fontSize: 13),
                children: [
                  const TextSpan(
                    text: '🟢 أيام العمل: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  TextSpan(text: workDays.join('، ')),
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],

          // أيام الإجازة
          if (restDays.isNotEmpty) ...[
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[300], fontSize: 13),
                children: [
                  const TextSpan(
                    text: '🔴 أيام الإجازة: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  TextSpan(text: restDays.join('، ')),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatContainer({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 5,
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // الانتقال لصفحة إضافة موظف جديد
        _showAddEmployeeDialog();
      },
      backgroundColor: const Color(0xFF8e2de2),
      icon: const Icon(Icons.person_add, color: Colors.white),
      label: const Text(
        'إضافة موظف',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _approveRequest(WorkRequest request) {
    setState(() {
      _requestManager.updateRequestStatus(request.id, WorkRequestStatus.approved);
    });

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اعتماد طلب ${request.employeeName}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _rejectRequest(WorkRequest request) {
    setState(() {
      _requestManager.updateRequestStatus(request.id, WorkRequestStatus.rejected);
    });

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم رفض طلب ${request.employeeName}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // عرض تفاصيل الجدول في نافذة منبثقة
  void _showScheduleDetails(WorkRequest request) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF1a1a2e), Color(0xFF000000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFF8e2de2), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8e2de2).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF8e2de2), size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.employeeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'تفاصيل جدول العمل المطلوب',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // إحصائيات سريعة
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailStatCard(
                            'أيام العمل',
                            '${request.workSchedule.values.where((day) => day).length}',
                            Icons.work,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDetailStatCard(
                            'أيام الراحة',
                            '${request.workSchedule.values.where((day) => !day).length}',
                            Icons.weekend,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // جدول مفصل
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: request.workSchedule.entries.map((entry) {
                          final isWorkDay = entry.value;
                          final dayIndex = _getDayIndex(entry.key);

                          return Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isWorkDay
                                  ? Colors.green.withOpacity(0.05)
                                  : Colors.red.withOpacity(0.05),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.purple.withOpacity(0.1),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // رقم اليوم
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: isWorkDay
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$dayIndex',
                                      style: TextStyle(
                                        color: isWorkDay ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),

                                // اسم اليوم
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // الوقت المتوقع (مثال)
                                if (isWorkDay) ...[
                                  Text(
                                    '8:00 - 17:00',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],

                                // الحالة
                                Icon(
                                  isWorkDay ? Icons.work : Icons.home,
                                  color: isWorkDay ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // الملاحظات في النافذة المنبثقة
                    if (request.notes.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.note, color: Colors.purple, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'ملاحظات الموظف:',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.notes,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // أزرار الإجراءات
                    if (request.status == WorkRequestStatus.pending) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _approveRequest(request);
                              },
                              icon: const Icon(Icons.check, color: Colors.white, size: 18),
                              label: const Text(
                                'اعتماد',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _rejectRequest(request);
                              },
                              icon: const Icon(Icons.close, color: Colors.white, size: 18),
                              label: const Text(
                                'رفض',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }

  int _getDayIndex(String dayName) {
    const days = {
      'الأحد': 1,
      'الإثنين': 2,
      'الثلاثاء': 3,
      'الأربعاء': 4,
      'الخميس': 5,
      'الجمعة': 6,
      'السبت': 7,
    };
    return days[dayName] ?? 0;
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('إضافة موظف جديد', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هذه الميزة ستتيح إضافة موظفين جدد إلى النظام',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق', style: TextStyle(color: Color(0xFF8e2de2))),
          ),
        ],
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