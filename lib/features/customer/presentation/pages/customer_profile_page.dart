// lib/features/customer/presentation/pages/customer_profile_page.dart

import 'package:customer_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entity.dart';
import 'package:customer_app/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev; // برای لاگ‌گذاری

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;

  CustomerEntity? _currentCustomer;
  bool _isEditing = false;
  // --- ۱. اضافه شدن فلگ برای تشخیص کاربر جدید ---
  bool _isNewUser = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    dev.log('[LOG-UI] 1. initState()', name: 'CustomerProfilePage');
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();

    final state = context.read<CustomerCubit>().state;
    dev.log('[LOG-UI] 2. Initial Cubit State in initState: ${state.runtimeType}', name: 'CustomerProfilePage');
    
    if (state is CustomerLoaded) {
      dev.log('[LOG-UI] 3. initState: Cubit is already CustomerLoaded.', name: 'CustomerProfilePage');
      _currentCustomer = state.customer;
      _updateControllers(state.customer);
      
      // --- ۲. بررسی در initState (منطق کاربر جدید) ---
      if (state.customer.fullName.isEmpty || state.customer.phone.isEmpty) {
        dev.log('[LOG-UI] 4. initState: Detected new user. Forcing edit mode.', name: 'CustomerProfilePage');
        _isEditing = true;
        _isNewUser = true; // این یک کاربر جدید است
      }
    } else if (state is CustomerInitial) {
      dev.log('[LOG-UI] 3. initState: Cubit is CustomerInitial. Calling fetchCustomerDetails().', name: 'CustomerProfilePage');
      context.read<CustomerCubit>().fetchCustomerDetails();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateControllers(CustomerEntity customer) {
    dev.log('[LOG-UI] _updateControllers() called with name: "${customer.fullName}"', name: 'CustomerProfilePage');
    _fullNameController.text = customer.fullName;
    _phoneController.text = customer.phone;
  }

  void _toggleEdit() {
    // --- ۳. منطق دکمه انصراف (منطق کاربر جدید) ---
    if (_isNewUser && _isEditing) {
      dev.log('[LOG-UI] _toggleEdit(): New user tried to cancel edit. Denied.', name: 'CustomerProfilePage');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا ابتدا پروفایل خود را تکمیل کنید.'),
          backgroundColor: Colors.orange,
        ),
      );
      return; // از خروج از حالت ویرایش جلوگیری کن
    }
    setState(() => _isEditing = !_isEditing);
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate() && _currentCustomer != null) {
      dev.log('[LOG-UI] _saveProfile() called.', name: 'CustomerProfilePage');
      final updatedCustomer = CustomerEntity(
        id: _currentCustomer!.id,
        email: _currentCustomer!.email,
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        avatarUrl: _currentCustomer!.avatarUrl,
        defaultAddressId: _currentCustomer!.defaultAddressId,
      );
      context.read<CustomerCubit>().updateCustomer(updatedCustomer);
      
      // --- ۴. پس از ذخیره (منطق کاربر جدید) ---
      setState(() {
        _isEditing = false;
        _isNewUser = false; // کاربر اطلاعات خود را ذخیره کرد
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    dev.log('[LOG-UI] build() called.', name: 'CustomerProfilePage');

    return Scaffold(
      body: BlocConsumer<CustomerCubit, CustomerState>(
        listener: (context, state) {
          dev.log('[LOG-UI] BlocListener detected state: ${state.runtimeType}', name: 'CustomerProfilePage');
          if (state is CustomerLoaded) {
            _currentCustomer = state.customer;
            _updateControllers(state.customer);

            // --- ۵. بررسی در listener (منطق کاربر جدید) ---
            if (state.customer.fullName.isEmpty || state.customer.phone.isEmpty) {
              if (!_isEditing) { // فقط اگر قبلاً در حالت ویرایش نبودیم
                dev.log('[LOG-UI] Listener: Detected new user. Forcing edit mode.', name: 'CustomerProfilePage');
                setState(() {
                  _isEditing = true;
                  _isNewUser = true;
                });
              }
            } else if (_isNewUser && state.customer.fullName.isNotEmpty) {
              // اگر کاربر اطلاعاتش را ذخیره کرده و ما new user بودیم
              dev.log('[LOG-UI] Listener: User was new, but data is now present. Disabling new user mode.', name: 'CustomerProfilePage');
              setState(() {
                 _isNewUser = false;
                 _isEditing = false;
              });
            }
          }
          if (state is CustomerError) {
            dev.log('[LOG-UI] Listener: Detected CustomerError: ${state.message}', name: 'CustomerProfilePage');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          dev.log('[LOG-UI] BlocBuilder building with state: ${state.runtimeType}', name: 'CustomerProfilePage');
          
          final customer = (state is CustomerLoaded) 
              ? state.customer 
              : _currentCustomer;

          // --- ۶. مدیریت حالت‌های لودینگ و خطا ---
          if (state is CustomerLoading && customer == null) {
             dev.log('[LOG-UI] Builder: Showing full page loading (Loading, no customer data).', name: 'CustomerProfilePage');
             return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError && customer == null) {
             dev.log('[LOG-UI] Builder: Showing Error widget (Error, no customer data).', name: 'CustomerProfilePage');
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خطا در بارگیری اطلاعات: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                       dev.log('[LOG-UI] "Retry" button pressed.', name: 'CustomerProfilePage');
                       context.read<CustomerCubit>().fetchCustomerDetails();
                    },
                    child: const Text('تلاش مجدد'),
                  )
                ],
              ),
            );
          }
          
          if (customer == null) {
             dev.log('[LOG-UI] Builder: Showing full page loading (Customer is null, state is ${state.runtimeType}).', name: 'CustomerProfilePage');
             return const Center(child: CircularProgressIndicator());
          }
          // --- پایان مدیریت حالت‌ها ---


          dev.log('[LOG-UI] Builder: Showing profile page. IsEditing: $_isEditing, IsNewUser: $_isNewUser', name: 'CustomerProfilePage');
          return RefreshIndicator(
            onRefresh: () async {
              dev.log('[LOG-UI] RefreshIndicator pulled.', name: 'CustomerProfilePage');
              context.read<CustomerCubit>().fetchCustomerDetails();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context, customer),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _isEditing
                        ? _buildEditableForm(context, customer)
                        : _buildReadOnlyProfile(context, customer),
                  ),
                  const SizedBox(height: 16),
                  _buildLogoutButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CustomerEntity customer) {
    final theme = Theme.of(context);
    final avatarUrl = customer.avatarUrl;
    final fallbackLetter = customer.fullName.isNotEmpty
        ? customer.fullName[0].toUpperCase()
        : customer.email.isNotEmpty
          ? customer.email[0].toUpperCase()
          : '؟';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage:
                (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
            backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.1),
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? Text(
                    fallbackLetter,
                    style: TextStyle(
                      fontSize: 40,
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            customer.fullName.isNotEmpty ? customer.fullName : customer.email,
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(height: 4),
          if (customer.fullName.isNotEmpty)
            Text(
              customer.email,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.8)),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            // --- ۷. منطق دکمه (منطق کاربر جدید) ---
            icon: Icon(_isEditing ? (_isNewUser ? Icons.edit_note : Icons.close) : Icons.edit),
            label: Text(_isEditing ? (_isNewUser ? "تکمیل پروفایل" : "انصراف") : "ویرایش پروفایل"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.onPrimary,
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _toggleEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyProfile(BuildContext context, CustomerEntity customer) {
    return Padding(
      key: const ValueKey('readOnly'), // Key برای AnimatedSwitcher
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _infoRow(Icons.person_outline, "نام و نام خانوادگی", customer.fullName),
              const Divider(),
              _infoRow(Icons.phone_outlined, "شماره تلفن", customer.phone),
              const Divider(),
              _infoRow(Icons.email_outlined, "ایمیل", customer.email),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableForm(BuildContext context, CustomerEntity customer) {
    final theme = Theme.of(context);
    return Padding(
      key: const ValueKey('editable'), // Key برای AnimatedSwitcher
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- ۸. پیام خوش‌آمدگویی (منطق کاربر جدید) ---
                if (_isNewUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'خوش آمدید! لطفا اطلاعات پروفایل خود را تکمیل کنید.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: "نام و نام خانوادگی",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'نام الزامی است' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "شماره تلفن",
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'شماره الزامی است' : null,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: customer.email,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "ایمیل (غیرقابل ویرایش)",
                    prefixIcon: Icon(Icons.email_outlined),
                    suffixIcon: Icon(Icons.lock_outline, size: 18),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("ذخیره تغییرات"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _saveProfile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        value.isEmpty ? 'ثبت نشده' : value, // اگر خالی بود، "ثبت نشده" نشان بده
        style: TextStyle(
          color: value.isEmpty ? Colors.grey[600] : null,
          fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      dense: true,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: TextButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text("خروج از حساب کاربری"),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
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
                    Navigator.of(dialogContext).pop();
                    context.read<AuthCubit>().signOut();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}