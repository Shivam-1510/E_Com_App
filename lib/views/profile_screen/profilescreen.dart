import 'package:e_comapp/consts/consts.dart';
import 'package:e_comapp/services/Order/orderservice.dart';
import 'package:e_comapp/services/getloginuesrrole.dart';
import 'package:e_comapp/utils/snackbar_util.dart';
import 'package:e_comapp/views/widgets_common/bg_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:e_comapp/views/authScreen/loginScreen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final UserRoleService _userRoleService = UserRoleService();
  final OrderService _orderService = OrderService();
  Map<String, dynamic>? loggedInUser;
  String? roleCode;
  List<dynamic> orders = [];
  bool isLoading = true;

  Future<void> fetchLoggedInUserDetails() async {
    final userDetails = await _userRoleService.getUserDetails();
    if (userDetails != null && userDetails.containsKey('user')) {
      setState(() {
        loggedInUser = userDetails['user'];
        roleCode = userDetails['userRoles'][0]['roleCode'].toString();
      });
    }
  }

  void _logout() async {
    await _storage.delete(key: 'authToken');
    String? token = await _storage.read(key: 'authToken');
    if (token == null) {
      Get.to(() => const Loginscreen());
    } else {
      showGlobalSnackBar("Error, Could not log out. Please try again.");
    }
  }

  Future<void> loadOrders() async {
    final fetchedOrders = await _orderService.fetchOrders();
    setState(() {
      orders = fetchedOrders;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchLoggedInUserDetails();
    loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return bgWidget(
      Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              // Profile header section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile image and info
                    Row(
                      children: [
                        // Profile image
                        Image.asset(
                          imgProfile2,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ).box.roundedFull.clip(Clip.antiAlias).make(),
                        const SizedBox(width: 10),
                        // User info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loggedInUser?['name'] ?? "User Name",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            Text(
                              loggedInUser?['eMail'] ?? "User Email",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Logout button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                      onPressed: _logout,
                      child: Text("Logout",
                          style: TextStyle(
                              fontFamily: semibold, color: Colors.white)),
                    ),
                  ],
                ),
              ),

              // Orders Section
              Container(
                margin: const EdgeInsets.all(12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Orders',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : orders.isEmpty
                            ? Center(
                                child: Text("No Orders Found",
                                    style: TextStyle(color: Colors.grey)))
                            : SizedBox(
                                height: 300, // Adjust height as needed
                                child: ListView.builder(
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    final orderCode =
                                        order['order']['orderCode'] ?? 'N/A';
                                    final orderItems =
                                        order['orderItems'] as List<dynamic>;

                                    return Card(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Order Code: $orderCode',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 5),
                                            ...orderItems.map((item) {
                                              final productName =
                                                  item['product']
                                                          ['productName'] ??
                                                      'Unknown Product';
                                              final size = item['size']
                                                      ['sizeName'] ??
                                                  'N/A';
                                              final color = item['color']
                                                      ['colorName'] ??
                                                  'N/A';
                                              final price = item['product']
                                                          ['productPrice']
                                                      ?.toString() ??
                                                  '0';

                                              return ListTile(
                                                title: Text(productName,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                subtitle: Text(
                                                    'Size: $size | Color: $color\n₹ $price'),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// .box
//                   .white
//                   .rounded
//                   .shadowSm
//                   .margin(const EdgeInsets.all(12))
//                   .padding(const EdgeInsets.symmetric(horizontal: 16))
//                   .width(context.screenWidth - 70)
//                   .make(),
