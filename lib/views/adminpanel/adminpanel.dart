import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final String baseUrl = "https://localhost:7157"; // API Base URL
  final searchController = TextEditingController();
  bool isLoading = true;
  List<Map<String, dynamic>> roles = []; // List to store user roles

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users data on initialization
  }

  void _addRole(String name, String level) {
    setState(() {
      roles.add({
        'roleCode':
            'new_role_code', // You can generate or assign a new code if needed
        'roleName': name,
        'roleLevel':
            level, // Ensure this matches the expected type (string or integer)
      });
    });
  }

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token =
        prefs.getString('authToken'); // Get token from shared preferences
    print("Token retrieved: $token");
    return token;
  }

  // Function to fetch users from the API
  Future<void> fetchUsers() async {
    final token = await getToken(); // Get the token from shared preferences

    if (token == null) {
      print("No token found. Please log in.");
      return;
    }

    final url = Uri.parse('$baseUrl/userrole'); // API endpoint for users

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rolesData = jsonDecode(response.body);
        setState(() {
          roles = rolesData.map((role) {
            return {
              'roleCode': role['roleCode']?.toString() ?? 'N/A',
              'roleName': role['roleName']?.toString() ?? 'N/A',
              'roleLevel': role['roleLevel']?.toString() ?? 'N/A',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch users: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to add a new role to the database
  Future<void> addRoleToDatabase(
      String roleCode, String roleName, int roleLevel) async {
    final token = await getToken(); // Retrieve the token
    if (token == null) {
      print("No token found. Please log in.");
      return;
    }

    final url = Uri.parse(
        '$baseUrl/userrole/create'); // Replace 'your_endpoint' with your API endpoint

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "roleCode": roleCode,
          "roleName": roleName,
          "roleLevel": roleLevel,
        }),
      );

      if (response.statusCode == 201) {
        // Assuming 201 is the success code for creation
        print("Role added successfully!");
        fetchUsers(); // Refresh the roles list after adding
      } else {
        print('Failed to add role: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error adding role: $e');
    }
  }

  // Function to delete a role
  Future<void> deleteRole(int roleId) async {
    final token = await getToken();
    if (token == null) {
      print("No token found. Please log in.");
      return;
    }

    final url =
        Uri.parse('$baseUrl/userrole/$roleId'); // API endpoint for deleting

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Successfully deleted the role
        print('Role deleted');
        fetchUsers(); // Refresh the list
      } else {
        print('Failed to delete role: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting role: $e');
    }
  }

  // Function to edit a role
  Future<void> editRole(int roleId) async {
    // You can implement the edit functionality here
    // For example, show a dialog to edit the role name, role code, or level
    print("Edit role with ID: $roleId");
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: context.screenHeight * 0.02),
                      applogoWidget(),
                      10.heightBox,
                      "Dashboard"
                          .text
                          .fontFamily(bold)
                          .color(Colors.white)
                          .size(18)
                          .make(),
                      15.heightBox,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Field
                          TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Add Role Button
                          Align(
                            alignment: Alignment.topRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: redColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text(
                                "Add Role",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: bold,
                                    fontSize: 14),
                              ),
                              // Updated Add Role Button Functionality
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    String roleCode = '';
                                    String roleName = '';
                                    String roleLevelStr = '';

                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title
                                            Text(
                                              "Add New Role",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: bold),
                                            ),
                                            SizedBox(height: 20),

                                            // Role Code Field
                                            TextField(
                                              decoration: InputDecoration(
                                                labelText: "Role Code",
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) {
                                                roleCode = value;
                                              },
                                            ),
                                            SizedBox(height: 20),

                                            // Role Name Field
                                            TextField(
                                              decoration: InputDecoration(
                                                labelText: "Role Name",
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) {
                                                roleName = value;
                                              },
                                            ),
                                            SizedBox(height: 20),

                                            // Role Level Field
                                            TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: "Role Level",
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) {
                                                roleLevelStr = value;
                                              },
                                            ),
                                            SizedBox(height: 20),

                                            // Action Buttons
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text("Cancel",
                                                      style: TextStyle(
                                                          color: redColor)),
                                                ),
                                                SizedBox(width: 10),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (roleCode.isNotEmpty &&
                                                        roleName.isNotEmpty &&
                                                        roleLevelStr
                                                            .isNotEmpty) {
                                                      final roleLevel =
                                                          int.tryParse(
                                                              roleLevelStr);

                                                      if (roleLevel != null) {
                                                        addRoleToDatabase(
                                                            roleCode,
                                                            roleName,
                                                            roleLevel);
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      } else {
                                                        print(
                                                            "Invalid role level. Please enter a number.");
                                                      }
                                                    } else {
                                                      print(
                                                          "All fields are required.");
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: redColor,
                                                  ),
                                                  child: Text(
                                                    "Save",
                                                    style: TextStyle(
                                                        color: whiteColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          HeightBox(20),

                          // Table Header
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: 'Role Code'
                                    .text
                                    .fontFamily(bold)
                                    .size(16)
                                    .make(),
                              ),
                              Expanded(
                                flex: 2,
                                child: 'Role Name'
                                    .text
                                    .fontFamily(bold)
                                    .size(16)
                                    .make(),
                              ),
                              Expanded(
                                flex: 1,
                                child: 'Role Level'
                                    .text
                                    .fontFamily(bold)
                                    .size(16)
                                    .make(),
                              ),
                              Expanded(
                                flex: 1,
                                child: 'Actions'
                                    .text
                                    .fontFamily(bold)
                                    .size(16)
                                    .make(),
                              ),
                            ],
                          ),
                          Divider(),

                          // Table Rows
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: roles.length,
                            itemBuilder: (context, index) {
                              final role = roles[index];

                              // Ensure roleLevel is an int, otherwise, convert it
                              final roleLevelValue = role['roleLevel'] is int
                                  ? role['roleLevel']
                                  : int.tryParse(
                                          role['roleLevel'].toString()) ??
                                      -1;

                              // Map the roleLevel value
                              final roleLevelText =
                                  roleLevelsMap[roleLevelValue] ?? 'Unknown';

                              final roleCode =
                                  role['roleCode']?.toString() ?? 'N/A';
                              final roleName =
                                  role['roleName']?.toString() ?? 'N/A';

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: roleCode.text.size(14).make(),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: roleName.text.size(14).make(),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: roleLevelText.text.size(14).make(),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              // add functionality
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              // add functionality
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )
                          .box
                          .white
                          .rounded
                          .padding(const EdgeInsets.all(16))
                          .width(context.screenWidth - 70)
                          .shadowSm
                          .make(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
