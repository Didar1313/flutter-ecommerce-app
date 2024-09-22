import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/const/appColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('No user is currently logged in.')),
      );
    }

    final userDocRef =
    FirebaseFirestore.instance.collection('users').doc(currentUser.email);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Center(
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 24.h,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: userDocRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User data not found.'));
          }

          final userData = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180.h,
                      color: Colors.green[700],
                    ),
                    Positioned(
                      top: 100.h,
                      child: CircleAvatar(
                        radius: 70.r,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          userData.data()!.containsKey('profileImage')
                              ? userData['profileImage']
                              : 'https://via.placeholder.com/150', // Default image
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 80.h),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        userData['name'] ?? 'Name not available',
                        style: TextStyle(
                          fontSize: 26.h,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        userData['email'] ?? 'Email not available',
                        style: TextStyle(
                          fontSize: 18.h,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfileDetailRow(
                                  icon: Icons.person_outline,
                                  label: 'Name',
                                  value: userData['name'] ?? 'N/A'),
                              SizedBox(height: 10.h),
                              ProfileDetailRow(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: userData['email'] ?? 'N/A'),
                              SizedBox(height: 10.h),
                              ProfileDetailRow(
                                  icon: Icons.phone,
                                  label: 'Phone',
                                  value: userData['phone'] ?? 'N/A'),
                              SizedBox(height: 10.h),
                              ProfileDetailRow(
                                  icon: Icons.date_range,
                                  label: 'Age',
                                  value: userData['age'] ?? 'N/A'),
                              SizedBox(height: 10.h),
                              ProfileDetailRow(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Created At',
                                  value: userData['createdAt']?.toDate() !=
                                      null
                                      ? userData['createdAt']
                                      .toDate()
                                      .toString()
                                      : 'N/A'),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: EdgeInsets.symmetric(
                              horizontal: 50.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 18.h,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileDetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deep_green),
        SizedBox(width: 10.w),
        Text(
          '$label: ',
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16.h, color: Colors.black),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16.h, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
