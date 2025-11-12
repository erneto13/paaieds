import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/history_provider.dart';
import 'package:paaieds/core/providers/test_provider.dart';
import 'package:paaieds/ui/screens/main_app/etests/test_screen.dart';
import 'package:paaieds/ui/screens/settings/settings_screen.dart';
import 'package:paaieds/ui/widgets/test/test_history_section.dart';
import 'package:paaieds/ui/widgets/test/test_preview_card.dart';
import 'package:provider/provider.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/ui/widgets/util/custom_bottom_bar.dart';
import 'package:paaieds/ui/widgets/util/gradient_text.dart';
import 'package:paaieds/ui/widgets/util/snackbar.dart';
import '../../widgets/util/custom_app_bar.dart';

class LearnTestScreen extends StatefulWidget {
  final Function(int)? onNavBarTap;
  final int? currentIndex;

  const LearnTestScreen({super.key, this.onNavBarTap, this.currentIndex});

  @override
  State<LearnTestScreen> createState() => _LearnTestScreenState();
}

class _LearnTestScreenState extends State<LearnTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeHistory();
  }

  void _initializeHistory() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final historyProvider = Provider.of<HistoryProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        historyProvider.loadTestHistoryStream(authProvider.currentUser!.uid);
      }
    });
  }

  Future<void> _generateTest() async {
    final topic = _controller.text.trim();

    if (topic.isEmpty) {
      CustomSnackbar.showError(
        context: context,
        message: 'Campo vacío',
        description: 'Por favor, ingresa un tema para generar el test.',
      );
      return;
    }

    final testProvider = Provider.of<TestProvider>(context, listen: false);

    // ✅ IMPORTANTE: Limpiar estado previo antes de generar nuevo test
    testProvider.reset();

    final success = await testProvider.generateTest(topic);

    if (!mounted) return;

    if (success) {
      CustomSnackbar.showSuccess(
        context: context,
        message: 'Test generado',
        description: 'El test se ha generado correctamente.',
      );

      _controller.clear();
      _scrollToPreview();
    } else {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al generar test',
        description: testProvider.errorMessage ?? 'Intenta más tarde.',
      );
    }
  }

  void _startTest() {
    final testProvider = Provider.of<TestProvider>(context, listen: false);

    if (testProvider.questions.isEmpty) {
      CustomSnackbar.showError(
        context: context,
        message: 'No hay test generado',
        description: 'Genera un test primero.',
      );
      return;
    }

    testProvider.clearAnswers();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TestScreen()),
    );
  }

  void _scrollToPreview() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          300,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          onNavBarTap: widget.onNavBarTap ?? (_) {},
          currentIndex: widget.currentIndex ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Hola, ${user?.displayName ?? 'Usuario'}",
        onProfileTap: _navigateToSettings,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildTextField(),
              const SizedBox(height: 16),
              _buildGenerateButton(),
              const SizedBox(height: 40),
              TestPreviewCard(onStartTest: _startTest),
              _buildSpacer(),
              const TestHistorySection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.onNavBarTap != null
          ? CustomBottomNavBar(
              currentIndex: widget.currentIndex ?? 0,
              onTap: widget.onNavBarTap!,
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: GradientText(
        "¿Qué quieres aprender?",
        gradient: const LinearGradient(
          colors: [AppColors.deepBlue, AppColors.oceanBlue],
        ),
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          return TextField(
            controller: _controller,
            enabled: !testProvider.isLoading,
            style: TextStyle(color: Colors.grey[800]),
            decoration: InputDecoration(
              hintText: "Ejemplo: Signals en Angular",
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.school, color: AppColors.deepBlue),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: AppColors.lightBlue.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: AppColors.highlight,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            onSubmitted: (_) => _generateTest(),
          );
        },
      ),
    );
  }

  Widget _buildGenerateButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          final isLoading = testProvider.isLoading;

          return SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _generateTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundButtom,
                disabledBackgroundColor: AppColors.lightBlue.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isLoading ? 0 : 2,
              ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Generando test...",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      "Generar Test",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpacer() {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        return testProvider.questions.isNotEmpty
            ? const SizedBox(height: 40)
            : const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
