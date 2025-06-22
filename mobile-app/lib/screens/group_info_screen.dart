import 'package:bill_split/controllers/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  const GroupInfoScreen({super.key, required this.groupId});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final groupController = Get.find<GroupController>();

  @override
  void initState() {
    super.initState();
    groupController.getGroupMembers(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    final group = groupController.getGroupById(widget.groupId);

    return Scaffold(
      appBar: AppBar(title: const Text("Group Info"), elevation: 2),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child:
                    groupController.isFetchingGroupMembers.value
                        ? const Center(child: CircularProgressIndicator())
                        : groupController.members.isEmpty
                        ? const Center(
                          child: Text(
                            "No members in this group.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              "Group Members (${groupController.members.length})",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.separated(
                                itemCount: groupController.members.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  final member = groupController.members[index];
                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue.shade50,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                      title: Text(
                                        member.name?.isNotEmpty == true
                                            ? member.name!
                                            : "${member.walletAddress.substring(0, 6)}...",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            member.walletAddress,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Joined: ${DateFormat('dd MMM yyyy').format(member.joinedAt)}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.copy, size: 20),
                                        tooltip: "Copy Wallet",
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: member.walletAddress,
                                            ),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Wallet address copied",
                                              ),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
              ),
            ),
            if (group != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Invite Others",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QrImageView(
                      data: group.inviteCode,
                      version: QrVersions.auto,
                      size: 150,
                      backgroundColor: Colors.white,
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: const Size(30, 30),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Invite Code: ${group.inviteCode}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: group.inviteCode),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Invite code copied"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text("Copy Invite Code"),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }
}
