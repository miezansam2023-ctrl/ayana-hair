import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/panier_manager.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int etapeActuelle = 2; // 2=Livraison, 3=Paiement, 4=Confirmation

  final nomController = TextEditingController();
  final adresseController = TextEditingController();
  final telephoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? modePaiementSelectionne;
  bool isLoading = false;

  final List<Map<String, dynamic>> modesPaiement = [
    {
      'id': 'orange_money',
      'nom': 'Orange Money',
      'logo': 'assets/images/orange_money.png',
      
      'couleur': const Color(0xFFFF6600),
    },
    {
      'id': 'mtn_money',
      'nom': 'MTN Mobile Money',
      'logo': 'assets/images/mtn_money.png',
      
      'couleur': const Color(0xFFFFCC00),
    },
    {
      'id': 'wave',
      'nom': 'Wave',
      'logo': 'assets/images/wave.png',
      
      'couleur': const Color(0xFF1BA6E0),
    },
    {
      'id': 'moov_money',
      'nom': 'Moov Money',
      'logo': 'assets/images/moov_money.png',
      
      'couleur': const Color(0xFF0066CC),
    },
    {
      'id': 'livraison',
      'nom': 'Paiement à la livraison',
      'logo': null,
      'icon': Icons.delivery_dining,
      'numero': 'Payez en cash à la réception',
      'couleur': const Color(0xFFC9A84C),
    },
  ];

  @override
  void dispose() {
    nomController.dispose();
    adresseController.dispose();
    telephoneController.dispose();
    super.dispose();
  }

  void etapeSuivante() {
    if (etapeActuelle == 1) {
      setState(() => etapeActuelle = 2);
    } else if (etapeActuelle == 2) {
      if (_formKey.currentState!.validate()) {
        setState(() => etapeActuelle = 3);
      }
    } else if (etapeActuelle == 3) {
      if (modePaiementSelectionne == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez choisir un mode de paiement'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => etapeActuelle = 4);
    }
  }

  Future<void> confirmerCommande() async {
    setState(() => isLoading = true);
    final panier = Provider.of<PanierManager>(context, listen: false);
    final userId = await ApiService.getId() ?? 0;
    await ApiService.creerCommande(
      userId,
      panier.total.toInt(),
      panier.articles,
      nomLivraison: nomController.text,
      telephone: telephoneController.text,
      adresse: adresseController.text,
      modePaiement: modePaiementSelectionne ?? '',
    );
    await panier.vider();
    setState(() => isLoading = false);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFFC9A84C),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Commande confirmée !',
              style: TextStyle(
                color: Color(0xFFC9A84C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Votre commande a été passée avec succès !',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              'Livraison estimée : 24-48h',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A84C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text(
                  'RETOUR À L\'ACCUEIL',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panier = Provider.of<PanierManager>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'MA COMMANDE',
          style: TextStyle(
            color: Color(0xFFC9A84C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFC9A84C)),
      ),
      body: Column(
        children: [
          _buildBarreEtapes(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: etapeActuelle == 1
                  ? _buildEtapePanier(panier)
                  : etapeActuelle == 2
                  ? _buildEtapeLivraison()
                  : etapeActuelle == 3
                  ? _buildEtapePaiement()
                  : _buildEtapeRecapitulatif(panier),
            ),
          ),
          _buildBoutonBas(panier),
        ],
      ),
    );
  }

  Widget _buildBarreEtapes() {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          _etapeIndicateur(1, 'Panier'),
          _barre(1),
          _etapeIndicateur(2, 'Livraison'),
          _barre(2),
          _etapeIndicateur(3, 'Paiement'),
          _barre(3),
          _etapeIndicateur(4, 'Confirmation'),
        ],
      ),
    );
  }

  Widget _barre(int apresEtape) {
    return Expanded(
      child: Container(
        height: 1,
        color: etapeActuelle > apresEtape
            ? const Color(0xFFC9A84C)
            : Colors.white24,
      ),
    );
  }

  Widget _etapeIndicateur(int numero, String titre) {
    final bool actif = etapeActuelle >= numero;
    final bool done = etapeActuelle > numero;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: actif ? const Color(0xFFC9A84C) : const Color(0xFF2A2A2A),
            shape: BoxShape.circle,
            border: Border.all(
              color: actif ? const Color(0xFFC9A84C) : Colors.white24,
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.black, size: 14)
                : Text(
                    '$numero',
                    style: TextStyle(
                      color: actif ? Colors.black : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildEtapePanier(PanierManager panier) {
    final articles = panier.articles;
    if (articles.isEmpty) {
      return const Center(
        child: Text('Panier vide', style: TextStyle(color: Colors.white54)),
      );
    }
    return Column(
      children: [
        const Text(
          'VOTRE PANIER',
          style: TextStyle(
            color: Color(0xFFC9A84C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        ...articles.asMap().entries.map((entry) {
          final index = entry.key;
          final p = entry.value;
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
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFF2A2A2A),
                            child: const Icon(
                              Icons.inventory_2,
                              color: Color(0xFFC9A84C),
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: const Color(0xFF2A2A2A),
                          child: const Icon(
                            Icons.inventory_2,
                            color: Color(0xFFC9A84C),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['nom'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${p['prix']} FCFA',
                        style: const TextStyle(color: Color(0xFFC9A84C)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => panier.supprimerArticle(index),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
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
                  const Text(
                    'Sous-total',
                    style: TextStyle(color: Colors.white54),
                  ),
                  Text(
                    '${panier.total.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Livraison', style: TextStyle(color: Colors.white54)),
                  Text('Gratuite', style: TextStyle(color: Color(0xFFC9A84C))),
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
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${panier.total.toStringAsFixed(0)} FCFA',
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
      ],
    );
  }

  Widget _buildEtapeLivraison() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INFORMATIONS DE LIVRAISON',
            style: TextStyle(
              color: Color(0xFFC9A84C),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildLabel('NOM COMPLET'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: nomController,
            hint: 'Votre nom complet',
            icon: Icons.person_outline,
            validator: (v) =>
                v == null || v.isEmpty ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('TÉLÉPHONE'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: telephoneController,
            hint: '01 05 07 00 00',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.isEmpty ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('ADRESSE DE LIVRAISON'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: adresseController,
            hint: 'Quartier, rue, description...',
            icon: Icons.location_on_outlined,
            maxLines: 3,
            validator: (v) =>
                v == null || v.isEmpty ? 'Champ obligatoire' : null,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFC9A84C).withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFFC9A84C),
                  size: 20,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Livraison gratuite',
                      style: TextStyle(
                        color: Color(0xFFC9A84C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Délai estimé : 24 à 48 heures',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtapePaiement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MODE DE PAIEMENT',
          style: TextStyle(
            color: Color(0xFFC9A84C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choisissez votre méthode de paiement préférée',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 24),
        ...modesPaiement.map((mode) {
          final bool sel = modePaiementSelectionne == mode['id'];
          return GestureDetector(
            onTap: () => setState(() => modePaiementSelectionne = mode['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF1A1A1A) : const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel
                      ? const Color(0xFFC9A84C)
                      : const Color(0xFF2A2A2A),
                  width: sel ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (mode['couleur'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: mode['logo'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              mode['logo'],
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.payment,
                                color: mode['couleur'] as Color,
                                size: 24,
                              ),
                            ),
                          )
                        : Icon(
                            mode['icon'] as IconData,
                            color: mode['couleur'] as Color,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode['nom'],
                          style: TextStyle(
                            color: sel ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: sel ? const Color(0xFFC9A84C) : Colors.white24,
                        width: 2,
                      ),
                      color: sel ? const Color(0xFFC9A84C) : Colors.transparent,
                    ),
                    child: sel
                        ? const Icon(Icons.check, color: Colors.black, size: 14)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEtapeRecapitulatif(PanierManager panier) {
    final modePaie = modesPaiement.firstWhere(
      (m) => m['id'] == modePaiementSelectionne,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RÉCAPITULATIF',
          style: TextStyle(
            color: Color(0xFFC9A84C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection('Livraison', [
          _buildLigne('Nom', nomController.text),
          _buildLigne('Téléphone', telephoneController.text),
          _buildLigne('Adresse', adresseController.text),
        ]),
        const SizedBox(height: 16),
        _buildSection('Paiement', [_buildLigne('Mode', modePaie['nom'])]),
        const SizedBox(height: 16),
        _buildSection('Articles (${panier.nombreArticles})', [
          ...panier.articles.map(
            (p) => _buildLigne(p['nom'], '${p['prix']} FCFA'),
          ),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC9A84C)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL À PAYER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${panier.total.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  color: Color(0xFFC9A84C),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String titre, List<Widget> enfants) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: const TextStyle(
              color: Color(0xFFC9A84C),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 20),
          ...enfants,
        ],
      ),
    );
  }

  Widget _buildLigne(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String texte) {
    return Text(
      texte,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 11,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFC9A84C)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC9A84C)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildBoutonBas(PanierManager panier) {
    String texte;
    if (etapeActuelle == 1)
      texte = 'CONTINUER → LIVRAISON';
    else if (etapeActuelle == 2)
      texte = 'CONTINUER → PAIEMENT';
    else if (etapeActuelle == 3)
      texte = 'CONTINUER → RÉCAPITULATIF';
    else
      texte = 'CONFIRMER LA COMMANDE';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          if (etapeActuelle > 1) ...[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFC9A84C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onPressed: () => setState(() => etapeActuelle--),
              child: const Icon(Icons.arrow_back, color: Color(0xFFC9A84C)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A84C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : (etapeActuelle == 4 ? confirmerCommande : etapeSuivante),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        texte,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
