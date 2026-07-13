import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
class VillageNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const VillageNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      title: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF2D5A27)),
          const SizedBox(width: 8),
          Text(
            "Somarayanampeta",
            style: GoogleFonts.outfit(
              color: const Color(0xFF2D5A27),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          if (isDesktop) ...[
            const Spacer(),
            Expanded(
              flex: 10,
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _navButton("Home", 0, context),
                      _navButton("About", 1, context),
                      _navButton("Events", 2, context),
                      _navButton("Jobs", 3, context),
                      _navButton("Services", 4, context),
                      _navButton("Gallery", 5, context),
                      _navButton("Farming", 6, context),
                      _navButton("Quiz", 7, context),
                      _navButton("Marketplace", 8, context),
                      _navButton("Forum", 9, context),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.language, color: Color(0xFF2D5A27)),
              tooltip: "Toggle Language (English/Telugu)",
              onPressed: () {
                context.read<LanguageProvider>().toggleLanguage();
              },
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/admin/login'),
              icon: const Icon(Icons.admin_panel_settings, color: Color(0xFF2D5A27)),
              tooltip: "Admin Portal",
            ),
          ],
        ],
      ),
      actions: isDesktop ? [const SizedBox(width: 16)] : null,
    );
  }

  Widget _navButton(String label, int index, BuildContext context) {
    bool isSelected = selectedIndex == index;
    final tLabel = context.watch<LanguageProvider>().translate(label);
    return TextButton(
      onPressed: () => onDestinationSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          tLabel,
          style: GoogleFonts.inter(
            color: isSelected ? const Color(0xFF2D5A27) : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class VillageDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const VillageDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2D5A27)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text(
                  "Somarayanampeta",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home, "Home", 0, context),
          _drawerItem(Icons.info, "About", 1, context),
          _drawerItem(Icons.event, "Events", 2, context),
          _drawerItem(Icons.work, "Jobs", 3, context),
          _drawerItem(Icons.home_repair_service, "Services", 4, context),
          _drawerItem(Icons.photo_library, "Gallery", 5, context),
          _drawerItem(Icons.agriculture_outlined, "Farming", 6, context),
          _drawerItem(Icons.quiz_outlined, "Quiz", 7, context),
          _drawerItem(Icons.storefront, "Marketplace", 8, context),
          _drawerItem(Icons.forum, "Forum", 9, context),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF2D5A27)),
            title: Text(context.watch<LanguageProvider>().translate("Language (English/Telugu)"), style: GoogleFonts.inter()),
            onTap: () {
              context.read<LanguageProvider>().toggleLanguage();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF2D5A27)),
            title: Text("Admin Portal", style: GoogleFonts.inter()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index, BuildContext context) {
    bool isSelected = selectedIndex == index;
    final tLabel = context.watch<LanguageProvider>().translate(label);
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF2D5A27) : null),
      title: Text(tLabel, style: GoogleFonts.inter(fontWeight: isSelected ? FontWeight.bold : null)),
      selected: isSelected,
      onTap: () {
        onDestinationSelected(index);
      },
    );
  }
}
