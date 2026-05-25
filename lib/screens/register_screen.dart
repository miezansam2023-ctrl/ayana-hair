import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String typeCheveux = 'Bouclés';
  bool isLoading = false;
  bool showPassword = false;

  void sInscrire() async {
    if (nomController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    final result = await ApiService.inscription(
      nomController.text,
      emailController.text,
      passwordController.text,
      typeCheveux,
    );
    setState(() => isLoading = false);

    if (result.containsKey('erreur')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['erreur']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie ! Connectez-vous 🎉'),
          backgroundColor: Color(0xFFC9A84C),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Image.network(
                    'https://res.cloudinary.com/dwwjln5xo/image/upload/v1779583247/fond_dia2mn.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF1A1A1A)),
                  ),
                ),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Image.asset('assets/images/logo.png', height: 80),
                  ),
                ),
                // Bouton retour
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC9A84C)),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFFC9A84C), size: 20),
                    ),
                  ),
                ),
              ],
            ),
            // Formulaire
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CRÉER UN COMPTE',
                      style: TextStyle(
                        color: Color(0xFFC9A84C),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      )),
                  const SizedBox(height: 6),
                  const Text('Rejoignez la communauté Ayana Hair',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 30),
                  // Nom
                  const Text('NOM COMPLET',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nomController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Votre nom complet',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.person_outline,
                          color: Color(0xFFC9A84C)),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFC9A84C)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Email
                  const Text('EMAIL',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'votre@email.com',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Color(0xFFC9A84C)),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFC9A84C)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Mot de passe
                  const Text('MOT DE PASSE',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.lock_outlined,
                          color: Color(0xFFC9A84C)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white38,
                        ),
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFFC9A84C)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Type cheveux
                  const Text('TYPE DE CHEVEUX',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: typeCheveux,
                        dropdownColor: const Color(0xFF1A1A1A),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFFC9A84C)),
                        items: ['Bouclés', 'Lisses', 'Frisés', 'Crépus', 'Ondulés']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.cut,
                                          color: Color(0xFFC9A84C),
                                          size: 18),
                                      const SizedBox(width: 10),
                                      Text(type,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => typeCheveux = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Bouton inscription
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A84C),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isLoading ? null : sInscrire,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text("S'INSCRIRE",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              )),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Déjà un compte
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Déjà un compte ? ',
                          style: TextStyle(color: Colors.white54),
                          children: [
                            TextSpan(
                              text: 'SE CONNECTER',
                              style: TextStyle(
                                color: Color(0xFFC9A84C),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}