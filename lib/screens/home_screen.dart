import 'package:flutter/material.dart';
import 'boutique_screen.dart';
import 'panier_screen.dart';
import 'profil_screen.dart';
import 'package:provider/provider.dart';
import '../../services/panier_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: true,
        actions: [
          Consumer<PanierManager>(
            builder: (context, panier, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFFC9A84C),
                  ),
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
                      child: Text(
                        '${panier.nombreArticles}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bannière hero
            Stack(
              children: [
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/produits.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sublimez\nvos cheveux',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A84C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BoutiqueScreen(),
                          ),
                        ),
                        child: const Text(
                          'DÉCOUVRIR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Services
            Container(
              color: const Color(0xFF111111),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ServiceItem(
                    icon: Icons.local_shipping_outlined,
                    text: 'Livraison rapide',
                  ),
                  _ServiceItem(
                    icon: Icons.verified_outlined,
                    text: 'Produits authentiques',
                  ),
                  _ServiceItem(
                    icon: Icons.support_agent_outlined,
                    text: 'Support 24/7',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Titre section produits
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'NOS PRODUITS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Divider(color: Color(0xFFC9A84C), thickness: 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Grille produits
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
              children: const [
                _ProductCard(
                  nom: 'Huile de Coco',
                  prix: '5 000 FCFA',
                  image: 'assets/images/huilecoco.png',
                ),
                _ProductCard(
                  nom: 'Shampoing Karité',
                  prix: '7 500 FCFA',
                  image: 'assets/images/shampkarite.png',
                ),
                _ProductCard(
                  nom: 'Masque Capillaire',
                  prix: '9 000 FCFA',
                  image: 'assets/images/masqcapi.png',
                ),
                _ProductCard(
                  nom: 'Sérum Croissance',
                  prix: '12 000 FCFA',
                  image: 'assets/images/serumcroiss.png',
                ),
                _ProductCard(
                  nom: 'Après-Shampoing',
                  prix: '6 500 FCFA',
                  image: 'assets/images/apshamp.png',
                ),
                _ProductCard(
                  nom: 'Huile de Ricin',
                  prix: '8 000 FCFA',
                  image: 'assets/images/huiri.png',
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Footer
            Container(
              color: const Color(0xFF111111),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo.png', height: 60),
                  const SizedBox(height: 12),
                  const Text(
                    'Vos produits capillaires\nde qualité supérieure.',
                    style: TextStyle(color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFC9A84C)),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Color(0xFFC9A84C),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'contact@ayanahair.com',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        color: Color(0xFFC9A84C),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '+225 07 00 00 00 00',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF111111),
        selectedItemColor: const Color(0xFFC9A84C),
        unselectedItemColor: Colors.white38,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BoutiqueScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Boutique'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ServiceItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFC9A84C), size: 24),
        const SizedBox(height: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String nom;
  final String prix;
  final String image;
  const _ProductCard({
    required this.nom,
    required this.prix,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  prix,
                  style: const TextStyle(
                    color: Color(0xFFC9A84C),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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
