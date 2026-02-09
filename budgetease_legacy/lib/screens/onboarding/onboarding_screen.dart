import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/database_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_category_dialog.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _currency = 'FCFA';
  bool _notificationEnabled = false;
  String _notificationTime = '20:00';
  List<String> _selectedCategories = [];
  List<Category> _customCategories = [];

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final settings = DatabaseService.settings.values.first;
    settings.currency = _currency;
    settings.notificationEnabled = _notificationEnabled;
    settings.notificationTime = _notificationTime;
    settings.onboardingCompleted = true;
    settings.favoriteCategories = _selectedCategories;
    await settings.save();

    // Save custom categories to database (already saved in dialog)
    // They are already in DatabaseService.categories

    widget.onComplete();
  }

  void _toggleCategory(String categoryName) {
    setState(() {
      if (_selectedCategories.contains(categoryName)) {
        _selectedCategories.remove(categoryName);
      } else if (_selectedCategories.length < 3) {
        _selectedCategories.add(categoryName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    width: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'BudgetEase',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gérez votre budget simplement',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Progress indicator
                  Row(
                    children: List.generate(
                      4,
                      (index) => Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: index < 3 ? 8 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: index <= _currentPage
                                ? AppColors.primary
                                : AppColors.gray200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildCurrencyPage(),
                  _buildNotificationPage(),
                  _buildCategoriesPage(),
                  _buildCustomCategoriesPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retour'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_currentPage == 2 && _selectedCategories.isEmpty)
                          ? null
                          : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_currentPage == 3 ? 'Commencer' : 'Continuer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sélectionnez votre devise',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous pourrez la modifier plus tard dans les paramètres',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 32),
          ...currencyOptions.map((option) => RadioListTile<String>(
                title: Text(option['label']!),
                value: option['value']!,
                groupValue: _currency,
                onChanged: (value) => setState(() => _currency = value!),
                activeColor: AppColors.primary,
              )),
        ],
      ),
    );
  }

  Widget _buildNotificationPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rappel quotidien',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recevez un rappel pour enregistrer vos dépenses (optionnel)',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 32),
          SwitchListTile(
            title: const Text('Activer le rappel'),
            value: _notificationEnabled,
            onChanged: (value) => setState(() => _notificationEnabled = value),
            activeColor: AppColors.primary,
          ),
          if (_notificationEnabled) ...[
            const SizedBox(height: 24),
            const Text(
              'Heure du rappel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: int.parse(_notificationTime.split(':')[0]),
                    minute: int.parse(_notificationTime.split(':')[1]),
                  ),
                );
                if (time != null) {
                  setState(() {
                    _notificationTime =
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _notificationTime,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time, color: AppColors.gray600),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catégories favorites',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sélectionnez 3 catégories que vous utilisez le plus',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: defaultCategoriesData.length,
              itemBuilder: (context, index) {
                final categoryData = defaultCategoriesData[index];
                final isSelected = _selectedCategories.contains(categoryData['name']);

                return InkWell(
                  onTap: () => _toggleCategory(categoryData['name']!),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.gray200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? AppColors.primaryLight : Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categoryData['icon']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          categoryData['name']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_selectedCategories.length}/3 sélectionnées',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCategoriesPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personnalisation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez vos propres catégories (optionnel, max 3)',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 32),

          // Custom categories list
          Expanded(
            child: _customCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: AppColors.gray300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune catégorie personnalisée',
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _customCategories.length,
                    itemBuilder: (context, index) {
                      final category = _customCategories[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                            onPressed: () {
                              setState(() {
                                _customCategories.removeAt(index);
                              });
                              // Delete from database
                              category.delete();
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),

          // Add category button
          if (_customCategories.length < 3)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final category = await showDialog<Category>(
                    context: context,
                    builder: (context) => const CustomCategoryDialog(),
                  );
                  if (category != null) {
                    setState(() {
                      _customCategories.add(category);
                    });
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Créer une catégorie'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '${_customCategories.length}/3 créées',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
