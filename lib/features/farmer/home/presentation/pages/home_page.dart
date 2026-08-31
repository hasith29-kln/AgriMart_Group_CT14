import 'package:agri_mart/features/farmer/product/presentation/pages/my_products_page.dart';
import 'package:agri_mart/features/officer/home/presentation/pages/officer_dashboard_content.dart';
import 'package:flutter/material.dart';
import 'package:agri_mart/core/widgets/bottom_nav/custom_bottom_nav_bar.dart';
import 'package:agri_mart/features/farmer/orders/presentation/pages/orders_page.dart';
import 'package:agri_mart/features/farmer/profile/presentation/pages/profile_page.dart';
import 'package:agri_mart/features/buyer/home/presentation/pages/buyer_home_content.dart';
import 'package:agri_mart/features/buyer/profile/presentation/pages/buyer_profile_page.dart';
import 'package:agri_mart/features/buyer/browse/presentation/pages/buyer_browse_page.dart';
import 'package:agri_mart/features/buyer/orders/presentation/pages/buyer_orders_page.dart';
import 'package:agri_mart/features/officer/farmers/presentation/pages/officer_farmers_page.dart';
import 'package:agri_mart/features/officer/products/presentation/pages/officer_products_page.dart';
import 'package:agri_mart/features/officer/buyers/presentation/pages/officer_buyers_page.dart';
import 'package:agri_mart/features/officer/profile/presentation/pages/officer_profile_page.dart';
import 'package:agri_mart/features/farmer/home/presentation/pages/farmer_home_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:agri_mart/features/comman/notifications/presentation/pages/app_notifications_page.dart';
import 'package:agri_mart/core/providers/notification_provider.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerStatefulWidget {
  final String userRole;
  const HomePage({super.key, this.userRole = 'farmer'});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);
    PreferredSizeWidget? appBar;
    if (selectedIndex == 0) {
      if (widget.userRole == 'buyer') {
        appBar = _buildBuyerAppBar();
      } else if (widget.userRole == 'officer') {
        appBar = _buildOfficerAppBar();
      } else {
        appBar = _buildAppBar();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: appBar,
      body: _buildBody(selectedIndex),
      bottomNavigationBar: CustomBottomNavBar(
        userRole: widget.userRole,
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
      ),
    );
  }

  Widget _buildBody(int selectedIndex) {
    if (widget.userRole == 'buyer') {
      switch (selectedIndex) {
        case 0:
          return const BuyerHomeContent();
        case 1:
          return const BuyerBrowsePage();
        case 2:
          return const AppNotificationsPage(showBackButton: false);
        case 3:
          return const BuyerOrdersPage();
        case 4:
          return const BuyerProfilePage();
        default:
          return const BuyerHomeContent();
      }
    } else if (widget.userRole == 'officer') {
      switch (selectedIndex) {
        case 0:
          return const OfficerDashboardContent();
        case 1:
          return const OfficerFarmersPage();
        case 2:
          return const OfficerProductsPage();
        case 3:
          return const OfficerBuyersPage();
        case 4:
          return const OfficerProfilePage();
        default:
          return const OfficerDashboardContent();
      }
    } else {
      switch (selectedIndex) {
        case 0:
          return const FarmerHomeContent();
        case 1:
          return const MyProductsPage();
        case 3:
          return const OrdersPage();
        case 4:
          return const ProfilePage();
        default:
          return const FarmerHomeContent();
      }
    }
  }

  // Removed _buildHomeContent as it's now in farmer_home_content.dart

  PreferredSizeWidget _buildAppBar() {
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF387015),
      elevation: 0,
      title: Row(
        children: [
          const Text('🌾', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          const Text(
            'AgriMart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            ref.read(notificationReadStateProvider.notifier).state = true;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppNotificationsPage()),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Text('🔔', style: TextStyle(fontSize: 20)),
              ),
              if (hasUnread)
                Positioned(
                  right: 14,
                  top: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            ref.read(selectedTabProvider.notifier).state = 4;
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text('👤', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildOfficerAppBar() {
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF8D5A36), // Brown background
      elevation: 0,
      title: Row(
        children: [
          const Text('⚙️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          const Text(
            'Officer Panel',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            ref.read(notificationReadStateProvider.notifier).state = true;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppNotificationsPage()),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Text('🔔', style: TextStyle(fontSize: 18)),
              ),
              if (hasUnread)
                Positioned(
                  right: 14,
                  top: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            ref.read(selectedTabProvider.notifier).state = 4;
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text('👤', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildBuyerAppBar() {
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          const Text('🛒', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          const Text(
            'AgriMart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            ref.read(notificationReadStateProvider.notifier).state = true;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppNotificationsPage()),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2), // Light yellowish
                  shape: BoxShape.circle,
                ),
                child: const Text('🔔', style: TextStyle(fontSize: 18)),
              ),
              if (hasUnread)
                Positioned(
                  right: 14,
                  top: 8,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            ref.read(selectedTabProvider.notifier).state = 4;
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1), // Light blueish
              shape: BoxShape.circle,
            ),
            child: const Text('👤', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}
