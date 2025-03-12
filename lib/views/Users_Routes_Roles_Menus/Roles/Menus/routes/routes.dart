import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/route_service.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/views/widgets_common/drawer.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});
  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  final String baseUrl = "https://localhost:5001"; // API Base URL
  final searchController = TextEditingController();
  final RouteService _routeService = RouteService();
  final TextEditingController routeNameController = TextEditingController();
  final TextEditingController pathController = TextEditingController();

  List<dynamic> _routes = []; // Full list of routes
  List<dynamic> _filteredRoutes = []; // Filtered list for search
  List<dynamic> routeItems = []; // List for dropdown

  bool isLoading = true;
  bool isActive = false;
  String? selectedRoute;
  String? selectedParentCode;

  @override
  void initState() {
    super.initState();
    fetchRoutes();
    searchController.addListener(() {
      filterRoutes(searchController.text);
    });
  }

  Future<void> fetchRoutes() async {
    final routes = await _routeService.fetchRoute();
    if (routes != null) {
      setState(() {
        _routes = routes;
        _filteredRoutes = _routes; // Initialize with full list
        routeItems = _routes.map((route) {
          return {
            "routeCode": route["routeCode"].toString(),
            "routeName": route["routeName"] ?? "No Parent",
          };
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterRoutes(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, show all routes
        _filteredRoutes = _routes;
      } else {
        // Filter routes based on the query
        _filteredRoutes = _routes.where((route) {
          final routeName = route["routeName"]?.toLowerCase() ?? "";
          final path = route["path"]?.toLowerCase() ?? "";
          return routeName.contains(query.toLowerCase()) ||
              path.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        appBar: AppBar(
            title: Text(
              'Routes',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: IconThemeData(color: Colors.white)),
        drawer: CustomDrawer(),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: context.screenHeight * 0.02),
                applogoWidget(),
                20.heightBox,
                // Search Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                                    } else {}
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
                    isLoading
                        ? CircularProgressIndicator()
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                // Heading
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Route Details',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (_filteredRoutes.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No routes found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                else
                                  // Cards for each route
                                  ..._filteredRoutes.map((route) {
                                    // Find the parent route by matching the parentCode
                                    final parentRoute = _routes.firstWhere(
                                      (r) =>
                                          r["routeCode"] == route["parentCode"],
                                      orElse: () => null,
                                    );

                                    return Card(
                                      elevation: 5,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Route Name: ${route["routeName"] ?? ""}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                                'Path: ${route["path"] ?? ""}'),
                                            SizedBox(height: 8),
                                            Text(
                                                'Parent Name: ${parentRoute != null ? parentRoute["routeName"] : "N/A"}'),
                                            SizedBox(height: 8),

                                            // Action buttons - aligned at the right
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                // Edit Button
                                                IconButton(
                                                  icon: Icon(Icons.edit,
                                                      color: Colors.blue),
                                                  onPressed: () {
                                                    final routeId =
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
                                                    final currentParentCode =
                                                        route['parentCode']
                                                            ?.toString();

                                                    String? updatedParentCode =
                                                        currentParentCode;

                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return StatefulBuilder(
                                                          builder: (context,
                                                              setState) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'Edit Route'),
                                                              content:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
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
                                                                      maxLines:
                                                                          1,
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            16),
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
                                                                        height:
                                                                            16),
                                                                    // Parent Name Dropdown
                                                                    ConstrainedBox(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              maxWidth: 400), // Adjust the max width as needed
                                                                      child: DropdownButtonFormField<
                                                                          String>(
                                                                        decoration:
                                                                            const InputDecoration(
                                                                          labelText:
                                                                              "Parent Name",
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                        ),
                                                                        value:
                                                                            updatedParentCode, // Current selection
                                                                        items: _routes
                                                                            .map((route) {
                                                                          return DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                route["routeCode"],
                                                                            child:
                                                                                Text(route["routeName"] ?? "No Parent"),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (newValue) {
                                                                          setState(
                                                                              () {
                                                                            updatedParentCode =
                                                                                newValue; // Update selected parentCode
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),

                                                                    SizedBox(
                                                                        height:
                                                                            16),
                                                                    // Status Toggle
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'Status:',
                                                                          style: TextStyle(
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        Switch(
                                                                          value:
                                                                              updatedStatus,
                                                                          onChanged:
                                                                              (value) {
                                                                            setState(() {
                                                                              updatedStatus = value;
                                                                            });
                                                                          },
                                                                          activeColor:
                                                                              Colors.green,
                                                                          inactiveThumbColor:
                                                                              Colors.grey,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Text(
                                                                      updatedStatus
                                                                          ? 'Active'
                                                                          : 'Inactive',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: updatedStatus
                                                                              ? Colors.green
                                                                              : Colors.red),
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
                                                                  child: Text(
                                                                      'Cancel'),
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
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
                                                                    await _routeService
                                                                        .updateRoute(
                                                                      routeId,
                                                                      route['routeCode']
                                                                              ?.toString() ??
                                                                          '',
                                                                      routeNameController
                                                                          .text,
                                                                      pathController
                                                                          .text,
                                                                      updatedStatus,
                                                                      updatedParentCode ??
                                                                          '',
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
                                                // Delete Button
                                                IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () async {
                                                    final routeCode =
                                                        route["routeCode"];
                                                    if (routeCode != null &&
                                                        routeCode.isNotEmpty) {
                                                      await _routeService
                                                          .deleteRotue(
                                                              routeCode);
                                                      fetchRoutes(); // Refresh the list
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          )
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
