import 'package:e_comapp/consts/consts.dart';
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
  bool isLoading = true;
  bool isActive = false;
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
                        "Create New ",
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

                                          // User Name Field
                                          TextField(
                                            decoration: const InputDecoration(
                                              labelText: "Route Name",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          // PASSWORD
                                          TextField(
                                            decoration: const InputDecoration(
                                              labelText: "Path",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          // TODO isko change krna hia dropdown mein
                                          TextField(
                                            decoration: const InputDecoration(
                                              labelText: "Parent Name",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          Text('Status: ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
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

                                          // Status Checkbox
                                          // Row(
                                          //   children: [
                                          //     Checkbox(
                                          //       value: isActive,
                                          //       onChanged: (value) => setState(
                                          //           () => isActive =
                                          //               value ?? false),
                                          //     ),
                                          //     const Text("Is Active"),
                                          //   ],
                                          // ),
                                          const SizedBox(height: 20),

                                          // Buttons
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                  // Close the dialog after the user is added
                                                  Navigator.pop(context);
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

                  // Table
                  // isLoading
                  //     ? CircularProgressIndicator()
                  //     :
                  SingleChildScrollView(
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
                            "Route Name",
                            style: TextStyle(fontFamily: bold, fontSize: 16),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Path",
                            style: TextStyle(fontFamily: bold, fontSize: 16),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Actions",
                            style: TextStyle(fontFamily: bold, fontSize: 16),
                          ),
                        ),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text("Dashboard")),
                          DataCell(Text("/dashboard")),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  print("Edit Dashboard");
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  print("Delete Dashboard");
                                },
                              ),
                            ],
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text("Users")),
                          DataCell(Text("/users")),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  print("Edit Users");
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  print("Delete Users");
                                },
                              ),
                            ],
                          )),
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
