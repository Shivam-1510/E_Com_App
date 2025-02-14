import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/route_service.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final String baseUrl = "https://localhost:7157"; // API Base URL
  final searchController = TextEditingController();
  final RouteService _routeService = RouteService();
  final TextEditingController routeNameController = TextEditingController();
  final TextEditingController pathController = TextEditingController();
  List<dynamic> _routes = []; // list to hold the routes data
  List<dynamic> routeItems = []; // list to store the routeItems
  bool isLoading = true;
  bool isActive = false;
  String? selectedRoute;
  String? selectedParentCode = null;

  @override
  void initState() {
    super.initState();
    fetchRoutes();
  }

  Future<void> fetchRoutes() async {
    final routes = await _routeService.fetchRoute();
    if (routes != null) {
      setState(() {
        _routes = routes;
        routeItems = _routes.map((route) {
          return {
            "routeCode":
                route["routeCode"].toString(), // Always convert to String
            "routeName": route["routeName"] ?? "No Parent",
          };
        }).toList(); // Set the parent names for the dropdown
        isLoading = false; // Set loading to false after data is fetched
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to fetch routes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: context.screenHeight * 0.02),
                applogoWidget(),
                10.heightBox,
                "Routes"
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
                          "Create New",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () async {
                          // Reset the form fields before opening the dialog
                          routeNameController.clear();
                          pathController.clear();
                          setState(() {
                            selectedRoute = null;
                            isActive = false;
                          });
                          showDialog(
                            context: context,
                            builder: (context) {
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
                                              "Create Routes",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'bold'),
                                            ),
                                            const SizedBox(height: 20),

                                            // Route Name Field
                                            TextField(
                                              controller: routeNameController,
                                              decoration: const InputDecoration(
                                                labelText: "Route Name",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            // Path Field
                                            TextField(
                                              controller: pathController,
                                              decoration: const InputDecoration(
                                                labelText: "Path",
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            const SizedBox(height: 20),

                                            // Parent Name Dropdown (To be implemented)
                                            DropdownButtonFormField<String>(
                                              decoration: const InputDecoration(
                                                labelText: 'Parent Name',
                                                border: OutlineInputBorder(),
                                              ),
                                              value: selectedParentCode,
                                              items: routeItems.map((route) {
                                                return DropdownMenuItem<String>(
                                                  value: route[
                                                      "routeCode"], // Use routeCode as the value
                                                  child: Text(route[
                                                          "routeName"] ??
                                                      "No Parent"), // Display routeName
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  selectedParentCode =
                                                      newValue; // Update selected parentCode
                                                });
                                              },
                                            ),

                                            SizedBox(height: 20),
                                            Text('Status: ',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Switch(
                                              value: isActive,
                                              onChanged: (value) {
                                                setState(() {
                                                  isActive = value;
                                                });
                                              },
                                              activeColor: Colors.green,
                                              inactiveThumbColor: Colors.grey,
                                            ),
                                            Text(
                                              isActive ? 'Active' : 'Inactive',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isActive
                                                      ? Colors.green
                                                      : Colors.red),
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
                                                  onPressed: () async {
                                                    final routeName =
                                                        routeNameController
                                                            .text;
                                                    final path =
                                                        pathController.text;
                                                    final isActiveStatus =
                                                        isActive;
                                                    final String? parentCode =
                                                        (selectedParentCode ==
                                                                    null ||
                                                                selectedParentCode ==
                                                                    "null" ||
                                                                selectedParentCode!
                                                                    .trim()
                                                                    .isEmpty)
                                                            ? null
                                                            : selectedParentCode;
                                                    final result =
                                                        await _routeService
                                                            .createRoute(
                                                      routeName,
                                                      path,
                                                      isActiveStatus,
                                                      parentCode,
                                                    );
                                                    if (result != null) {
                                                      fetchRoutes();
                                                    } else {
                                                      print(
                                                          'Failed to cerate route.');
                                                    }
                                                    // Close the dialog after the user is added
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
                    ),
                    20.heightBox,

                    // Table
                    isLoading
                        ? CircularProgressIndicator()
                        : Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 30,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "Route Name",
                                      style: TextStyle(
                                          fontFamily: bold, fontSize: 16),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Path",
                                      style: TextStyle(
                                          fontFamily: bold, fontSize: 16),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Parent Name",
                                      style: TextStyle(
                                          fontFamily: bold, fontSize: 16),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Actions",
                                      style: TextStyle(
                                          fontFamily: bold, fontSize: 16),
                                    ),
                                  ),
                                ],
                                rows: _routes.map((route) {
                                  // Find the parent route by matching the parentCode
                                  final parentRoute = _routes.firstWhere(
                                    (r) =>
                                        r["routeCode"] == route["parentCode"],
                                    orElse: () => null,
                                  );

                                  return DataRow(cells: [
                                    DataCell(Text(route["routeName"] ??
                                        "")), // Route Name
                                    DataCell(Text(route["path"] ?? "")), // Path
                                    DataCell(Text(parentRoute != null
                                        ? parentRoute["routeName"]
                                        : "")),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () {
                                            // Get current values
                                            final currentRouteId =
                                                route['id'] ?? 0;
                                            final TextEditingController
                                                routeNameController =
                                                TextEditingController(
                                                    text: route['routeName']
                                                            ?.toString() ??
                                                        '');
                                            final TextEditingController
                                                pathController =
                                                TextEditingController(
                                                    text: route['path']
                                                            ?.toString() ??
                                                        '');
                                            bool updatedStatus =
                                                route['status'] == true;

                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return AlertDialog(
                                                      title: Text('Edit Route'),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            // Route Name input
                                                            TextField(
                                                              controller:
                                                                  routeNameController,
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Route Name',
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 16),
                                                            // Path Input
                                                            TextField(
                                                              controller:
                                                                  pathController,
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Path',
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 16),
                                                            // Status Toggle
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  'Status:',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Switch(
                                                                  value:
                                                                      updatedStatus,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      updatedStatus =
                                                                          value;
                                                                    });
                                                                  },
                                                                  activeColor:
                                                                      Colors
                                                                          .green,
                                                                  inactiveThumbColor:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              updatedStatus
                                                                  ? 'Active'
                                                                  : 'Inactive',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: updatedStatus
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red),
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
                                                                Colors.red,
                                                          ),
                                                          onPressed: () async {
                                                            // Validate inputs
                                                            if (routeNameController
                                                                    .text
                                                                    .isEmpty ||
                                                                pathController
                                                                    .text
                                                                    .isEmpty) {
                                                              showGlobalSnackBar(
                                                                  'Please fill all fields.');
                                                              return;
                                                            }
                                                            // Call updateRoute function
                                                            await _routeService
                                                                .updateRoute(
                                                              currentRouteId,
                                                              route['routeCode']
                                                                      ?.toString() ??
                                                                  '',
                                                              routeNameController
                                                                  .text,
                                                              pathController
                                                                  .text,
                                                              updatedStatus,
                                                            );

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            fetchRoutes();
                                                          },
                                                          child: Text(
                                                            'Update',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            final routeCode =
                                                route["routeCode"];
                                            if (routeCode != null &&
                                                routeCode.isNotEmpty) {
                                              await _routeService
                                                  .deleteRotue(routeCode);
                                              fetchRoutes(); // Refresh the list
                                            } else {
                                              print(
                                                  'Route code is null or empty');
                                            }
                                          },
                                        ),
                                      ],
                                    )),
                                    // Parent Name
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                  ],
                )
                    .box
                    .white
                    .rounded
                    .padding(const EdgeInsets.all(16))
                    .width(context.screenWidth - 30)
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
