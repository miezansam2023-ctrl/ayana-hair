import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Sauvegarder le token
  static Future<void> sauvegarderToken(
    String token,
    String role,
    String nom,
    String email,
    int id,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('nom', nom);
    await prefs.setString('email', email);
    await prefs.setInt('id', id);
  }

  static Future<int?> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Récupérer le nom
  static Future<String?> getNom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nom');
  }

  // Supprimer le token (déconnexion)
  static Future<void> supprimerToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // CONNEXION
  static Future<Map<String, dynamic>> connexion(
    String email,
    String motDePasse,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/connexion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'mot_de_passe': motDePasse}),
      );
      final data = jsonDecode(response.body);
      if (data.containsKey('token')) {
        await sauvegarderToken(
          data['token'],
          data['role'],
          data['nom'],
          email,
          data['id'] ?? 0,
        );
      }
      return data;
    } catch (e) {
      return {'erreur': 'Impossible de contacter le serveur'};
    }
  }

  // INSCRIPTION
  static Future<Map<String, dynamic>> inscription(
    String nom,
    String email,
    String motDePasse,
    String typeCheveux,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'mot_de_passe': motDePasse,
          'type_cheveux': typeCheveux,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'erreur': 'Impossible de contacter le serveur'};
    }
  }

  // PRODUITS
  static Future<List<dynamic>> getProduits() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/produits'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }

  // MODIFIER STOCK
  static Future<void> modifierStock(int id, int stock) async {
    try {
      final token = await getToken();
      await http.put(
        Uri.parse('$baseUrl/produits/$id/stock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'stock': stock}),
      );
    } catch (e) {
      print('Erreur modification stock: $e');
    }
  }

  // COMMANDE
  static Future<Map<String, dynamic>> creerCommande(
    int utilisateurId,
    int total,
    List<Map<String, dynamic>> produits, {
    String nomLivraison = '',
    String telephone = '',
    String adresse = '',
    String modePaiement = '',
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/commandes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'utilisateur_id': utilisateurId,
          'total': total,
          'produits': produits,
          'nom_livraison': nomLivraison,
          'telephone': telephone,
          'adresse': adresse,
          'mode_paiement': modePaiement,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'erreur': 'Impossible de créer la commande'};
    }
  }

  // MODIFIER PROFIL
  static Future<Map<String, dynamic>> modifierProfil(
    int id,
    String nom,
    String email,
    String typeCheveux,
  ) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/utilisateurs/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'type_cheveux': typeCheveux,
        }),
      );
      // Mettre à jour les infos locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nom', nom);
      await prefs.setString('email', email);
      return jsonDecode(response.body);
    } catch (e) {
      return {'erreur': 'Impossible de modifier le profil'};
    }
  }

  // MODIFIER MOT DE PASSE
  static Future<Map<String, dynamic>> modifierMotDePasse(
    int id,
    String ancien,
    String nouveau,
  ) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/utilisateurs/$id/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'ancien': ancien, 'nouveau': nouveau}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'erreur': 'Impossible de modifier le mot de passe'};
    }
  }

  // PANIER - Ajouter
  // PANIER - Ajouter
  static Future<void> ajouterAuPanier(
    Map<String, dynamic> article,
    int utilisateurId,
  ) async {
    try {
      final token = await getToken();
      print('📦 Ajout panier → utilisateur_id: $utilisateurId');
      print('📦 Article: $article');

      final response = await http.post(
        Uri.parse('$baseUrl/panier'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'utilisateur_id': utilisateurId,
          'produit_id': article['id'],
          'nom': article['nom'],
          'prix': article['prix'],
          'image': article['image'],
        }),
      );
      print('📦 Réponse serveur: ${response.statusCode} → ${response.body}');
    } catch (e) {
      print('❌ Erreur ajout panier: $e');
    }
  }

  // PANIER - Récupérer
  static Future<List<dynamic>> getPanier(int utilisateurId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/panier/$utilisateurId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }

  // PANIER - Supprimer un article
  static Future<void> supprimerDuPanier(int panierItemId) async {
    try {
      final token = await getToken();
      await http.delete(
        Uri.parse('$baseUrl/panier/$panierItemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Erreur suppression panier: $e');
    }
  }

  // PANIER - Vider
  static Future<void> viderPanier(int utilisateurId) async {
    try {
      final token = await getToken();
      await http.delete(
        Uri.parse('$baseUrl/panier/vider/$utilisateurId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Erreur vidage panier: $e');
    }
  }

  // COMMANDES - Historique
  static Future<List<dynamic>> getCommandes(int utilisateurId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/commandes/$utilisateurId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }

  // COMMANDE - Détails
  static Future<List<dynamic>> getCommandeDetails(int commandeId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/commandes/details/$commandeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }

  // NOTIFICATIONS
  static Future<List<dynamic>> getNotifications(int utilisateurId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$utilisateurId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }

  static Future<void> marquerNotificationLue(int id) async {
    try {
      final token = await getToken();
      await http.put(
        Uri.parse('$baseUrl/notifications/$id/lu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Erreur: $e');
    }
  }

  static Future<void> toutMarquerLu(int utilisateurId) async {
    try {
      final token = await getToken();
      await http.put(
        Uri.parse('$baseUrl/notifications/tout-lire/$utilisateurId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      print('Erreur: $e');
    }
  }
}
