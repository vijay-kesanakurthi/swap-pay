// lib/modules/group/group_screen.dart
import 'package:bill_split/controllers/group_controller.dart';
import 'package:bill_split/routes/app_routes.dart';
import 'package:bill_split/screens/group_detailed.dart';
import 'package:bill_split/screens/join_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupController = Get.put(GroupController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Groups"),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade50,
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.deepPurple),
                onPressed: () => Get.toNamed(AppRoutes.profile),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final groups = groupController.groups;

          return RefreshIndicator(
            onRefresh: () {
              return groupController.getAllGroups();
            },
            child:
                groupController.isGettingGroups.value
                    ? const Center(child: CircularProgressIndicator())
                    : groups.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.group_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "You are not in any groups.",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Create or join a group to get started.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: groups.length,
                      itemBuilder: (_, index) {
                        final group = groups[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap:
                                () => Get.to(
                                  () => GroupDetailScreen(groupId: group.id),
                                ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade600,
                              child: Text(
                                group.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              group.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
          );
        }),
      ),
      bottomNavigationBar: BottomActionBar(
        onCreateGroup: () => _showCreateGroupDialog(context, groupController),
        onJoinGroup: () {
          Get.to(() => const JoinGroupScannerScreen());
        },
      ),
    );
  }

  void _showCreateGroupDialog(
    BuildContext context,
    GroupController controller,
  ) {
    final groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Create a New Group",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: groupNameController,
                      decoration: InputDecoration(
                        labelText: "Group Name",
                        prefixIcon: const Icon(Icons.group),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 8),
                        Obx(
                          () => ElevatedButton.icon(
                            icon:
                                controller.isCreatingGroup.value
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(Icons.check),
                            label: Text(
                              controller.isCreatingGroup.value
                                  ? "Creating..."
                                  : "Create",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                controller.isCreatingGroup.value
                                    ? null
                                    : () async {
                                      final name =
                                          groupNameController.text.trim();
                                      if (name.isEmpty) return;

                                      controller.isCreatingGroup.value = true;

                                      try {
                                        await controller.createGroup(name);
                                        Get.back();
                                      } catch (e) {
                                        Get.snackbar(
                                          "Error",
                                          "Failed to create group: $e",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      } finally {
                                        controller.isCreatingGroup.value =
                                            false;
                                      }
                                    },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

class BottomActionBar extends StatelessWidget {
  final VoidCallback onCreateGroup;
  final VoidCallback onJoinGroup;

  const BottomActionBar({
    super.key,
    required this.onCreateGroup,
    required this.onJoinGroup,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      elevation: 12,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionIcon(
            icon: Icons.qr_code_scanner,
            label: "Join Group",
            onTap: onJoinGroup,
          ),
          _ActionIcon(
            icon: Icons.group_add,
            label: "Create Group",
            onTap: onCreateGroup,
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 26, color: Colors.deepPurple),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
