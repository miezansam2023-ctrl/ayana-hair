import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CommandeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> commande;

  const CommandeDetailScreen({super.key, required this.commande});

  @override
  State<CommandeDetailScreen> createState() => _CommandeDetailScreenState();
}

class _CommandeDetailScreenState extends State<CommandeDetailScreen> {
  List<dynamic> details = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerDetails();
  }

  void chargerDetails() async {
    final data = await ApiService.getCommandeDetails(widget.commande['id']);

    setState(() {
      details = data;
      isLoading = false;
    });
  }

  // =========================
  // STATUT
  // =========================

  Color getStatutColor(String statut) {
    switch (statut) {
      case 'confirmee':
        return const Color(0xFFC9A84C);

      case 'livree':
        return Colors.green;

      default:
        return Colors.orange;
    }
  }

  String getStatutLabel(String statut) {
    switch (statut) {
      case 'confirmee':
        return 'Confirmée';

      case 'livree':
        return 'Livrée';

      default:
        return 'En attente';
    }
  }

  // =========================
  // PAIEMENT
  // =========================

  IconData _getPaiementIcon(String mode) {
    switch (mode) {
      case 'orange_money':
        return Icons.phone_android;

      case 'mtn_money':
        return Icons.phone_android;

      case 'wave':
        return Icons.waves;

      case 'livraison':
        return Icons.delivery_dining;

      case 'carte':
        return Icons.credit_card;

      default:
        return Icons.payment;
    }
  }

  Color _getPaiementCouleur(String mode) {
    switch (mode) {
      case 'orange_money':
        return const Color(0xFFFF6600);

      case 'mtn_money':
        return const Color(0xFFFFCC00);

      case 'wave':
        return const Color(0xFF1BA6E0);

      case 'livraison':
        return const Color(0xFFC9A84C);

      case 'carte':
        return const Color(0xFF6C63FF);

      default:
        return Colors.white54;
    }
  }

  String _getPaiementSousTitre(String mode) {
    switch (mode) {
      case 'orange_money':
        return '+225 07 XX XX XX XX';

      case 'mtn_money':
        return '+225 05 XX XX XX XX';

      case 'wave':
        return '+225 01 XX XX XX XX';

      case 'livraison':
        return 'Payez en cash à la réception';

      case 'carte':
        return 'Visa / Mastercard';

      default:
        return '';
    }
  }

  String _getPaiementLabel(String mode) {
    switch (mode) {
      case 'orange_money':
        return 'Orange Money';

      case 'mtn_money':
        return 'MTN Mobile Money';

      case 'wave':
        return 'Wave';

      case 'livraison':
        return 'Paiement à la livraison';

      case 'carte':
        return 'Carte bancaire';

      default:
        return mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.commande;

    final statut = c['statut'] ?? 'en_attente';

    final date = DateTime.tryParse(c['created_at'] ?? '') ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: Text(
          'COMMANDE #${c['id']}',
          style: const TextStyle(
            color: Color(0xFFC9A84C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        centerTitle: true,

        iconTheme: const IconThemeData(color: Color(0xFFC9A84C)),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC9A84C)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =========================
                  // STATUT + DATE
                  // =========================
                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: getStatutColor(statut).withOpacity(0.4),
                      ),
                    ),

                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: getStatutColor(statut).withOpacity(0.15),

                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            statut == 'livree'
                                ? Icons.local_shipping
                                : statut == 'confirmee'
                                ? Icons.check_circle_outline
                                : Icons.pending_outlined,

                            color: getStatutColor(statut),

                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                getStatutLabel(statut),

                                style: TextStyle(
                                  color: getStatutColor(statut),

                                  fontWeight: FontWeight.bold,

                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',

                                style: const TextStyle(
                                  color: Colors.white54,

                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // TIMELINE
                  // =========================
                  _buildTimeline(statut),

                  const SizedBox(height: 20),

                  // =========================
                  // MODE DE PAIEMENT
                  // =========================
                  if (c['mode_paiement'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              color: _getPaiementCouleur(
                                c['mode_paiement'],
                              ).withOpacity(0.15),

                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: _getLogoPaiement(c['mode_paiement']),
                          ),

                          const SizedBox(width: 16),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'MODE DE PAIEMENT',

                                style: TextStyle(
                                  color: Colors.white38,

                                  fontSize: 10,

                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _getPaiementLabel(c['mode_paiement']),

                                style: TextStyle(
                                  color: _getPaiementCouleur(
                                    c['mode_paiement'],
                                  ),

                                  fontWeight: FontWeight.bold,

                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                c['telephone'] ??
                                    _getPaiementSousTitre(c['mode_paiement']),

                                style: const TextStyle(
                                  color: Colors.white38,

                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // =========================
                  // ARTICLES
                  // =========================
                  const Text(
                    'ARTICLES COMMANDÉS',

                    style: TextStyle(
                      color: Color(0xFFC9A84C),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 12),

                  details.isEmpty
                      ? const Text(
                          'Aucun détail disponible',

                          style: TextStyle(color: Colors.white54),
                        )
                      : Column(
                          children: details
                              .map((d) => _buildArticle(d))
                              .toList(),
                        ),

                  const SizedBox(height: 20),

                  // =========================
                  // RECAP
                  // =========================
                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),

                    child: Column(
                      children: [
                        const Text(
                          'RÉCAPITULATIF',

                          style: TextStyle(
                            color: Color(0xFFC9A84C),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),

                        const Divider(color: Color(0xFF2A2A2A), height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            const Text(
                              'Sous-total',

                              style: TextStyle(color: Colors.white54),
                            ),

                            Text(
                              '${double.tryParse(c['total'].toString())?.toStringAsFixed(0) ?? c['total']} FCFA',

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

                        const Divider(color: Color(0xFF2A2A2A), height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            const Text(
                              'TOTAL',

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1,
                              ),
                            ),

                            Text(
                              '${c['total']} FCFA',

                              style: const TextStyle(
                                color: Color(0xFFC9A84C),

                                fontWeight: FontWeight.bold,

                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // =========================
  // ARTICLE
  // =========================

  Widget _buildArticle(Map<String, dynamic> d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),

            child: _getImageProduit(d['nom'] ?? ''),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  d['nom'] ?? 'Produit',

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Qté : ${d['quantite']}',

                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            '${double.tryParse(d['prix_unitaire'].toString())?.toStringAsFixed(0) ?? d['prix_unitaire']} FCFA',

            style: const TextStyle(
              color: Color(0xFFC9A84C),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconeProduit() {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFF2A2A2A),

      child: const Icon(Icons.inventory_2, color: Color(0xFFC9A84C)),
    );
  }

  // =========================
  // TIMELINE
  // =========================

  Widget _buildTimeline(String statut) {
    final etapes = [
      {
        'label': 'Commande passée',
        'done': true,
        'icon': Icons.receipt_outlined,
      },

      {
        'label': 'Confirmée',
        'done': statut == 'confirmee' || statut == 'livree',

        'icon': Icons.check_circle_outline,
      },

      {
        'label': 'En livraison',
        'done': statut == 'livree',
        'icon': Icons.local_shipping_outlined,
      },

      {
        'label': 'Livrée',
        'done': statut == 'livree',
        'icon': Icons.home_outlined,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),

      child: Row(
        children: List.generate(etapes.length, (i) {
          final e = etapes[i];

          final bool done = e['done'] as bool;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,

                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0xFFC9A84C)
                              : const Color(0xFF2A2A2A),

                          shape: BoxShape.circle,
                        ),

                        child: Icon(
                          e['icon'] as IconData,

                          color: done ? Colors.black : Colors.white38,

                          size: 18,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        e['label'] as String,

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: done ? Colors.white : Colors.white38,

                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),

                if (i < etapes.length - 1)
                  Container(
                    height: 2,
                    width: 8,

                    color: done
                        ? const Color(0xFFC9A84C)
                        : const Color(0xFF2A2A2A),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // =========================
  // IMAGES PRODUITS
  // =========================

  final Map<String, String> _imagesProduits = {
    'Huile de Coco': 'assets/images/huilecoco.png',

    'Shampoing Karité': 'assets/images/shampkarite.png',

    'Masque Capillaire': 'assets/images/masqcapi.png',

    'Sérum Croissance': 'assets/images/serumcroiss.png',

    'Après-shampoing': 'assets/images/apshamp.png',

    'Huile de Ricin': 'assets/images/huiri.png',
  };

  Widget _getImageProduit(String nom) {
    final image = _imagesProduits[nom];

    if (image != null) {
      return Image.asset(
        image,

        width: 60,
        height: 60,

        fit: BoxFit.cover,

        errorBuilder: (_, __, ___) => _iconeProduit(),
      );
    }

    return _iconeProduit();
  }

  Widget _getLogoPaiement(String mode) {
    final logos = {
      'orange_money': 'assets/images/orange_money.png',
      'mtn_money': 'assets/images/mtn_money.png',
      'wave': 'assets/images/wave.png',
      'moov_money': 'assets/images/moov_money.png',
    };
    final logo = logos[mode];
    if (logo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          logo,
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            _getPaiementIcon(mode),
            color: _getPaiementCouleur(mode),
            size: 26,
          ),
        ),
      );
    }
    return Icon(
      _getPaiementIcon(mode),
      color: _getPaiementCouleur(mode),
      size: 26,
    );
  }
}
