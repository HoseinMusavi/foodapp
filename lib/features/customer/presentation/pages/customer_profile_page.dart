import 'package:customer_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entity.dart';
import 'package:customer_app/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;

  CustomerEntity? _currentCustomer;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();

    final state = context.read<CustomerCubit>().state;
    if (state is CustomerLoaded) {
      _updateControllers(state.customer);
      _currentCustomer = state.customer;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateControllers(CustomerEntity customer) {
    _fullNameController.text = customer.fullName;
    _phoneController.text = customer.phone;
  }

  void _onToggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      // اگر در حال لغو ویرایش بودیم، مقادیر را ریست کن
      if (!_isEditing && _currentCustomer != null) {
        _updateControllers(_currentCustomer!);
      }
    });
  }

  void _onSaveProfile() {
    if (_formKey.currentState!.validate() && _currentCustomer != null) {
      final updatedCustomer = CustomerEntity(
        id: _currentCustomer!.id,
        email: _currentCustomer!.email, // ایمیل قابل ویرایش نیست
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        avatarUrl: _currentCustomer!.avatarUrl,
        defaultAddressId: _currentCustomer!.defaultAddressId,
      );
      context.read<CustomerCubit>().updateCustomer(updatedCustomer);
      setState(() {
        _isEditing = false; // خروج از حالت ویرایش پس از ذخیره
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('خطا: ${state.message}'),
                  backgroundColor: Colors.red),
            );
          }
          if (state is CustomerLoaded) {
            final currentState = context.read<CustomerCubit>().state;
            if (currentState is! CustomerLoading) {
              _updateControllers(state.customer);
              _currentCustomer = state.customer;
              // فقط اگر در حال ویرایش نبودیم اسنک بار نشان بده
              if (!_isEditing) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('پروفایل با موفقیت به‌روزرسانی شد'),
                      backgroundColor: Colors.green),
                );
              }
            }
          }
        },
        builder: (context, state) {
          if (state is CustomerInitial) {
            context.read<CustomerCubit>().fetchCustomerDetails();
          }

          if (state is CustomerLoading && _currentCustomer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError && _currentCustomer == null) {
            return _buildErrorView(context, state.message);
          }

          // اگر در حال لودینگ بودیم ولی داده داشتیم، UI را با لودر نشان بده
          final customer = (state is CustomerLoaded) ? state.customer : _currentCustomer;
          final bool isLoading = (state is CustomerLoading);

          return RefreshIndicator(
            onRefresh: () async {
               context.read<CustomerCubit>().fetchCustomerDetails();
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, customer),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileFormCard(context, customer, isLoading),
                        const SizedBox(height: 24),
                        _buildActionsCard(context),
                        const SizedBox(height: 24),
                        _buildLogoutButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, CustomerEntity? customer) {
    final avatarUrl = customer?.avatarUrl;
    final fullName = customer?.fullName ?? '...';
    final fallbackLetter = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(fullName, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
               decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withAlpha(150),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )
               ),
            ),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor:
                    Theme.of(context).colorScheme.onPrimary.withAlpha(50),
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Text(
                        fallbackLetter,
                        style: TextStyle(
                          fontSize: 40,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileFormCard(BuildContext context, CustomerEntity? customer, bool isLoading) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('اطلاعات کاربری', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _onToggleEdit,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'نام و نام خانوادگی'),
                    validator: (value) => (value == null || value.isEmpty) ? 'نام اجباری است' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'شماره تلفن'),
                     validator: (value) => (value == null || value.isEmpty) ? 'تلفن اجباری است' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: customer?.email ?? '',
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'ایمیل (غیرقابل ویرایش)',
                      suffixIcon: Icon(Icons.lock_outline, size: 16)
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                        label: Text(isLoading ? 'در حال ذخیره...' : 'ذخیره تغییرات'),
                        style: ElevatedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: isLoading ? null : _onSaveProfile,
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

 Widget _buildActionsCard(BuildContext context) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('مدیریت', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('آدرس‌های من'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/select-address');
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
             ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('تاریخچه سفارشات'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigator.pushNamed(context, '/order-history');
              },
            ),
         ],
      )
    );
 }

  Widget _buildLogoutButton(BuildContext context) {
     return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('خروج از حساب کاربری'),
         style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          // نمایش دیالوگ تایید خروج
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('خروج از حساب'),
              content: const Text('آیا برای خروج مطمئن هستید؟'),
              actions: [
                TextButton(
                  child: const Text('لغو'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                FilledButton(
                  child: const Text('خروج'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // بستن دیالوگ
                    context.read<AuthCubit>().signOut(); // اجرای خروج
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

   Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'خطا در بارگذاری پروفایل: $message',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<CustomerCubit>().fetchCustomerDetails(),
            child: const Text('تلاش مجدد'),
          )
        ],
      ),
    );
  }
}