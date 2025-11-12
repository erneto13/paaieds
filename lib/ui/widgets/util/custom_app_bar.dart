import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onProfileTap;
  final bool isIcon;
  final IconData? customIcon;
  final VoidCallback? onCustomIconTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onProfileTap,
    this.isIcon = false,
    this.customIcon,
    this.onCustomIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: onProfileTap ?? onCustomIconTap,
                  child: isIcon
                      ? CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blueAccent.shade100,
                          child: Icon(
                            Icons.person,
                            color: Colors.blueAccent.shade700,
                            size: 20,
                          ),
                        )
                      : Icon(
                          customIcon ?? Icons.settings_outlined,
                          size: 26,
                          color: Colors.grey[700],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
