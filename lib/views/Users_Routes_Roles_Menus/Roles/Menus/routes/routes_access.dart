import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/fetch_roles_for_menu.dart';
import 'package:e_comapp/services/route_service.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/applogo.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:e_comapp/services/route_access_service.dart';

class RoutesAccess extends StatefulWidget {
  const RoutesAccess({super.key});

  @override
  State<RoutesAccess> createState() => _RoutesAccessState();
}

class _RoutesAccessState extends State<RoutesAccess> {
  final String baseUrl = "https://localhost:7157";
  final UserService _userService = UserService();
  final RouteService _routeService = RouteService();
  final RouteAccessService _routeAccessService = RouteAccessService();
  final searchController = TextEditingController();
  bool isActive = false;
  bool isLoading = false;
  String? selectedRoleCode;
  Set<String> selectedRoutes = {};
  List<Map<String, dynamic>> userData = [];
  List<Map<String, dynamic>> roles2 = [];
  List<Map<String, dynamic>> routeData = [];
  Map<String, bool> switches = {};

  @override
  void initState() {
    super.initState();
    fetchRoles();
    fetchRouteData();
  }

  Future<void> fetchRouteData() async {
    setState(() => isLoading = true);

    final routes = await _routeService.fetchRouteandSubroute(); // Debugging

    if (routes.isEmpty) {}

    setState(() {
      routeData =
          List<Map<String, dynamic>>.from(routes); // Ensure correct type
      for (var route in routeData) {
        switches[route['routeCode']] = false;
        if (route['subroutes'] != null) {
          for (var sub in route['subroutes']) {
            switches[sub['routeCode']] = false;
          }
        }
      }
      isLoading = false;
    });
  }

  Future<void> fetchRoles() async {
    setState(() {
      isLoading = true; // Show loading spinner
    });
    final roles = await _userService.fetchRoles();
    setState(() {
      userData = roles; // Update the userData list with fetched roles
      isLoading = false; // Hide loading spinner
    });
  }

  bool isRouteChecked(String routeCode, List<dynamic>? subRoutes) {
    return selectedRoutes.contains(routeCode) ||
        (subRoutes != null &&
            subRoutes.any((sub) => selectedRoutes.contains(sub['routeCode'])));
  }

  void toggleRoute(bool value, String routeCode, List<dynamic>? subRoutes) {
    setState(() {
      switches[routeCode] = value;
      if (value) {
        selectedRoutes.add(routeCode);

        // yh function parent krta hai ki agr parent on hai toh saare submenus on hoenge
        if (subRoutes != null) {
          for (var sub in subRoutes) {
            switches[sub['routeCode']] = true;
            selectedRoutes.add(sub['routeCode']);
          }
        }
      } else {
        selectedRoutes.remove(routeCode);
        // yh fucntion agr parent ko deselect krenge toh subroutes bhi deactivate ho jaye ge saare
        if (subRoutes != null) {
          for (var sub in subRoutes) {
            switches[sub['routeCode']] = false;
            selectedRoutes.remove(sub['routeCode']);
          }
        }
      }
      // yh fuction if subroute is active then uska parent bhi active hoeyga
      for (var route in routeData) {
        if (route['subRoutes'] != null &&
            route['subRoutes']
                .any((sub) => selectedRoutes.contains(sub['routeCode']))) {
          switches[route['routeCode']] = true;
          selectedRoutes.add(route['routeCode']);
        }
      }
    });
  }

  Future<void> saveRouteAccess() async {
    if (selectedRoleCode == null) {
      showGlobalSnackBar("Please select a role before saving.");
      return;
    }
    setState(() => isLoading = true);
    try {
      List<Map<String, dynamic>> routeAccessList = [];
      switches.forEach((routeCode, status) {
        routeAccessList.add({
          'roleCode': selectedRoleCode!,
          'routeCode': routeCode,
          'status': status,
        });
      });
      final response =
          await _routeAccessService.createRouteAccess(routeAccessList);

      if (response != null) {
        showGlobalSnackBar('Route Access updated successfully!');
      } else {
        print("Failed to update route access.");
      }
    } catch (e) {
      print("Error updating route access: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchRouteAccessByRole(String roleCode) async {
    setState(() => isLoading = true);

    try {
      final List<Map<String, dynamic>> accessList =
          await _routeAccessService.fetchRouteByRoleCode(roleCode);

      switches.clear();
      selectedRoutes.clear();

      //  Store all fetched route access
      for (var access in accessList) {
        String routeCode = access['routeCode'];
        bool status = access['status'] ?? false;

        switches[routeCode] = status;
        if (status) {
          selectedRoutes.add(routeCode);
        }
      }

      //  Ensure parent-child toggling works correctly
      for (var route in routeData) {
        if (route['subRoutes'] != null) {
          for (var sub in route['subRoutes']) {
            String subCode = sub['routeCode'];
            if (switches.containsKey(subCode) && switches[subCode]!) {
              switches[route['routeCode']] = true;
              selectedRoutes.add(route['routeCode']);
            }
          }
        }
      }

      setState(() {}); //  UI ko refresh karne ke liye
    } catch (e) {
      print("Error fetching route access: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildRouteItem(Map<String, dynamic> route, {bool isSubRoute = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: isSubRoute ? 20.0 : 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  route['routeName'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSubRoute ? FontWeight.normal : FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Switch(
                value: isRouteChecked(route['routeCode'], route['subRoutes']),
                onChanged: (value) =>
                    toggleRoute(value, route['routeCode'], route['subRoutes']),
                activeColor: Colors.green,
                inactiveTrackColor: Colors.grey[300],
                inactiveThumbColor: Colors.grey,
              ),
            ],
          ),
        ),
        if (route['subRoutes'] != null && route['subRoutes'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              children: route['subRoutes']
                  .map<Widget>((sub) => buildRouteItem(sub, isSubRoute: true))
                  .toList(),
            ),
          ),
        Divider(thickness: 1, color: Colors.grey.shade300),
      ],
    );
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
              "Routes Access With Role"
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
                  Row(children: [
                    // Dropdown Button wrapped in Flexible
                    Flexible(
                      child: DropdownButton<String>(
                        hint: const Text("Select Role "), // Default hint
                        value: selectedRoleCode, // Currently selected roleCode
                        items: userData.map((role) {
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
                          });

                          if (selectedRoleCode != null) {
                            setState(() => isLoading = true); //  Loading enable

                            try {
                              List<Map<String, dynamic>> routeAccessList =
                                  await _routeAccessService
                                          .fetchRouteByRoleCode(
                                              selectedRoleCode!) ??
                                      []; //  Null safety fix

                              switches.clear();
                              selectedRoutes.clear();

                              for (var route in routeAccessList) {
                                String routeCode =
                                    route['routeCode'] ?? ''; //  Null safety
                                bool status = route['status'] ?? false;

                                if (routeCode.isNotEmpty) {
                                  //  Avoid adding empty keys
                                  switches[routeCode] = status;
                                  if (status) {
                                    selectedRoutes.add(routeCode);
                                  }
                                }
                              }

                              //  Parent-child logic
                              for (var route in routeData) {
                                if (route['subRoutes'] != null) {
                                  for (var sub in route['subRoutes']) {
                                    String subCode = sub['routeCode'] ?? '';
                                    if (subCode.isNotEmpty &&
                                        switches.containsKey(subCode) &&
                                        switches[subCode]!) {
                                      switches[route['routeCode']] = true;
                                      selectedRoutes.add(route['routeCode']);
                                    }
                                  }
                                }
                              }
                            } catch (e) {
                              print("Error fetching route access: $e");
                            } finally {
                              setState(() => isLoading = false);
                            }
                          }
                        },

                        isExpanded:
                            true, // Ensures the dropdown takes the full width
                      ),
                    ),
                    20.widthBox,
                  ]),
                  SizedBox(height: 20),
                  isLoading
                      ? CircularProgressIndicator()
                      : routeData.isEmpty
                          ? Text("Data exists but UI is not displaying it!",
                              style: TextStyle(color: Colors.white))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: routeData.map<Widget>((item) {
                                return buildRouteItem(item);
                              }).toList(),
                            )
                              .box
                              .white
                              .padding(const EdgeInsets.all(16))
                              .shadowSm
                              .make(),
                  SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : saveRouteAccess,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text("Save", style: TextStyle(color: Colors.white)),
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
        )),
      ),
    );
  }
}
