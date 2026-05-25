import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/panier_manager.dart';
import 'panier_screen.dart';

class BoutiqueScreen extends StatefulWidget {
  const BoutiqueScreen({super.key});

  @override
  State<BoutiqueScreen> createState() => _BoutiqueScreenState();
}

class _BoutiqueScreenState extends State<BoutiqueScreen> {
  List<dynamic> produits = [];
  String categorieSelectionnee = 'Tous';
  bool isLoading = true;

  final Map<String, String> imagesProduits = {
    'Huile de Coco': 'assets/images/huilecoco.png',
    'Shampoing Karité': 'assets/images/shampkarite.png',
    'Masque Capillaire': 'assets/images/masqcapi.png',
    'Sérum Croissance': 'assets/images/serumcroiss.png',
    'Après-shampoing': 'assets/images/apshamp.png',
    'Huile de Ricin': 'assets/images/huiri.png',
  };

  @override
  void initState() {
    super.initState();
    chargerProduits();
  }

  void chargerProduits() async {
    final data = await ApiService.getProduits();
    setState(() {
      produits = data;
      isLoading = false;
    });
  }

  List<dynamic> get produitsFiltres {
    if (categorieSelectionnee == 'Tous') return produits;
    return produits
        .where((p) => p['categorie'] == categorieSelectionnee)
        .toList();
  }

  void ajouterAuPanier(Map<String, dynamic> produit) {
    final panier = Provider.of<PanierManager>(context, listen: false);
    panier.ajouterArticle(produit);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${produit['nom']} ajouté au panier !'),
        backgroundColor: const Color(0xFFC9A84C),
        duration: const Duration(seconds: 1),
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
        title: const Text('BOUTIQUE',
            style: TextStyle(
                color: Color(0xFFC9A84C),
                fontWeight: FontWeight.bold,
                letterSpacing: 3)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFC9A84C)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined,
                    color: Color(0xFFC9A84C)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PanierScreen()),
                ),
              ),
              if (panier.nombreArticles > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC9A84C),
                      shape: BoxShape.circle,
                    ),
                    child: Text('${panier.nombreArticles}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : Column(
              children: [
                // Filtres
                Container(
                  color: const Color(0xFF111111),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ['Tous', 'Huiles', 'Shampoings', 'Soins']
                          .map((cat) {
                        final selected = cat == categorieSelectionnee;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => categorieSelectionnee = cat),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFC9A84C)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFC9A84C)
                                    : Colors.white24,
                              ),
                            ),
                            child: Text(cat,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.black
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                )),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Nombre produits
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${produitsFiltres.length} produit(s)',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ),
                // Grille
                Expanded(
                  child: produitsFiltres.isEmpty
                      ? const Center(
                          child: Text('Aucun produit disponible',
                              style: TextStyle(color: Colors.white54)))
                      : GridView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: produitsFiltres.length,
                          itemBuilder: (context, index) {
                            final p = produitsFiltres[index];
                            final imageAsset = imagesProduits[p['nom']] ??
                                'assets/images/huilecoco.png';
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF2A2A2A)),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                              top: Radius.circular(8)),
                                      child: Stack(
                                        children: [
                                          Image.asset(
                                            imageAsset,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFC9A84C),
                                                    width: 0.5),
                                              ),
                                              child: Text(
                                                p['categorie'] ?? '',
                                                style: const TextStyle(
                                                    color: Color(0xFFC9A84C),
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    letterSpacing: 1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p['nom'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text('${p['prix']} FCFA',
                                            style: const TextStyle(
                                                color: Color(0xFFC9A84C),
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFC9A84C),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4)),
                                            ),
                                            onPressed: () =>
                                                ajouterAuPanier({
                                              'id': p['id'],
                                              'nom': p['nom'],
                                              'prix': p['prix'],
                                              'image': imageAsset,
                                            }),
                                            child: const Text('AJOUTER AU PANIER',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    letterSpacing: 1)),
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
                ),
              ],
            ),
    );
  }
}