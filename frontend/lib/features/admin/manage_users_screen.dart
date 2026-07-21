import 'package:flutter/material.dart';
import 'package:my_app/core/services/admin_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<AdminUser> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    final result = await AdminService.getAllUsers();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        users = result.users ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      _showSnack(result.message, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade400 : Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _toggleStatus(AdminUser user) async {
    final result = await AdminService.toggleStatus(user.id);
    if (!mounted) return;

    _showSnack(result.message, isError: !result.success);
    if (result.success) _loadUsers();
  }

  Future<void> _deleteUser(AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          "Delete User",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete ${user.name}? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await AdminService.deleteUser(user.id);
    if (!mounted) return;

    _showSnack(result.message, isError: !result.success);
    if (result.success) _loadUsers();
  }

  void _openUserModal({AdminUser? user}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFDF5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => UserFormModal(
        user: user,
        onSaved: _loadUsers,
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case "admin":
        return Colors.amber.shade700;
      case "service_provider":
        return Colors.green.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case "admin":
        return Icons.admin_panel_settings_rounded;
      case "service_provider":
        return Icons.home_repair_service_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF5),
        foregroundColor: Colors.black87,
        title: const Text(
          "Manage Users",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openUserModal(),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add User",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.amber.shade700),
            )
          : users.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.people_outline_rounded,
                            size: 50,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "No Users Found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: Colors.amber.shade700,
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(.10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        _roleColor(user.role).withOpacity(0.12),
                                    child: Icon(
                                      _roleIcon(user.role),
                                      color: _roleColor(user.role),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          user.email,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        Text(
                                          user.phoneNumber,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (user.isActive
                                              ? Colors.green.shade600
                                              : Colors.red.shade400)
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      user.isActive ? "Active" : "Inactive",
                                      style: TextStyle(
                                        color: user.isActive
                                            ? Colors.green.shade700
                                            : Colors.red.shade400,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),
                              Divider(color: Colors.grey.shade200, height: 1),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 42,
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _openUserModal(user: user),
                                        icon: Icon(
                                          Icons.edit_rounded,
                                          size: 16,
                                          color: Colors.amber.shade700,
                                        ),
                                        label: Text(
                                          "Edit",
                                          style: TextStyle(
                                            color: Colors.amber.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.amber.shade300,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 42,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.red.shade200,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () => _deleteUser(user),
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          size: 16,
                                          color: Colors.red.shade400,
                                        ),
                                        label: Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.red.shade400,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      tooltip:
                                          user.isActive ? "Deactivate" : "Activate",
                                      icon: Icon(
                                        user.isActive
                                            ? Icons.toggle_on_rounded
                                            : Icons.toggle_off_rounded,
                                        color: user.isActive
                                            ? Colors.green.shade600
                                            : Colors.grey.shade500,
                                        size: 28,
                                      ),
                                      onPressed: () => _toggleStatus(user),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ---------------- ADD / EDIT USER MODAL ----------------
class UserFormModal extends StatefulWidget {
  final AdminUser? user;
  final VoidCallback onSaved;

  const UserFormModal({super.key, this.user, required this.onSaved});

  @override
  State<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends State<UserFormModal> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = "user";
  bool isSaving = false;

  bool get isEditMode => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      nameController.text = widget.user!.name;
      emailController.text = widget.user!.email;
      phoneController.text = widget.user!.phoneNumber;
      selectedRole = widget.user!.role;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade400 : Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || (!isEditMode && password.isEmpty)) {
      _showSnack("Please fill all fields", isError: true);
      return;
    }

    setState(() => isSaving = true);

    final result = isEditMode
        ? await AdminService.updateUser(
            userId: widget.user!.id,
            name: name,
            email: email,
            phoneNumber: phone,
            role: selectedRole,
          )
        : await AdminService.createUser(
            name: name,
            email: email,
            password: password,
            phoneNumber: phone,
            role: selectedRole,
          );

    if (!mounted) return;
    setState(() => isSaving = false);

    _showSnack(result.message, isError: !result.success);

    if (result.success) {
      widget.onSaved();
      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: Colors.amber.shade700),
      filled: true,
      fillColor: Colors.amber.shade50.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.amber, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEditMode ? Icons.edit_rounded : Icons.person_add_rounded,
                color: Colors.amber.shade700,
                size: 26,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              isEditMode ? "Edit User" : "Add New User",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              decoration: _inputDecoration(
                label: "Full Name",
                icon: Icons.person_rounded,
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                label: "Email",
                icon: Icons.email_rounded,
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                label: "Phone Number",
                icon: Icons.phone_rounded,
              ),
            ),

            if (!isEditMode) ...[
              const SizedBox(height: 14),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: _inputDecoration(
                  label: "Password",
                  icon: Icons.lock_rounded,
                ),
              ),
            ],

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: _inputDecoration(
                label: "Role",
                icon: Icons.badge_rounded,
              ),
              items: const [
                DropdownMenuItem(value: "user", child: Text("User")),
                DropdownMenuItem(
                    value: "service_provider",
                    child: Text("Service Provider")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (value) {
                if (value != null) setState(() => selectedRole = value);
              },
            ),

            const SizedBox(height: 26),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isSaving ? null : _save,
                child: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditMode ? "Update User" : "Create User",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}