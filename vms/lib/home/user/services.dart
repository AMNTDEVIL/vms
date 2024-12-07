import 'package:flutter/material.dart';

class VMSService {
  final String serviceName;
  final String serviceDescription;
  final IconData serviceIcon;
  final void Function(BuildContext) onTapAction;

  VMSService({
    required this.serviceName,
    required this.serviceDescription,
    required this.serviceIcon,
    required this.onTapAction,
  });
}

class ServicesScreen extends StatelessWidget {
  final List<VMSService> services = [
    VMSService(
      serviceName: 'View Orders',
      serviceDescription:
          'Browse through different vendors offering various services.',
      serviceIcon: Icons.search,
      onTapAction: (context) {
        print('Navigating to /userOrders'); // Debug print
        Navigator.pushNamed(context, '/userOrders');
      },
    ),
    VMSService(
      serviceName: 'User Profile',
      serviceDescription: 'View and manage your user profile and details.',
      serviceIcon: Icons.account_circle,
      onTapAction: (context) {
        print('Navigating to /userprofile'); // Debug print
        Navigator.pushNamed(context, '/userprofile');
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VMS Services'),
      ),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ListTile(
            leading: Icon(service.serviceIcon),
            title: Text(service.serviceName),
            subtitle: Text(service.serviceDescription),
            onTap: () {
              service.onTapAction(context); // Trigger action
            },
          );
        },
      ),
    );
  }
}
