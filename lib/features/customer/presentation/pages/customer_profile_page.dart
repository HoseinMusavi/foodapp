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

class _CustomerProfilePageState extends State<CustomerProfilePage>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;

  CustomerEntity? _currentCustomer;
  bool _isEditing = false;

  @override
  bool get wantKeepAlive => true; // ✅ جلوگیری از ری‌بیلد هنگام تعویض تب‌ها

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

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate() && _currentCustomer != null) {
      final updatedCustomer = CustomerEntity(
        id: _currentCustomer!.id,
        email: _currentCustomer!.email,
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        avatarUrl: _currentCustomer!.avatarUrl,
        defaultAddressId: _currentCustomer!.defaultAddressId,
      );
      context.read<CustomerCubit>().updateCustomer(updatedCustomer);
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: BlocConsumer<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerLoaded) {
            _currentCustomer = state.customer;
            _updateControllers(state.customer);
          }
          if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomerInitial) {
            context.read<CustomerCubit>().fetchCustomerDetails();
            return const Center(child: CircularProgressIndicator());
          }

          final customer =
              (state is CustomerLoaded) ? state.customer : _currentCustomer;

          if (customer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
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
        : 'U';

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
            customer.fullName,
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            customer.email,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            label: Text(_isEditing ? "انصراف" : "ویرایش پروفایل"),
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
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: "نام و نام خانوادگی",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'نام الزامی است' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "شماره تلفن",
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'شماره الزامی است' : null,
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
      subtitle: Text(value),
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
