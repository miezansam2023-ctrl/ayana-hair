import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'historique_screen.dart';
import 'notification_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String nom = '';
  String email = '';
  String typeCheveux = 'Bouclés';
  int totalCommandes = 0;
  int commandesEnAttente = 0;
  int commandesLivrees = 0;

  @override
  void initState() {
    super.initState();
    chargerInfos();
  }

  void chargerInfos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nom = prefs.getString('nom') ?? 'Utilisateur';
      email = prefs.getString('email') ?? '';
      typeCheveux = prefs.getString('type_cheveux') ?? 'Bouclés';
    });
    // Charger les stats
    final id = await ApiService.getId();
    final commandes = await ApiService.getCommandes(id ?? 0);
    setState(() {
      totalCommandes = commandes.length;
      commandesEnAttente = commandes
          .where((c) => c['statut'] == 'en_attente')
          .length;
      commandesLivrees = commandes.where((c) => c['statut'] == 'livree').length;
    });
  }

  String get initiales {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (nom.length >= 2) return nom.substring(0, 2).toUpperCase();
    return nom.toUpperCase();
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: const Color(0xFFC9A84C)),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC9A84C)),
      ),
    );
  }

  void modifierProfil() {
    final nomCtrl = TextEditingController(text: nom);
    final emailCtrl = TextEditingController(text: email);
    String cheveux = typeCheveux;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MODIFIER MON PROFIL',
                style: TextStyle(
                  color: Color(0xFFC9A84C),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nomCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Nom complet',
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: cheveux,
                    dropdownColor: const Color(0xFF2A2A2A),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFFC9A84C),
                    ),
                    items: ['Bouclés', 'Lisses', 'Frisés', 'Crépus', 'Ondulés']
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setModalState(() => cheveux = val!),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final id = await ApiService.getId();
                    final result = await ApiService.modifierProfil(
                      id ?? 0,
                      nomCtrl.text,
                      emailCtrl.text,
                      cheveux,
                    );
                    if (result.containsKey('erreur')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['erreur']),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      setState(() {
                        nom = nomCtrl.text;
                        email = emailCtrl.text;
                        typeCheveux = cheveux;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil mis à jour avec succès! '),
                          backgroundColor: Color(0xFFC9A84C),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'ENREGISTRER',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changerMotDePasse() {
    final ancienCtrl = TextEditingController();
    final nouveauCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHANGER MOT DE PASSE',
              style: TextStyle(
                color: Color(0xFFC9A84C),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ancienCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Ancien mot de passe',
                Icons.lock_outline,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nouveauCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Nouveau mot de passe',
                Icons.lock_open,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Confirmer mot de passe',
                Icons.lock,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A84C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (nouveauCtrl.text != confirmCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Les mots de passe ne correspondent pas !',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final id = await ApiService.getId();
                  final result = await ApiService.modifierMotDePasse(
                    id ?? 0,
                    ancienCtrl.text,
                    nouveauCtrl.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ?? result['erreur'] ?? '',
                      ),
                      backgroundColor: result.containsKey('erreur')
                          ? Colors.red
                          : const Color(0xFFC9A84C),
                    ),
                  );
                },
                child: const Text(
                  'MODIFIER',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'MON PROFIL',
          style: TextStyle(
            color: Color(0xFFC9A84C),
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFC9A84C)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2A2A2A),
                          border: Border.all(
                            color: const Color(0xFFC9A84C),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initiales,
                            style: const TextStyle(
                              color: Color(0xFFC9A84C),
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: modifierProfil,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFC9A84C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFC9A84C)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Cheveux : $typeCheveux',
                      style: const TextStyle(
                        color: Color(0xFFC9A84C),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatCard(
                    titre: 'Commandes',
                    valeur: '$totalCommandes',
                    icon: Icons.shopping_bag,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    titre: 'En attente',
                    valeur: '$commandesEnAttente',
                    icon: Icons.pending,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    titre: 'Livrées',
                    valeur: '$commandesLivrees',
                    icon: Icons.check_circle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _MenuItem(
              icon: Icons.edit,
              titre: 'Modifier mon profil',
              onTap: modifierProfil,
            ),
            _MenuItem(
              icon: Icons.lock_outline,
              titre: 'Changer mot de passe',
              onTap: changerMotDePasse,
            ),
            _MenuItem(
              icon: Icons.history,
              titre: 'Historique commandes',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoriqueScreen()),
              ),
            ),

            _MenuItem(
              icon: Icons.notifications,
              titre: 'Notifications',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
            ),
            _MenuItem(icon: Icons.help, titre: 'Aide & Support', onTap: () {}),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Color(0xFFC9A84C)),
                  label: const Text(
                    'SE DÉCONNECTER',
                    style: TextStyle(
                      color: Color(0xFFC9A84C),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC9A84C)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1A1A),
                        title: const Text(
                          'Déconnexion',
                          style: TextStyle(color: Color(0xFFC9A84C)),
                        ),
                        content: const Text(
                          'Êtes-vous sûr de vouloir vous déconnecter ?',
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
                              backgroundColor: const Color(0xFFC9A84C),
                            ),
                            onPressed: () async {
                              await ApiService.supprimerToken();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Se déconnecter',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String titre;
  final String valeur;
  final IconData icon;
  const _StatCard({
    required this.titre,
    required this.valeur,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFC9A84C), size: 28),
            const SizedBox(height: 6),
            Text(
              valeur,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String titre;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.titre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC9A84C)),
        title: Text(titre, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white38,
        ),
        onTap: onTap,
      ),
    );
  }
}
