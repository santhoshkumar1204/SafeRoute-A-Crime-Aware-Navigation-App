import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    return SingleChildScrollView(
      child: Column(
        children: [
          // SOS Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.danger.withOpacity(0.2), width: 2),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger.withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.phone, size: 40, color: Colors.white),
                        SizedBox(height: 4),
                        Text('SOS',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tap to alert emergency services instantly',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions
          isDesktop
              ? Row(
                  children: [
                    Expanded(child: _actionCard(
                      icon: Icons.share,
                      iconBg: AppColors.primary.withOpacity(0.1),
                      iconColor: AppColors.primary,
                      title: 'Share Live Location',
                      subtitle: 'Send your real-time location to contacts',
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _actionCard(
                      icon: Icons.shield,
                      iconBg: AppColors.safe.withOpacity(0.1),
                      iconColor: AppColors.safe,
                      title: 'Safe Zone Nearby',
                      subtitle: 'Navigate to nearest safe zone',
                    )),
                  ],
                )
              : Column(
                  children: [
                    _actionCard(
                      icon: Icons.share,
                      iconBg: AppColors.primary.withOpacity(0.1),
                      iconColor: AppColors.primary,
                      title: 'Share Live Location',
                      subtitle: 'Send your real-time location to contacts',
                    ),
                    const SizedBox(height: 12),
                    _actionCard(
                      icon: Icons.shield,
                      iconBg: AppColors.safe.withOpacity(0.1),
                      iconColor: AppColors.safe,
                      title: 'Safe Zone Nearby',
                      subtitle: 'Navigate to nearest safe zone',
                    ),
                  ],
                ),
          const SizedBox(height: 16),

          // Police + Hospitals
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPoliceStations()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildHospitals()),
                  ],
                )
              : Column(
                  children: [
                    _buildPoliceStations(),
                    const SizedBox(height: 16),
                    _buildHospitals(),
                  ],
                ),
          const SizedBox(height: 16),

          // Emergency Contacts
          _buildEmergencyContacts(isDesktop),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliceStations() {
    final stations = [
      {'name': 'Central Police Station', 'dist': '0.8 km', 'phone': '911'},
      {'name': 'Downtown Precinct', 'dist': '1.2 km', 'phone': '911'},
      {'name': 'North District HQ', 'dist': '2.1 km', 'phone': '911'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nearby Police Stations',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),
          ...stations.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.navigation,
                          size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['name']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          Text('${s['dist']} away',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                      child: const Text('Call'),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildHospitals() {
    final hospitals = [
      {
        'name': 'City General Hospital',
        'dist': '0.5 km',
        'phone': '555-0100'
      },
      {
        'name': "St. Mary's Medical",
        'dist': '1.4 km',
        'phone': '555-0200'
      },
      {
        'name': 'Emergency Care Clinic',
        'dist': '1.8 km',
        'phone': '555-0300'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nearby Hospitals',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),
          ...hospitals.map((h) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.location_on,
                          size: 16, color: AppColors.danger),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h['name']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          Text('${h['dist']} away',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                      child: const Text('Call'),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts(bool isDesktop) {
    final contacts = [
      {'name': 'Emergency Services', 'number': '911'},
      {'name': 'Mom', 'number': '+1 555-1234'},
      {'name': 'Dad', 'number': '+1 555-5678'},
      {'name': 'Best Friend', 'number': '+1 555-9012'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Emergency Contacts',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 2 : 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4,
            children: contacts.map((c) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c['name']!,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        Text(c['number']!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedForeground)),
                      ],
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.safe.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.phone,
                          size: 16, color: AppColors.safe),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
