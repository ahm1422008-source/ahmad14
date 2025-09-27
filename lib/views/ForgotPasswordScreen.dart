import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailSent = false;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller للدخول
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animation Controller للنبضة
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

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String email = _emailController.text.trim();

      try {
        // محاكاة عملية إرسال الإيميل
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _isEmailSent = true;
            _isLoading = false;
          });

          HapticFeedback.lightImpact();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('تم إرسال رابط الاستعادة إلى $email'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          HapticFeedback.mediumImpact();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('حدث خطأ: ${e.toString()}')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _resendEmail() {
    setState(() => _isEmailSent = false);
    _sendResetLink();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    elevation: 25,
                    shadowColor: const Color(0xFFff6b35).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1a1a2e),
                            Color(0xFF000000),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFFff6b35),
                          width: 1,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // شعار التطبيق مع تأثير النبضة
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
                                        colors: [Color(0xFFff6b35), Color(0xFFf9844a)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFff6b35).withOpacity(0.5),
                                          blurRadius: 25,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.lock_reset_rounded,
                                      color: Colors.white,
                                      size: 45,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 30),

                            // العنوان
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFff6b35), Color(0xFFf9844a)],
                              ).createShader(bounds),
                              child: Text(
                                _isEmailSent ? 'EMAIL SENT' : 'RESET PASSWORD',
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
                              _isEmailSent ? 'تم إرسال الرابط' : 'استعادة كلمة المرور',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFff6b35),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 35),

                            // المحتوى الرئيسي
                            if (!_isEmailSent) ...[
                              // النص التوضيحي
                              Text(
                                'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 35),

                              // حقل البريد الإلكتروني
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'البريد الإلكتروني',
                                  hintText: 'example@email.com',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFFff6b35),
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFff6b35),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFff6b35),
                                      width: 2,
                                    ),
                                  ),
                                  labelStyle: const TextStyle(color: Color(0xFFff6b35)),
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _sendResetLink(),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 30),

                              // زر إرسال الرابط
                              SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _sendResetLink,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFff6b35),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[600],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    shadowColor: const Color(0xFFff6b35).withOpacity(0.5),
                                    elevation: 10,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                      : const Text(
                                    'إرسال رابط الاستعادة',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // حالة نجح الإرسال
                              Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.withOpacity(0.1),
                                      Colors.green.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.mark_email_read_rounded,
                                        size: 50,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'تم إرسال البريد الإلكتروني',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'تحقق من بريدك الإلكتروني واتبع التعليمات\nإذا لم تجد الرسالة، تحقق من الرسائل المحذوفة',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green[300],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25),

                              // زر إعادة الإرسال
                              TextButton.icon(
                                onPressed: _isLoading ? null : _resendEmail,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('إعادة إرسال'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFff6b35),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 40),

                            // زر العودة
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('العودة لتسجيل الدخول'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFff6b35),
                                  side: const BorderSide(
                                    color: Color(0xFFff6b35),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // نص المساعدة
                            Text(
                              'تحتاج مساعدة؟ اتصل بالدعم الفني',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
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
          ),
        ),
      ),
    );
  }
}