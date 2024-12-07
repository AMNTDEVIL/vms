import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vms/home/admin/admin_dashboard.dart';
import 'package:vms/home/admin/admin_registration.dart';
import 'package:vms/home/admin/view_trades.dart';
import 'package:vms/home/admin/view_users.dart';
import 'package:vms/home/admin/view_vendors.dart';
import 'package:vms/home/user/view_orders.dart';
import 'package:vms/home/vendor/vieworders.dart';
import 'home/user/about_us.dart';
import 'home/user/purchase_screen.dart';
import 'home/user/userprofile.dart';
import 'home/vendor/vendorhome.dart';
import 'logins/RegisterVendor.dart';
import 'logins/homepage.dart';
import 'logins/ulogout.dart';
import 'logins/vlogout.dart';
import 'php_api_call/register_vendor.dart';
import 'logins/User_registration.dart';
import 'logins/Userlogin.dart';
import 'logins/Vendorlogin.dart';
import 'home/vendor/vendorprofile.dart';
import 'home/vendor/inventory/manageproduct.dart';
import 'home/vendor/inventory/addproduct.dart';
import 'home/vendor/inventory/editproduct.dart';
import 'home/vendor/inventory/viewproduct.dart';
import 'home/vendor/inventory/deleteproduct.dart';
import 'home/vendor/inventory/product.dart';
import 'home/vendor/inventory/inventorymgmt.dart';
import 'home/user/userhome.dart';
import 'home/user/display_vendors.dart';
import 'home/user/services.dart';
import 'home/admin/admin_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendor Management System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
      routes: {
        "user_registration": (context) => const RegisterPage(),
        "user_login": (context) => LoginPage(),
        "vendor_login": (context) => const VendorLogin(),
        "/vendor_dashboard": (context) => VendorDashboard1(),
        "user_dashboard": (context) => UserDashboard(),
        "display_vendors": (context) => DisplayVendorsScreen(),
        "vendor_profile": (context) => const VendorProfileScreen(),
        "vendor_registration": (context) => RegisterVendor(),
        "manage_product": (context) => const ProductManagementScreen(),
        'homepage': (context) => Homepage(),
        'admin_login': (context) => AdminLoginPage(),
        '/admin_dashboard': (context) => AdminDashboardPage(),
        'admin_register': (context) => AdminRegistrationPage(),
        'view_vendors': (context) => ViewVendorsPage(),
        '/view_users': (context) => ViewUsersScreen(),
        '/view_trades': (context) => OrderLogsScreen(),
        "services_screen": (context) =>
            ServicesScreen(), // Add ServicesScreen route here
        'logout': (context) => LogoutScreen(),
        'userlogout': (context) => UserLogOutScreen(),
        '/userprofile': (context) => UserProfileScreen(),
        'about_us': (context) => AboutUsPage(),
        '/purchase': (context) => PurchaseScreen(
              productId: 'default_product_id',
              productPrice: 100,
              name: 'Default User',
              vendorName: 'Default Vendor',
            ),
        'inventorymgmt': (context) => ViewProductScreen(),
        'add_product': (context) => AddProductScreen(),
        'edit_product': (context) {
          final product =
              ModalRoute.of(context)?.settings.arguments as Product?;
          return EditProductScreen(product: product);
        },
        'view_orders': (context) => VendorOrdersScreen(),
        'view_product': (context) => ProductListScreen(),
        'delete_product': (context) => const DeleteProductScreen(),
        '/userOrders': (context) =>
            UserOrdersScreen(), // Define route for /userOrders
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _checkIfUserOrVendorLoggedIn(context);
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  // Function to check if either user or vendor is logged in
  void _checkIfUserOrVendorLoggedIn(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check for user login status
    String? userEmail = prefs.getString('user_email');
    String? vendorEmail = prefs.getString('vendor_email');

    if (userEmail != null) {
      // If user is logged in, navigate to user dashboard
      Navigator.pushReplacementNamed(context, 'user_dashboard');
    } else if (vendorEmail != null) {
      // If vendor is logged in, navigate to vendor dashboard
      Navigator.pushReplacementNamed(context, '/vendor_dashboard');
    } else {
      // If neither user nor vendor is logged in, navigate to homepage
      Navigator.pushReplacementNamed(context, 'homepage');
    }
  }
}
