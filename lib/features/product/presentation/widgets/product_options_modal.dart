// lib/features/product/presentation/widgets/product_options_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/option_entity.dart';
import '../../domain/entities/option_group_entity.dart';
import '../../domain/entities/product_entity.dart';
// ایمپورت CartBloc و Event مربوطه
import '../../../cart/presentation/bloc/cart_bloc.dart';

class ProductOptionsModal extends StatefulWidget {
  final ProductEntity product;
  final List<OptionGroupEntity> optionGroups;

  const ProductOptionsModal({
    super.key,
    required this.product,
    required this.optionGroups,
  });

  @override
  State<ProductOptionsModal> createState() => _ProductOptionsModalState();
}

class _ProductOptionsModalState extends State<ProductOptionsModal> {
  // Map برای نگهداری آپشن انتخاب شده برای هر گروه (groupID -> selectedOptionID)
  // فرض اولیه: هر گروه فقط یک انتخاب دارد (RadioButton)
  final Map<int, int> _selectedOptions = {};
  double _currentTotalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // مقدار اولیه قیمت، قیمت پایه محصول است
    _currentTotalPrice = widget.product.finalPrice;
    // انتخاب آپشن‌های پیش‌فرض (معمولاً اولین گزینه یا گزینه‌ای با priceDelta=0)
    _initializeDefaultSelections();
    _calculateTotalPrice(); // محاسبه اولیه قیمت با آپشن‌های پیش‌فرض
  }

  // انتخاب آپشن‌های پیش‌فرض
  void _initializeDefaultSelections() {
    for (var group in widget.optionGroups) {
      if (group.options.isNotEmpty) {
         // گزینه‌ای با priceDelta=0 را به عنوان پیش‌فرض انتخاب کن، اگر نبود اولین گزینه
         final defaultOption = group.options.firstWhere(
             (opt) => opt.priceDelta == 0,
             orElse: () => group.options.first
         );
        _selectedOptions[group.id] = defaultOption.id;
      }
    }
  }

  // محاسبه قیمت کل بر اساس آپشن‌های انتخاب شده
  void _calculateTotalPrice() {
    double basePrice = widget.product.finalPrice;
    double optionsPriceDelta = 0;

    _selectedOptions.forEach((groupId, optionId) {
      // پیدا کردن آپشن انتخاب شده با اطمینان بیشتر
      try {
        final group = widget.optionGroups.firstWhere((g) => g.id == groupId);
        final option = group.options.firstWhere((o) => o.id == optionId);
        optionsPriceDelta += option.priceDelta;
      } catch (e) {
        print("Error finding selected option during price calculation: $e");
        // اگر آپشنی پیدا نشد (نباید اتفاق بیفتد)، قیمت آن را صفر در نظر بگیر
      }
    });

    setState(() {
      _currentTotalPrice = basePrice + optionsPriceDelta;
    });
  }

  // تابع برای انتخاب یک آپشن (برای RadioButton)
  void _selectOption(int groupId, int optionId) {
    setState(() {
      _selectedOptions[groupId] = optionId;
    });
    _calculateTotalPrice(); // قیمت را دوباره محاسبه کن
  }

  // جمع‌آوری OptionEntity های انتخاب شده برای ارسال به Bloc
  List<OptionEntity> _getSelectedOptionEntities() {
    final List<OptionEntity> selected = [];
    _selectedOptions.forEach((groupId, optionId) {
       try {
        final group = widget.optionGroups.firstWhere((g) => g.id == groupId);
        final option = group.options.firstWhere((o) => o.id == optionId);
        selected.add(option);
       } catch (e) {
         print("Error retrieving selected option entity: $e");
       }
    });
    return selected;
  }


  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          // دکوراسیون برای گوشه‌های گرد بالا
          decoration: BoxDecoration(
             color: Theme.of(context).scaffoldBackgroundColor,
             borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
             )
          ),
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 0),
          child: Column(
            children: [
              // نوار کوچک بالای مودال
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 10),
              ),
              // عنوان مودال (نام محصول)
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const Divider(height: 20),
              // لیست آپشن‌ها
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: widget.optionGroups.length,
                  itemBuilder: (context, index) {
                    final group = widget.optionGroups[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                             group.name,
                             style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                          ),
                        ),
                        // استفاده از RadioListTile برای انتخاب تکی
                        // TODO: اگر گروهی نیاز به انتخاب چندگانه داشت (allow_multiple=true در بک‌اند)
                        // باید از CheckboxListTile استفاده شود و _selectedOptions تغییر کند.
                        ...group.options.map(
                          (option) => RadioListTile<int>(
                            title: Text(option.name),
                            value: option.id,
                            // مقدار انتخاب شده فعلی برای این گروه
                            groupValue: _selectedOptions[group.id],
                            onChanged: (value) {
                              if (value != null) {
                                _selectOption(group.id, value);
                              }
                            },
                            // نمایش تغییر قیمت
                            secondary: Text(
                                option.priceDelta == 0
                                   ? 'رایگان' // یا خالی بگذارید
                                   : '${option.priceDelta > 0 ? '+' : ''}${option.priceDelta.toStringAsFixed(0)} ت',
                                style: TextStyle(
                                   color: option.priceDelta >= 0 ? Colors.green : Colors.red,
                                   fontSize: 12
                                ),
                             ),
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: EdgeInsets.zero,
                            activeColor: Theme.of(context).colorScheme.primary, // رنگ دکمه فعال
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1), // خط جداکننده نازک‌تر
                ),
              ),
              // --- نوار پایین شامل قیمت و دکمه افزودن ---
              Container(
                 // SafeArea برای جلوگیری از تداخل با دکمه‌های ناوبری سیستم عامل
                 padding: EdgeInsets.only(
                   top: 12.0,
                   bottom: MediaQuery.of(context).padding.bottom + 12.0,
                   left: 16.0, // اضافه کردن پدینگ افقی به نوار پایین
                   right: 16.0,
                 ),
                 // دکوراسیون برای جدا کردن بصری از لیست
                 decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor, // یا scaffoldBackgroundColor
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08), // سایه ملایم‌تر
                        blurRadius: 8,
                        offset: const Offset(0,-3),
                      )
                    ],
                    // برداشتن گوشه‌های گرد بالا اگر مودال خودش گرد است
                    // borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                 ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     // نمایش قیمت کل
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisSize: MainAxisSize.min, // جلوگیری از گرفتن ارتفاع اضافه
                       children: [
                         Text('مجموع:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                         Text(
                           '${_currentTotalPrice.toStringAsFixed(0)} تومان',
                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary // رنگ قیمت
                            ),
                         ),
                       ],
                    ),
                    // دکمه افزودن به سبد
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      label: const Text('افزودن به سبد'),
                      onPressed: () {
                        // ۱. گرفتن لیست OptionEntity های انتخاب شده
                        final selected = _getSelectedOptionEntities();

                        // ۲. ارسال ایونت به CartBloc
                        context.read<CartBloc>().add(
                           CartProductAdded(
                             product: widget.product,
                             selectedOptions: selected,
                           ),
                         );

                        // ۳. بستن مودال
                        Navigator.of(context).pop();

                        // ۴. نمایش SnackBar تایید
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('${widget.product.name} با گزینه‌های انتخابی به سبد اضافه شد'),
                             duration: const Duration(seconds: 3), // زمان بیشتر
                             behavior: SnackBarBehavior.floating, // ظاهر شناور
                           )
                        );
                      },
                      style: ElevatedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // گوشه‌های گردتر
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}