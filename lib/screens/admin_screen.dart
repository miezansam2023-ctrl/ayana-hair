import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Données
  Map<String, dynamic> stats = {};
  List<dynamic> commandes = [];
  List<dynamic> stocks = [];

  bool isLoadingStats = true;
  bool isLoadingCommandes = true;
  bool isLoadingStocks = true;

  static const Color violet = Color(0xFF6B2D5E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    chargerStats();
    chargerCommandes();
    chargerStocks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> chargerStats() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/admin/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      setState(() {
        stats = jsonDecode(response.body);
        isLoadingStats = false;
      });
    } catch (e) {
      setState(() => isLoadingStats = false);
    }
  }

  Future<void> chargerCommandes() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/admin/commandes'),
        headers: {'Authorization': 'Bearer $token'},
      );
      setState(() {
        commandes = jsonDecode(response.body);
        isLoadingCommandes = false;
      });
    } catch (e) {
      setState(() => isLoadingCommandes = false);
    }
  }

  Future<void> chargerStocks() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/admin/stocks'),
        headers: {'Authorization': 'Bearer $token'},
      );
      setState(() {
        stocks = jsonDecode(response.body);
        isLoadingStocks = false;
      });
    } catch (e) {
      setState(() => isLoadingStocks = false);
    }
  }

  Future<void> changerStatut(int commandeId, String statut) async {
    try {
      final token = await ApiService.getToken();
      await http.put(
        Uri.parse(
          'http://10.0.2.2:3000/api/admin/commandes/$commandeId/statut',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'statut': statut}),
      );
      await chargerCommandes();
      await chargerStats();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Statut mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> modifierStock(int produitId, int nouveauStock) async {
    try {
      final token = await ApiService.getToken();
      await http.put(
        Uri.parse('http://10.0.2.2:3000/api/admin/stocks/$produitId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'stock': nouveauStock}),
      );
      await chargerStocks();
      await chargerStats();
    } catch (e) {
      print('Erreur stock: $e');
    }
  }

  Color getStatutColor(String statut) {
    switch (statut) {
      case 'confirmee':
        return Colors.blue;
      case 'en_livraison':
        return Colors.orange;
      case 'livree':
        return Colors.green;
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatutLabel(String statut) {
    switch (statut) {
      case 'confirmee':
        return 'Confirmée';
      case 'en_livraison':
        return 'En livraison';
      case 'livree':
        return 'Livrée';
      case 'annulee':
        return 'Annulée';
      default:
        return 'En attente';
    }
  }

  void _showStatutDialog(Map<String, dynamic> commande) {
    final statuts = [
      {
        'id': 'en_attente',
        'label': 'En attente',
        'icon': Icons.pending_outlined,
        'color': Colors.grey,
      },
      {
        'id': 'confirmee',
        'label': 'Confirmée',
        'icon': Icons.check_circle_outline,
        'color': Colors.blue,
      },
      {
        'id': 'en_livraison',
        'label': 'En livraison',
        'icon': Icons.local_shipping_outlined,
        'color': Colors.orange,
      },
      {
        'id': 'livree',
        'label': 'Livrée',
        'icon': Icons.home_outlined,
        'color': Colors.green,
      },
      {
        'id': 'annulee',
        'label': 'Annulée',
        'icon': Icons.cancel_outlined,
        'color': Colors.red,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commande #${commande['id']} — Changer statut',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              ...statuts.map((s) {
                final bool current = commande['statut'] == s['id'];

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    changerStatut(commande['id'], s['id'] as String);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: current
                          ? (s['color'] as Color).withOpacity(0.2)
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: current
                            ? s['color'] as Color
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          s['icon'] as IconData,
                          color: s['color'] as Color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            s['label'] as String,
                            style: TextStyle(
                              color: current
                                  ? s['color'] as Color
                                  : Colors.white70,
                              fontWeight: current
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),

                        if (current)
                          Icon(
                            Icons.check,
                            color: s['color'] as Color,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: violet,
        title: const Text(
          'DASHBOARD ADMIN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              chargerStats();
              chargerCommandes();
              chargerStocks();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _confirmDeconnexion(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Commandes'),
            Tab(icon: Icon(Icons.inventory), text: 'Stocks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStats(), _buildCommandes(), _buildStocks()],
      ),
    );
  }

  // ==================== STATS ====================
  Widget _buildStats() {
    if (isLoadingStats) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6B2D5E)),
      );
    }

    final ca =
        double.tryParse(stats['chiffre_affaires']?.toString() ?? '0') ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Chiffre d'affaires
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B2D5E), Color(0xFF9C4185)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHIFFRE D\'AFFAIRES',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${ca.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Cartes stats
          Row(
            children: [
              _StatCard(
                titre: 'Commandes',
                valeur: '${stats['total_commandes'] ?? 0}',
                icon: Icons.shopping_bag_outlined,
                couleur: violet,
              ),
              const SizedBox(width: 12),
              _StatCard(
                titre: 'En attente',
                valeur: '${stats['en_attente'] ?? 0}',
                icon: Icons.pending_outlined,
                couleur: Colors.orange,
              ),
              const SizedBox(width: 12),
              _StatCard(
                titre: 'Clients',
                valeur: '${stats['total_clients'] ?? 0}',
                icon: Icons.people_outline,
                couleur: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Commandes récentes
          const Text(
            'COMMANDES RÉCENTES',
            style: TextStyle(
              color: Color(0xFF6B2D5E),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...commandes.take(3).map((c) => _buildCommandeCard(c, compact: true)),
        ],
      ),
    );
  }

  // ==================== COMMANDES ====================
  Widget _buildCommandes() {
    if (isLoadingCommandes) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6B2D5E)),
      );
    }
    if (commandes.isEmpty) {
      return const Center(
        child: Text('Aucune commande', style: TextStyle(color: Colors.white54)),
      );
    }
    return RefreshIndicator(
      onRefresh: chargerCommandes,
      color: violet,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: commandes.length,
        itemBuilder: (_, index) => _buildCommandeCard(commandes[index]),
      ),
    );
  }

  String _getLabelPaiement(String mode) {
    switch (mode) {
      case 'orange_money':
        return 'Orange Money';
      case 'mtn_money':
        return 'MTN Mobile Money';
      case 'wave':
        return 'Wave';
      case 'moov_money':
        return 'Moov Money';
      case 'livraison':
        return 'Paiement à la livraison';
      default:
        return mode;
    }
  }

  Color _getCouleurPaiement(String mode) {
    switch (mode) {
      case 'orange_money':
        return const Color(0xFFFF6600);
      case 'mtn_money':
        return const Color(0xFFFFCC00);
      case 'wave':
        return const Color(0xFF1BA6E0);
      case 'moov_money':
        return const Color(0xFF0066CC);
      case 'livraison':
        return const Color(0xFFC9A84C);
      default:
        return Colors.white54;
    }
  }

  Widget _buildCommandeCard(Map<String, dynamic> c, {bool compact = false}) {
    final statut = c['statut'] ?? 'en_attente';
    final date = DateTime.tryParse(c['created_at'] ?? '') ?? DateTime.now();
    final total = double.tryParse(c['total']?.toString() ?? '0') ?? 0;

    return GestureDetector(
      onTap: compact ? null : () => _showStatutDialog(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commande #${c['id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c['client_nom'] ?? 'Client',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    if (c['type_cheveux'] != null)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: violet.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: violet.withOpacity(0.4)),
                        ),
                        child: Text(
                          '✂️ ${c['type_cheveux']}',
                          style: const TextStyle(
                            color: Color(0xFF6B2D5E),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (c['mode_paiement'] != null &&
                        c['mode_paiement'] != '') ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          c['mode_paiement'] == 'livraison'
                              ? Icon(
                                  Icons.delivery_dining,
                                  color: const Color(0xFFC9A84C),
                                  size: 16,
                                )
                              : Image.asset(
                                  _getImagePaiement(c['mode_paiement']),
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.payment,
                                    color: _getCouleurPaiement(
                                      c['mode_paiement'],
                                    ),
                                    size: 16,
                                  ),
                                ),
                          const SizedBox(width: 6),
                          Text(
                            _getLabelPaiement(c['mode_paiement']),
                            style: TextStyle(
                              color: _getCouleurPaiement(c['mode_paiement']),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    Text(
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getStatutColor(statut).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: getStatutColor(statut)),
                      ),
                      child: Text(
                        getStatutLabel(statut),
                        style: TextStyle(
                          color: getStatutColor(statut),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${total.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: Color(0xFF6B2D5E),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: violet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: violet.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: Color(0xFF6B2D5E), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Changer le statut',
                      style: TextStyle(
                        color: Color(0xFF6B2D5E),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== STOCKS ====================
  Widget _buildStocks() {
    if (isLoadingStocks) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6B2D5E)),
      );
    }

    final enRupture = stocks.where((p) {
      final stock = int.tryParse(p['stock']?.toString() ?? '0') ?? 0;
      return stock <= 10;
    }).length;

    return RefreshIndicator(
      onRefresh: chargerStocks,
      color: violet,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (enRupture > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$enRupture produit(s) en rupture de stock !',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ...stocks.map((p) => _buildStockCard(p)),
        ],
      ),
    );
  }

  String _getImageStock(String nom) {
    const images = {
      'Huile de Coco': 'assets/images/huilecoco.png',
      'Shampoing Karité': 'assets/images/shampkarite.png',
      'Masque Capillaire': 'assets/images/masqcapi.png',
      'Sérum Croissance': 'assets/images/serumcroiss.png',
      'Après-shampoing': 'assets/images/apshamp.png',
      'Huile de Ricin': 'assets/images/huiri.png',
    };
    return images[nom] ?? 'assets/images/huilecoco.png';
  }

  Widget _buildStockCard(Map<String, dynamic> p) {
    final stock = int.tryParse(p['stock']?.toString() ?? '0') ?? 0;
    final bool enRupture = stock <= 10;
    final prix = double.tryParse(p['prix']?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enRupture
            ? Colors.red.withOpacity(0.05)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enRupture
              ? Colors.red.withOpacity(0.4)
              : const Color(0xFF2A2A2A),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _getImageStock(p['nom'] ?? ''),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: enRupture
                      ? Colors.red.withOpacity(0.15)
                      : violet.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: enRupture ? Colors.red : violet,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['nom'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${prix.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                if (enRupture)
                  const Text(
                    '⚠️ Stock faible',
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  ),
              ],
            ),
          ),
          // Boutons stock
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (stock > 0) {
                    modifierStock(p['id'], stock - 1);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, color: Colors.red, size: 16),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$stock',
                  style: TextStyle(
                    color: enRupture ? Colors.red : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => modifierStock(p['id'], stock + 1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.green, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getImagePaiement(String mode) {
    switch (mode) {
      case 'orange_money':
        return 'assets/images/orange_money.png';
      case 'mtn_money':
        return 'assets/images/mtn_money.png';
      case 'wave':
        return 'assets/images/wave.png';
      case 'moov_money':
        return 'assets/images/moov_money.png';
      default:
        return '';
    }
  }

  void _confirmDeconnexion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Êtes-vous sûr ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: violet),
            onPressed: () async {
              await ApiService.supprimerToken();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icon;
  final Color couleur;
  const _StatCard({
    required this.titre,
    required this.valeur,
    required this.icon,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: couleur.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: couleur.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: couleur, size: 24),
            const SizedBox(height: 6),
            Text(
              valeur,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: couleur,
              ),
            ),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
