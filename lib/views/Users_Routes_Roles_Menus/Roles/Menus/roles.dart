import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Roles extends StatefulWidget {
  const Roles({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RolesState createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  final String baseUrl = "https://localhost:7157"; // API Base URL
  final searchController = TextEditingController();
  bool isLoading = true;
  List<Map<String, dynamic>> roles = []; // List to store user roles

  @override
  void initState() {
    super.initState();
    fetchUsers();
    // Fetch users data on initialization
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
  Future<void> addRoleToDatabase(String roleName, int roleLevel) async {
    final token = await getToken(); // Retrieve the token
    if (token == null) {
      print("No token found. Please log in.");
      return;
    }

    final url = Uri.parse('$baseUrl/userrole/create');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "roleName": roleName,
          "roleLevel": roleLevel,
        }),
      );
      if (response.statusCode == 200) {
        // Assuming 200 is the success code for creation
        fetchUsers(); // Refresh the roles list after adding
        // Show floating snackbar on success
        showGlobalSnackBar("Role added successfully!");
      } else {
        fetchUsers();
        showGlobalSnackBar("Failed to add role. Please try again.");
      }
    } catch (e) {
      print('Error adding role: $e');
      // Show floating snackbar in case of error
      showGlobalSnackBar("An error occurred while adding the role.");
    }
  }

  // Function to delete a role
  Future<void> deleteRole(String roleCode) async {
    if (roleCode.isEmpty) {
      print("Invalid roleCode provided: $roleCode");
      return;
    }
    final encodedRoleCode = base64Encode(utf8.encode(roleCode));
    print('Encoded roleCode: $encodedRoleCode');
    final token = await getToken();
    if (token == null) {
      print("No token found. Please log in.");
      return;
    }

    final url =
        Uri.parse('$baseUrl/userrole/delete?RoleCode=${encodedRoleCode}');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Role deleted successfully.');
        fetchUsers();
        showGlobalSnackBar("Role deleted successfully");
      } else {
        showGlobalSnackBar('Failed to delete role.');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error deleting role: $e');
    }
  }

  // Function to edit a role
  Future<void> updateRole(
      int id, String roleCode, String roleName, int roleLevel) async {
    if (roleName.isEmpty || roleLevel <= 0) {
      print("Invalid inputs for role update.");
      return;
    }

    final token = await getToken(); // Retrieve token
    if (token == null) {
      print("No token found. Please log in.");
      return;
    }

    final url = Uri.parse('$baseUrl/userrole/update');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "id": id,
          "roleCode": roleCode,
          "roleName": roleName,
          "roleLevel": roleLevel,
        }),
      );

      if (response.statusCode == 200) {
        fetchUsers();
        showGlobalSnackBar("Role updated successfully!");
      } else {
        showGlobalSnackBar('Failed to update role.');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating role: $e');
    }
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
              "Roles".text.fontFamily(bold).color(Colors.white).size(18).make(),
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
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            String roleName = '';
                            String selectedRoleLevel = ''; // Initially empty

                            // List of role level names (from your roleLevelsMap)
                            List<String> roleLevels =
                                roleLevelsMap.values.toList();

                            return StatefulBuilder(
                              builder: (context, setState) {
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
                                              fontSize: 18, fontFamily: bold),
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

                                        // Role Level Dropdown
                                        DropdownButton<String>(
                                          hint: Text(
                                            selectedRoleLevel.isEmpty
                                                ? "Select Role Level"
                                                : selectedRoleLevel, // Display selected role level
                                          ),
                                          value: selectedRoleLevel.isEmpty
                                              ? null
                                              : selectedRoleLevel,
                                          items: roleLevels.map((level) {
                                            return DropdownMenuItem<String>(
                                              value: level,
                                              child: Text(level),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedRoleLevel =
                                                  newValue ?? '';
                                            });
                                          },
                                          isExpanded: true,
                                        ),
                                        SizedBox(height: 20),
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
                                                if (roleName.isNotEmpty &&
                                                    selectedRoleLevel
                                                        .isNotEmpty) {
                                                  // Get the role level number from the map
                                                  final roleLevel = roleLevelsMap
                                                      .keys
                                                      .firstWhere(
                                                          (key) =>
                                                              roleLevelsMap[
                                                                  key] ==
                                                              selectedRoleLevel,
                                                          orElse: () => -1);

                                                  if (roleLevel != -1) {
                                                    addRoleToDatabase(roleName,
                                                        roleLevel); // Call your function
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  } else {
                                                    print(
                                                        "Invalid role level selected.");
                                                  }
                                                } else {
                                                  print(
                                                      "All fields are required.");
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
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
                        );
                      },
                    ),
                  ),

                  HeightBox(20),

                  // Loading Indicator
                  isLoading
                      ? CircularProgressIndicator()
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 30,
                            columns: const [
                              // DataColumn(
                              //   label: Text(
                              //     "Role Code",
                              //     style: TextStyle(
                              //         fontFamily: bold, fontSize: 16),
                              //   ),
                              // ),
                              DataColumn(
                                label: Text(
                                  "Role Name",
                                  style:
                                      TextStyle(fontFamily: bold, fontSize: 16),
                                ),
                              ),
                              // DataColumn(
                              //   label: Text(
                              //     "Role Level",
                              //     style: TextStyle(
                              //         fontFamily: bold, fontSize: 16),
                              //   ),
                              // ),
                              DataColumn(
                                label: Text(
                                  "Actions",
                                  style:
                                      TextStyle(fontFamily: bold, fontSize: 16),
                                ),
                              ),
                            ],
                            rows: roles.isNotEmpty
                                ? roles.map((role) {
                                    // Ensure roleLevel is an int; convert if necessary
                                    // final roleLevelValue =
                                    //     role['roleLevel'] is int
                                    //         ? role['roleLevel']
                                    //         : int.tryParse(
                                    //                 role['roleLevel']
                                    //                     .toString()) ??
                                    //             -1;

                                    // Map the roleLevel value
                                    // final roleLevelText =
                                    //     roleLevelsMap[roleLevelValue] ??
                                    //         'Unknown';
                                    // final roleCode =
                                    //     role['roleCode']?.toString() ??
                                    //         'N/A';
                                    final roleName =
                                        role['roleName']?.toString() ?? 'N/A';

                                    return DataRow(cells: [
                                      // DataCell(Text(
                                      //   roleCode,
                                      //   style: const TextStyle(
                                      //       fontSize: 14),
                                      // )),
                                      DataCell(Text(
                                        roleName,
                                        style: const TextStyle(fontSize: 14),
                                      )),
                                      // DataCell(Text(
                                      //   roleLevelText,
                                      //   style: const TextStyle(
                                      //       fontSize: 14),
                                      // )),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              //Edit function
                                              onPressed: () {
                                                // Get current values for the selected role
                                                final currentRoleId = role[
                                                        'id'] ??
                                                    0; // Assuming 'id' exists in role
                                                final currentRoleCode =
                                                    role['roleCode']
                                                            ?.toString() ??
                                                        '';
                                                final currentRoleName =
                                                    role['roleName']
                                                            ?.toString() ??
                                                        '';
                                                final currentRoleLevel = role[
                                                        'roleLevel'] is int
                                                    ? role['roleLevel']
                                                    : int.tryParse(role[
                                                                    'roleLevel']
                                                                ?.toString() ??
                                                            '') ??
                                                        -1;

                                                // Variables for updated values
                                                String updatedRoleName =
                                                    currentRoleName;
                                                int selectedRoleLevel =
                                                    currentRoleLevel;

                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text('Edit Role'),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            // Role Name Input
                                                            TextField(
                                                              controller:
                                                                  TextEditingController(
                                                                      text:
                                                                          updatedRoleName),
                                                              onChanged:
                                                                  (value) {
                                                                updatedRoleName =
                                                                    value;
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Role Name',
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 16),
                                                            // Role Level Dropdown
                                                            DropdownButtonFormField<
                                                                int>(
                                                              value: selectedRoleLevel >=
                                                                      0
                                                                  ? selectedRoleLevel
                                                                  : null,
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Role Level',
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                              items: roleLevelsMap
                                                                  .entries
                                                                  .map((entry) {
                                                                return DropdownMenuItem<
                                                                    int>(
                                                                  value:
                                                                      entry.key,
                                                                  child: Text(entry
                                                                      .value), // Display human-readable name
                                                                );
                                                              }).toList(),
                                                              onChanged: (int?
                                                                  newValue) {
                                                                selectedRoleLevel =
                                                                    newValue ??
                                                                        currentRoleLevel;
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text('Cancel'),
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                redColor,
                                                          ),
                                                          onPressed: () {
                                                            // Validate inputs
                                                            if (updatedRoleName
                                                                    .isEmpty ||
                                                                selectedRoleLevel <
                                                                    0) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Please fill all fields.')),
                                                              );
                                                              return;
                                                            }

                                                            // Call the updateRole function with updated values
                                                            updateRole(
                                                              currentRoleId, // Pass the ID
                                                              currentRoleCode, // Pass the Role Code
                                                              updatedRoleName, // Updated Role Name
                                                              selectedRoleLevel, // Updated Role Level
                                                            );

                                                            // Refresh UI and close the dialog
                                                            fetchUsers();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            ScaffoldMessenger
                                                                .of(context);
                                                            showGlobalSnackBar(
                                                                'Role updated successfully.');
                                                          },
                                                          child: Text(
                                                            'Update',
                                                            style: TextStyle(
                                                                color:
                                                                    whiteColor),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              // delete function
                                              onPressed: () {
                                                final roleCode =
                                                    role['roleCode']
                                                        ?.toString();
                                                if (roleCode != null &&
                                                    roleCode.isNotEmpty) {
                                                  print(
                                                      'Attempting to delete role with roleCode: $roleCode');
                                                  deleteRole(
                                                      roleCode); // Call deleteRole with a string
                                                } else {
                                                  print(
                                                      'Invalid roleCode: $roleCode');
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]);
                                  }).toList()
                                : [
                                    const DataRow(cells: [
                                      DataCell(Text("No roles available")),
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                    ]),
                                  ],
                          ),
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
    );
  }
}
