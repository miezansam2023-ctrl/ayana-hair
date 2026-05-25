import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerNotifications();
  }

  void chargerNotifications() async {
    final id = await ApiService.getId();
    final data = await ApiService.getNotifications(id ?? 0);
    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  int get nonLues => notifications.where((n) => n['lu'] == 0).length;

  IconData _getIcon(String? type) {
    switch (type) {
      case 'commande': return Icons.local_shipping_outlined;
      case 'confirmation': return Icons.check_circle_outline;
      case 'promo': return Icons.local_offer_outlined;
      case 'stock': return Icons.inventory_2_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getCouleur(String? type) {
    switch (type) {
      case 'commande': return Colors.orange;
      case 'confirmation': return Colors.green;
      case 'promo': return const Color(0xFFC9A84C);
      case 'stock': return Colors.blue;
      default: return Colors.white54;
    }
  }

  void marquerLu(int index) async {
    final n = notifications[index];
    if (n['lu'] == 0) {
      await ApiService.marquerNotificationLue(n['id']);
      setState(() => notifications[index]['lu'] = 1);
    }
  }

  void marquerToutLu() async {
    final id = await ApiService.getId();
    await ApiService.toutMarquerLu(id ?? 0);
    setState(() {
      for (var n in notifications) n['lu'] = 1;
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Aujourd\'hui à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Hier';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('NOTIFICATIONS',
                style: TextStyle(
                    color: Color(0xFFC9A84C),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            if (nonLues > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A84C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$nonLues',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFC9A84C)),
        actions: [
          if (nonLues > 0)
            TextButton(
              onPressed: marquerToutLu,
              child: const Text('Tout lire',
                  style: TextStyle(color: Color(0xFFC9A84C), fontSize: 12)),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.notifications_none_outlined,
                          size: 80, color: Color(0xFF2A2A2A)),
                      SizedBox(height: 16),
                      Text('Aucune notification',
                          style: TextStyle(color: Colors.white54, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Vos notifications apparaîtront ici',
                          style: TextStyle(color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (nonLues > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A84C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFC9A84C).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active,
                                color: Color(0xFFC9A84C), size: 18),
                            const SizedBox(width: 10),
                            Text('$nonLues notification(s) non lue(s)',
                                style: const TextStyle(
                                    color: Color(0xFFC9A84C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ...List.generate(notifications.length, (index) {
                      final n = notifications[index];
                      final bool lu = n['lu'] == 1;
                      final couleur = _getCouleur(n['type']);
                      return GestureDetector(
                        onTap: () => marquerLu(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: lu ? const Color(0xFF111111) : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: lu ? const Color(0xFF2A2A2A) : couleur.withOpacity(0.4),
                              width: lu ? 1 : 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: couleur.withOpacity(lu ? 0.1 : 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_getIcon(n['type']),
                                      color: couleur.withOpacity(lu ? 0.6 : 1.0),
                                      size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(n['titre'] ?? '',
                                                style: TextStyle(
                                                    color: lu ? Colors.white70 : Colors.white,
                                                    fontWeight: lu ? FontWeight.normal : FontWeight.bold,
                                                    fontSize: 14)),
                                          ),
                                          if (!lu)
                                            Container(
                                              width: 8, height: 8,
                                              decoration: const BoxDecoration(
                                                  color: Color(0xFFC9A84C),
                                                  shape: BoxShape.circle),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(n['message'] ?? '',
                                          style: TextStyle(
                                              color: lu ? Colors.white38 : Colors.white54,
                                              fontSize: 12,
                                              height: 1.4)),
                                      const SizedBox(height: 6),
                                      Text(_formatDate(n['created_at']),
                                          style: const TextStyle(
                                              color: Colors.white24, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}