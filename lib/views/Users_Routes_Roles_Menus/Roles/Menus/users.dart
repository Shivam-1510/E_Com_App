import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/getloginuesrrole.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserRole extends StatefulWidget {
  const UserRole({super.key});

  @override
  State<UserRole> createState() => _UserRoleState();
}

class _UserRoleState extends State<UserRole> {
  final String baseUrl = "https://localhost:5001";
  final searchController = TextEditingController();
  List<Map<String, dynamic>> roles2 = []; // List to store user roles
  // List to store the fetched user data
  List<Map<String, dynamic>> userData = [];
  Map<String, dynamic>? _loggedInUser; // To store logged-in user details
  final UserRoleService _userRoleService = UserRoleService();

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
  String? selectedRoleLevel;
  int? selectRoleLevel2; // Store the selected role level as an integer
  int? selectedRoleLevelValue; // Store the selected role level as an integer
  int? userRoleLevel; // Variable to store the user's assigned role level

  bool isLoading = true;
  String? selectedRoleCode;

  @override
  void initState() {
    super.initState();
    fetchLoggedInUserDetails(); // Fetch logged-in user role on load
    roleLevels = roleLevelsMap.values.toList();
    fetchRoles();
  }

  // Fetch logged-in user role and update the state
  Future<void> fetchLoggedInUserDetails() async {
    final userDetails =
        await _userRoleService.getUserDetails(); // Fetch full user data

    if (userDetails != null) {
      setState(() {
        userRoleLevel = userDetails['roleLevel']; // Extract role level
        // Store full user details if needed
      });
    }
  }

  // Function to check if the logged in user is a SUPER ADMIN
  bool isSuperAdmin() {
    return _loggedInUser?['roleLevel'] == 7;
  }

  // Function to get the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return token;
  }

  // Function to fetch roles from the API
  Future<void> fetchRoles() async {
    final token = await getToken(); // Get the token from shared preferences
    if (token == null) {
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
        final List<dynamic> roles2Data = jsonDecode(response.body);
        setState(() {
          roles2 = roles2Data.map((role) {
            return {
              'roleCode': role['roleCode']?.toString() ?? 'N/A',
              'roleName': role['roleName']?.toString() ?? 'N/A',
              'roleLevel': role['roleLevel']?.toString() ?? 'N/A',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to fetch users based on roleCode
  Future<void> fetchUsers(String roleCode) async {
    final token = await getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final encodedRoleCode =
        base64Encode(utf8.encode(roleCode)); // Encode roleCode
    // final encodedUserCode =
    //     base64Encode(utf8.encode(userCode)); // Encode userCode

    final url = Uri.parse(
        '$baseUrl/user/users?roleCode=$encodedRoleCode'); // API endpoint

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
            return {
              'name': role['user']['name'] ?? 'N/A',
              'mobile': role['user']['mobileNumber'] ?? 'N/A',
              'status': role['user']['isActive'] ?? 'N/A',
              'lastLogin': role['user']['lastLogin'] ?? 'N/A',
              'createdBy': role['user']['createdBy'] ?? 'N/A',
              'roleLevel': role['userRole']['roleLevel'] ?? 'N/A',
              'userCode': role['user']['userCode'] ?? 'N/A',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to fetchuserRolebased on roleCode
  Future<void> fetchUserRole(
    String roleCode,
  ) async {
    final token = await getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final encodedRoleCode =
        base64Encode(utf8.encode(roleCode)); // Encode roleCode
    // final encodedUserCode =
    //     base64Encode(utf8.encode(userCode)); // Encode userCode

    final url = Uri.parse(
        '$baseUrl/register/registeruser?roleCode=$encodedRoleCode'); // API endpoint

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
            return {
              'name': role['user']['name'] ?? 'N/A',
              'mobile': role['user']['mobileNumber'] ?? 'N/A',
              'status': role['user']['isActive'] ?? 'N/A',
              'lastLogin': role['user']['lastLogin'] ?? 'N/A',
              'createdBy': role['user']['createdBy'] ?? 'N/A',
              'roleLevel': role['userRole']['roleLevel'] ?? 'N/A',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to show user details dialog
  void showUserDetails(Map<String, dynamic> user) {
    final roleLevel = user['roleLevel'] ?? -1; // Default to -1 if missing
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
              Text("User Code: ${user['userCode']}"),
              Text("Role Level: $roleLevelText"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Fucntion to add users in Database
  Future<void> addUserToDatabase({
    required String roleCode,
    required String userName,
    required String passWord,
    required String mobileNumber,
    required String email,
    required String address,
    required String pinCode,
    required String panNumber,
    required bool isActive,
  }) async {
    final token = await getToken(); // Retrieve the token
    if (token == null) {
      return;
    }

    final encodedRoleCode =
        base64Encode(utf8.encode(roleCode)); // Encode the RoleCode

    final url =
        Uri.parse('$baseUrl/register/registeruser?RoleCode=$encodedRoleCode');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          // User data
          "name": userName,
          "password": passWord,
          "mobileNumber": mobileNumber,
          "eMail": email,
          "panNumber": panNumber,
          "address": address,
          "pinCode": pinCode,
          "isActive": isActive,
        }),
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar("User added successfully!");
      } else {
        showGlobalSnackBar("Failed to add user");
      }
    } catch (e) {}
  }

  // Filter users based on the selected role level

  List<Map<String, dynamic>> getFilteredUsers() {
    if (selectRoleLevel2 == null) return [];

    final selectedRoleIndex = roleLevels.indexOf(selectedRoleLevel!);
    if (selectedRoleIndex == -1) return [];

    return userData.where((user) {
      return user['roleLevel'] == selectedRoleIndex;
    }).toList();
  }

  // Function to delete a user
  Future<void> deleteUser(String userCode) async {
    final token = await _userRoleService.getToken();
    if (token == null) {
      return;
    }

    final encodedUserCode = base64Encode(utf8.encode(userCode));
    final url =
        Uri.parse('$baseUrl/management/delete?UserCode=$encodedUserCode');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        showGlobalSnackBar("User deleted successfully.");
        fetchRoles(); // Refresh roles after deletion
      } else {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        appBar: AppBar(
            title: Text(
              'Users',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: IconThemeData(color: Colors.white)),
        drawer: CustomDrawer(),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: context.screenHeight * 0.02),
              applogoWidget(),
              20.heightBox,
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
                  Row(
                    children: [
                      // Dropdown Button wrapped in Flexible
                      Flexible(
                        child: DropdownButton<String>(
                          hint: const Text("Select Role Name"), // Default hint
                          value:
                              selectedRoleCode, // Currently selected roleCode
                          items: roles2.map((role) {
                            return DropdownMenuItem<String>(
                              value:
                                  role['roleCode'], // Use roleCode as the value
                              child: Text(role['roleName'] ??
                                  "Unknown"), // Display roleName
                            );
                          }).toList(),
                          onChanged: (String? roleCode) async {
                            setState(() {
                              selectedRoleCode = roleCode;
                              // Update the selected role code
                              fetchUsers(selectedRoleCode!);
                            });
                          },
                          isExpanded:
                              true, // Ensures the dropdown takes the full width
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
                              String passWord = '';
                              String mobileNumber = '';
                              String email = '';
                              String address = '';
                              String pinCode = '';
                              String panNumber = '';
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
                                            // PASSWORD
                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: "Password",
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) =>
                                                  passWord = value,
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

                                            // Address Field
                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: "Address",
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) =>
                                                  address = value,
                                            ),
                                            const SizedBox(height: 20),

                                            // Pin Code Field
                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: "Pin Code",
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) =>
                                                  pinCode = value,
                                            ),
                                            const SizedBox(height: 20),

                                            // Pan Number Field
                                            TextField(
                                              decoration: const InputDecoration(
                                                labelText: "Pan Number",
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (value) =>
                                                  panNumber = value,
                                            ),
                                            const SizedBox(height: 20),
                                            // Dropdown
                                            Flexible(
                                              child: DropdownButton<String>(
                                                hint: const Text(
                                                    "Select Role"), // Default hint
                                                value:
                                                    selectedRoleCode, // Currently selected roleCode
                                                items: roles2.map((role) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: role[
                                                        'roleCode'], // Use roleCode as the value
                                                    child: Text(role[
                                                            'roleName'] ??
                                                        "Unknown"), // Display roleName
                                                  );
                                                }).toList(),
                                                onChanged:
                                                    (String? roleCode) async {
                                                  setState(() {
                                                    selectedRoleCode = roleCode;
                                                    // Update the selected role code
                                                    fetchUserRole(
                                                        selectedRoleCode!);
                                                  });
                                                },
                                                isExpanded:
                                                    true, // Ensures the dropdown takes the full width
                                              ),
                                            ),

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
                                                    addUserToDatabase(
                                                      roleCode: selectedRoleCode ??
                                                          '', // Check if this has a valid value
                                                      userName: userName,
                                                      passWord: passWord,
                                                      mobileNumber:
                                                          mobileNumber,
                                                      email: email,
                                                      address: address,
                                                      pinCode: pinCode,
                                                      panNumber: panNumber,
                                                      isActive: isActive,
                                                    );

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
                                                )
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
                  // Loading indicator
                  isLoading
                      ? const CircularProgressIndicator()
                      : Center(
                          child: SingleChildScrollView(
                            child: Column(
                              children: userData.isNotEmpty
                                  ? userData.map((user) {
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "User Name: ${user["name"] ?? "N/A"}",
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                  "Phone Number: ${user["mobile"] ?? "N/A"}"),
                                              Text(
                                                  "Status: ${user["status"] ?? "N/A"}"),
                                              Text(
                                                  "Email: ${user['eMail'] ?? "N/A"}"),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.visibility,
                                                        color: Colors.green),
                                                    onPressed: () {
                                                      showUserDetails(user);
                                                    },
                                                  ),
                                                  if (userRoleLevel == 7)
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        final userCode =
                                                            user['userCode']
                                                                ?.toString();
                                                        if (userCode != null &&
                                                            userCode
                                                                .isNotEmpty) {
                                                          deleteUser(userCode);
                                                          fetchRoles();
                                                        }
                                                      },
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList()
                                  : [
                                      const Card(
                                        margin: EdgeInsets.all(16),
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Text("No users found"),
                                        ),
                                      )
                                    ],
                            ),
                          ),
                        )
                ],
              )
                  .box
                  .white
                  .rounded
                  .padding(const EdgeInsets.all(20)) // Adjusted padding
                  .width(
                      context.screenWidth - 30) // Adjust the width dynamically
                  .shadowSm
                  .make(),
            ],
          ),
        ),
      ),
    );
  }
}
