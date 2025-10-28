// lib/features/product/presentation/widgets/product_options_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // BlocProvider.of ممکن است لازم باشد
import '../../domain/entities/option_entity.dart';
import '../../domain/entities/option_group_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart'; // CartBloc و Event

// import '../../../../main_shell.dart'; // دیگر لازم نیست

class ProductOptionsModal extends StatefulWidget {
  final ProductEntity product;
  final List<OptionGroupEntity> optionGroups;
  // ✨ فیکس: پارامتر cartBloc اضافه شد (اختیاری برای تست‌پذیری)
  final CartBloc? cartBloc;

  const ProductOptionsModal({
    super.key,
    required this.product,
    required this.optionGroups,
    this.cartBloc, // <-- اضافه شد
  });

  @override
  State<ProductOptionsModal> createState() => _ProductOptionsModalState();
}

class _ProductOptionsModalState extends State<ProductOptionsModal> {
  final Map<int, int> _selectedOptions = {};
  double _currentTotalPrice = 0.0;

  // ✨ فیکس: نگهداری رفرنس BLoC
  late final CartBloc _cartBloc;

  @override
  void initState() {
    super.initState();
    // BLoC را یا از پارامتر بگیر یا از context پیدا کن
    _cartBloc = widget.cartBloc ?? context.read<CartBloc>();
    _currentTotalPrice = widget.product.finalPrice;
    _initializeDefaultSelections();
    _calculateTotalPrice();
  }

  void _initializeDefaultSelections() {
    for (var group in widget.optionGroups) {
      if (group.options.isNotEmpty) {
         final defaultOption = group.options.firstWhere(
             (opt) => opt.priceDelta == 0,
             orElse: () => group.options.first
         );
        _selectedOptions[group.id] = defaultOption.id;
      }
    }
  }

  void _calculateTotalPrice() {
    double basePrice = widget.product.finalPrice;
    double optionsPriceDelta = 0;
    _selectedOptions.forEach((groupId, optionId) {
      try {
        final group = widget.optionGroups.firstWhere((g) => g.id == groupId);
        final option = group.options.firstWhere((o) => o.id == optionId);
        optionsPriceDelta += option.priceDelta;
      } catch (e) { print("Error finding option: $e"); }
    });
    setState(() { _currentTotalPrice = basePrice + optionsPriceDelta; });
  }

  void _selectOption(int groupId, int optionId) {
    setState(() { _selectedOptions[groupId] = optionId; });
    _calculateTotalPrice();
  }

  List<OptionEntity> _getSelectedOptionEntities() {
    final List<OptionEntity> selected = [];
    _selectedOptions.forEach((groupId, optionId) {
       try {
        final group = widget.optionGroups.firstWhere((g) => g.id == groupId);
        final option = group.options.firstWhere((o) => o.id == optionId);
        selected.add(option);
       } catch (e) { print("Error retrieving option entity: $e"); }
    });
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      // ... (بقیه کد بدون تغییر تا دکمه افزودن)
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
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
              Container( width: 40, height: 5, decoration: BoxDecoration( color: Colors.grey[300], borderRadius: BorderRadius.circular(10), ), margin: const EdgeInsets.only(bottom: 10), ),
              Text( widget.product.name, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center, ),
              const Divider(height: 20),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: widget.optionGroups.length,
                  itemBuilder: (context, index) {
                    final group = widget.optionGroups[index];
                    return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding( padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text( group.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) ), ),
                      ...group.options.map( (option) => RadioListTile<int>(
                          title: Text(option.name), value: option.id, groupValue: _selectedOptions[group.id],
                          onChanged: (value) { if (value != null) { _selectOption(group.id, value); } },
                          secondary: Text( option.priceDelta == 0 ? 'رایگان' : '${option.priceDelta > 0 ? '+' : ''}${option.priceDelta.toStringAsFixed(0)} ت', style: TextStyle( color: option.priceDelta >= 0 ? Colors.green : Colors.red, fontSize: 12 ), ),
                          controlAffinity: ListTileControlAffinity.trailing, contentPadding: EdgeInsets.zero, activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ], );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                ),
              ),
              Container(
                 padding: EdgeInsets.only( top: 12.0, bottom: MediaQuery.of(context).padding.bottom + 12.0, left: 16.0, right: 16.0, ),
                 decoration: BoxDecoration( color: Theme.of(context).canvasColor, boxShadow: [ BoxShadow( color: Colors.black.withAlpha((255 * 0.08).round()), blurRadius: 8, offset: const Offset(0,-3), ) ], ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text('مجموع:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                      Text( '${_currentTotalPrice.toStringAsFixed(0)} تومان', style: Theme.of(context).textTheme.titleLarge?.copyWith( fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary ), ),
                    ], ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      label: const Text('افزودن به سبد'),
                      onPressed: () {
                        final selected = _getSelectedOptionEntities();

                        // ✨ فیکس نهایی: استفاده از BLoC ذخیره شده (_cartBloc)
                        _cartBloc.add(
                           CartProductAdded(
                             product: widget.product,
                             selectedOptions: selected,
                           ),
                         );

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('${widget.product.name} با گزینه‌های انتخابی به سبد اضافه شد'), duration: const Duration(seconds: 3), behavior: SnackBarBehavior.floating, ) );
                      },
                      style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), ),
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