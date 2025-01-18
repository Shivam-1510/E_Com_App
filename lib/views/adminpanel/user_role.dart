import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserRole extends StatefulWidget {
  const UserRole({super.key});

  @override
  State<UserRole> createState() => _UserRoleState();
}

class _UserRoleState extends State<UserRole> {
  final String baseUrl = "https://localhost:7157";
  final searchController = TextEditingController();

  // List to store the fetched user data
  List<Map<String, dynamic>> userData = [];

  // Dropdown-related fields
  final Map<int, String> roleLevelsMap = {
    0: "BASE",
    1: "PRIMARY",
    2: "SECONDARY",
    3: "INTERMEDIATE",
    4: "MANAGEMENT",
    5: "AUTHORITY",
    6: "ADMIN",
    7: "SUPER ADMIN",
  };
  late List<String> roleLevels;
  String? selectedRoleLevel; // Store the selected role level as a String

  int? userRoleLevel; // Variable to store the user's assigned role level

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    roleLevels = roleLevelsMap.values.toList();
    fetchUsers(); // Fetch the user data when the screen loads
  }

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  // Function to fetch users from the API
  Future<void> fetchUsers() async {
    final token = await getToken(); // Get the token from shared preferences

    if (token == null) {
      print("No token found. Please log in.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$baseUrl/user/users'); // API endpoint for users

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
          userData = rolesData.map((role) {
            final roleLevel = role['userRole']['roleLevel'] ?? -1;
            if (roleLevel != -1) {
              userRoleLevel = roleLevel; // Store the user's role level
            }
            return {
              'name': role['user']['name'] ?? 'N/A',
              'mobile': role['user']['mobileNumber'] ?? 'N/A',
              'status': role['user']['isActive'] ?? 'N/A',
              'lastLogin': role['user']['lastLogin'] ?? 'N/A',
              'createdBy': role['user']['createdBy'] ?? 'N/A',
              'roleLevel': roleLevel,
            };
          }).toList();
          // Set the selected role level for the dropdown
          selectedRoleLevel = roleLevelsMap[userRoleLevel ?? -1];
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

  // Function to show user details dialog
  void showUserDetails(Map<String, dynamic> user) {
    // Extract the roleLevel from userRole
    final roleLevel = user['roleLevel'] ?? -1; // Default to -1 if missing

    // Map the roleLevel value using the roleLevelsMap
    final roleLevelText = roleLevelsMap[roleLevel] ??
        'Unknown'; // Default to 'Unknown' if not found

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("User Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${user['name']}"),
              Text("Mobile Number: ${user['mobile']}"),
              Text("Status: ${user['status']}"),
              Text("Last Login: ${user['lastLogin']}"),
              Text("Created By: ${user['createdBy']}"),
              Text(
                  "Role Level: $roleLevelText"), // Display the role level as a string
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Filter users based on the selected role level
  List<Map<String, dynamic>> getFilteredUsers() {
    if (selectedRoleLevel == null) return [];

    final selectedRoleIndex = roleLevels.indexOf(selectedRoleLevel!);
    if (selectedRoleIndex == -1) return [];

    return userData.where((user) {
      return user['roleLevel'] == selectedRoleIndex;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(height: context.screenHeight * 0.02),
              applogoWidget(),
              10.heightBox,
              "User Role"
                  .text
                  .fontFamily(bold)
                  .color(Colors.white)
                  .size(18)
                  .make(),
              15.heightBox,
              Column(
                children: [
                  // Search Field
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  15.heightBox,
                  // Dropdown and Create User button
                  Row(
                    children: [
                      // Dropdown Button wrapped in Flexible
                      Flexible(
                        child: DropdownButton<String>(
                          hint: Text(
                            selectedRoleLevel ?? "Select Role Level",
                          ),
                          value: selectedRoleLevel,
                          items: roleLevels.map((level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRoleLevel = newValue;
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                      20.widthBox,
                      // Create User Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Replace with your redColor
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Create User",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'bold', // Replace with your font name
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              String userName = '';
                              String mobileNumber = '';
                              String email = '';
                              String state = '';
                              String district = '';
                              String village = '';
                              String role = '';
                              String address = '';
                              String pinCode = '';
                              String panNumber = '';
                              String password = '';
                              bool isActive = false;

                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title
                                            Text(
                                              "Register User",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'bold'),
                                            ),
                                            const SizedBox(height: 20),

                                            // User Name Field
                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: "User Name",
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) =>
                                                  userName = value,
                                            ),
                                            const SizedBox(height: 20),

                                            // Mobile Number Field
                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: "Mobile Number",
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.phone,
                                              onChanged: (value) =>
                                                  mobileNumber = value,
                                            ),
                                            const SizedBox(height: 20),

                                            // Email Field
                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: "E-Mail",
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              onChanged: (value) =>
                                                  email = value,
                                            ),
                                            const SizedBox(height: 20),

                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: "Address",
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              onChanged: (value) =>
                                                  email = value,
                                            ),
                                            const SizedBox(height: 20),
                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: "Pin Code",
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              onChanged: (value) =>
                                                  email = value,
                                            ),
                                            const SizedBox(height: 20),

                                            DropdownButtonFormField<String>(
                                              decoration: const InputDecoration(
                                                labelText: "Role",
                                                border: OutlineInputBorder(),
                                              ),
                                              items: [
                                                'Role 1 ',
                                                'Role 2 '
                                              ] // Replace with actual districts
                                                  .map((district) =>
                                                      DropdownMenuItem(
                                                        value: district,
                                                        child: Text(district),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) =>
                                                  district = value ?? '',
                                            ),
                                            const SizedBox(height: 20),

                                            // More Fields...
                                            // Continue adding TextFields or Dropdowns similar to the above for other fields.

                                            // Status Checkbox
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: isActive,
                                                  onChanged: (value) =>
                                                      setState(() => isActive =
                                                          value ?? false),
                                                ),
                                                const Text("Is Active"),
                                              ],
                                            ),
                                            const SizedBox(height: 20),

                                            // Buttons
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        color: redColor),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // Add your save logic here
                                                    print(
                                                        "User Name: $userName");
                                                    print(
                                                        "Mobile Number: $mobileNumber");
                                                    // Add other prints for debugging
                                                    Navigator.pop(context);
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
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  15.heightBox,
                  // Loading indicator
                  isLoading
                      ? CircularProgressIndicator()
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 30,
                            columns: const [
                              DataColumn(
                                  label: Text(
                                "User Name",
                                style: TextStyle(fontFamily: bold),
                              )),
                              // DataColumn(
                              //     label: Text(
                              //   "Phone Number",
                              //   style: TextStyle(fontFamily: bold),
                              // )),
                              DataColumn(
                                  label: Text(
                                "Actions",
                                style: TextStyle(fontFamily: bold),
                              )),
                            ],
                            rows: getFilteredUsers().isNotEmpty
                                ? getFilteredUsers().map((user) {
                                    return DataRow(cells: [
                                      DataCell(Text(user["name"])),
                                      // DataCell(Text(user["mobile"])),
                                      DataCell(
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.visibility,
                                                  color: Colors.green),
                                              onPressed: () {
                                                showUserDetails(
                                                    user); // Show details dialog
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () {
                                                // Edit functionality
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                // Delete functionality
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]);
                                  }).toList()
                                : [
                                    DataRow(cells: [
                                      DataCell(Text("No users found")),
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                    ])
                                  ],
                          ),
                        ),
                ],
              )
                  .box
                  .white
                  .rounded
                  .padding(const EdgeInsets.all(20)) // Adjusted padding
                  .width(
                      context.screenWidth - 70) // Adjust the width dynamically
                  .shadowSm
                  .make(),
            ],
          ),
        ),
      ),
    );
  }
}
