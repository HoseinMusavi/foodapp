import 'dart:io';
import 'package:customer_app/core/widgets/custom_network_image.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:customer_app/features/customer/presentation/cubit/customer_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerError && state.message != 'Profile not found') {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('خطا: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is CustomerLoading || state is CustomerInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerLoaded) {
            return ProfileView(customer: state.customer);
          }
          // If state is CustomerError with 'Profile not found', show the create form.
          final currentUser = Supabase.instance.client.auth.currentUser;
          return CreateOrEditProfileForm(
            isEditing: false,
            // Create a dummy entity for the form
            customer: CustomerEntity(
              id: currentUser?.id ?? '',
              email: currentUser?.email ?? '',
              fullName: '',
              phone: '',
            ),
          );
        },
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  final CustomerEntity customer;
  const ProfileView({required this.customer, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 250.0,
          backgroundColor: Theme.of(context).primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(customer.fullName, style: const TextStyle(color: Colors.white)),
            background: customer.avatarUrl != null && customer.avatarUrl!.isNotEmpty
                ? CustomNetworkImage(imageUrl: customer.avatarUrl!, fit: BoxFit.cover)
                : Container(color: Theme.of(context).primaryColor.withOpacity(0.5)),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => Supabase.instance.client.auth.signOut(),
            ),
          ],
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(customer.email),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: Text(customer.phone),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('آدرس‌های من'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                /* Navigate to address page */
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('تاریخچه سفارشات'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                /* Navigate to order history */
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('ویرایش پروفایل'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      // We provide the Cubit to the edit page
                      builder: (_) => BlocProvider.value(
                        value: context.read<CustomerCubit>(),
                        child: CreateOrEditProfileForm(
                          isEditing: true,
                          customer: customer,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class CreateOrEditProfileForm extends StatefulWidget {
  final bool isEditing;
  final CustomerEntity customer;
  const CreateOrEditProfileForm({
    required this.isEditing,
    required this.customer,
    super.key,
  });

  @override
  State<CreateOrEditProfileForm> createState() =>
      _CreateOrEditProfileFormState();
}

class _CreateOrEditProfileFormState extends State<CreateOrEditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.customer.fullName);
    _phoneController = TextEditingController(text: widget.customer.phone);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Compress image
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context
          .read<CustomerCubit>()
          .saveProfile(
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            imageFile: _imageFile,
          )
          .then((_) {
            // After saving, if we are in edit mode, pop the screen
            if (widget.isEditing && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'ویرایش پروفایل' : 'تکمیل پروفایل'),
      ),
      body: BlocListener<CustomerCubit, CustomerState>(
        // This listener will pop the page on successful update
        listener: (context, state) {
          if (state is CustomerLoaded && widget.isEditing) {
             // Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (widget.customer.avatarUrl != null &&
                                  widget.customer.avatarUrl!.isNotEmpty
                              ? NetworkImage(widget.customer.avatarUrl!)
                              : null) as ImageProvider?,
                      child: _imageFile == null &&
                              (widget.customer.avatarUrl == null ||
                                  widget.customer.avatarUrl!.isEmpty)
                          ? const Icon(Icons.person_outline, size: 60)
                          : null,
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'نام و نام خانوادگی',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'لطفا نام خود را وارد کنید' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'شماره تلفن'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'لطفا شماره تلفن را وارد کنید' : null,
                ),
                const SizedBox(height: 32),
                BlocBuilder<CustomerCubit, CustomerState>(
                  builder: (context, state) {
                    if (state is CustomerUpdating) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('ذخیره تغییرات'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}