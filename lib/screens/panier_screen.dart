import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/panier_manager.dart';
import '../services/api_service.dart'; //
import 'checkout_screen.dart';

class PanierScreen extends StatefulWidget {
  const PanierScreen({super.key});

  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  double get total => Provider.of<PanierManager>(context, listen: false)
      .articles
      .fold(0, (sum, p) => sum + (double.tryParse(p['prix'].toString()) ?? 0));

  @override
  Widget build(BuildContext context) {
    final panier = Provider.of<PanierManager>(context);
    final articles = panier.articles;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'MON PANIER',
          style: TextStyle(
            color: Color(0xFFC9A84C),
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFC9A84C)),
        actions: [
          if (articles.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1A1A1A),
                    title: const Text(
                      'Vider le panier',
                      style: TextStyle(color: Color(0xFFC9A84C)),
                    ),
                    content: const Text(
                      'Supprimer tous les articles ?',
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        //
                        onPressed: () async {
                          final userId = await ApiService.getId() ?? 0;

                          // 1. Sauvegarder la commande en BDD
                          await ApiService.creerCommande(
                            userId,
                            total.toInt(),
                            panier.articles,
                          );

                          // 2. Vider le panier
                          await panier.vider();

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Vider',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Vider',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
        ],
      ),
      body: articles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Color(0xFF2A2A2A),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Votre panier est vide',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoutez des produits depuis la boutique',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A84C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'ALLER À LA BOUTIQUE',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  color: const Color(0xFF111111),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      _EtapeItem(numero: '1', titre: 'Panier', actif: true),
                      Expanded(
                        child: Container(height: 1, color: Colors.white24),
                      ),
                      _EtapeItem(
                        numero: '2',
                        titre: 'Livraison',
                        actif: false,
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.white24),
                      ),
                      _EtapeItem(numero: '3', titre: 'Paiement', actif: false),
                      Expanded(
                        child: Container(height: 1, color: Colors.white24),
                      ),
                      _EtapeItem(
                        numero: '4',
                        titre: 'Confirmation',
                        actif: false,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final p = articles[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12),
                              ),
                              child: p['image'] != null
                                  ? Image.asset(
                                      p['image'],
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 90,
                                        height: 90,
                                        color: const Color(0xFF2A2A2A),
                                        child: const Icon(
                                          Icons.inventory_2,
                                          color: Color(0xFFC9A84C),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 90,
                                      height: 90,
                                      color: const Color(0xFF2A2A2A),
                                      child: const Icon(
                                        Icons.inventory_2,
                                        color: Color(0xFFC9A84C),
                                        size: 40,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['nom'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${p['prix']} FCFA',
                                      style: const TextStyle(
                                        color: Color(0xFFC9A84C),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // ✅ Corrigé : supprimerArticle(index)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => panier.supprimerArticle(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF111111),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sous-total',
                            style: TextStyle(color: Colors.white54),
                          ),
                          Text(
                            '${total.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Livraison',
                            style: TextStyle(color: Colors.white54),
                          ),
                          Text(
                            'Gratuite',
                            style: TextStyle(color: Color(0xFFC9A84C)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF2A2A2A)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            '${total.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              color: Color(0xFFC9A84C),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC9A84C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckoutScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'COMMANDER MAINTENANT',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _EtapeItem extends StatelessWidget {
  final String numero;
  final String titre;
  final bool actif;
  const _EtapeItem({
    required this.numero,
    required this.titre,
    required this.actif,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: actif ? const Color(0xFFC9A84C) : const Color(0xFF2A2A2A),
            shape: BoxShape.circle,
            border: Border.all(
              color: actif ? const Color(0xFFC9A84C) : Colors.white24,
            ),
          ),
          child: Center(
            child: Text(
              numero,
              style: TextStyle(
                color: actif ? Colors.black : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titre,
          style: TextStyle(
            color: actif ? Colors.white : Colors.white38,
            fontSize: 9,
            fontWeight: actif ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
