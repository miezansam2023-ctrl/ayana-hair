import 'package:flutter/material.dart';
import 'api_service.dart';

class PanierManager extends ChangeNotifier {
  static final PanierManager _instance = PanierManager._internal();
  factory PanierManager() => _instance;
  PanierManager._internal();

  final List<Map<String, dynamic>> _articles = [];
  int _utilisateurId = 0;

  List<Map<String, dynamic>> get articles => List.from(_articles);
  int get nombreArticles => _articles.length;
  double get total => _articles.fold(
    0,
    (sum, p) => sum + (double.tryParse(p['prix'].toString()) ?? 0),
  );

  // Appelé après connexion
  Future<void> setUtilisateur(int id) async {
    print('👤 setUtilisateur appelé avec id: $id');
    _utilisateurId = id;
    await chargerPanier();
  }

  // Charger depuis MySQL
  Future<void> chargerPanier() async {
    if (_utilisateurId == 0) return;
    final data = await ApiService.getPanier(_utilisateurId);
    _articles.clear();
    _articles.addAll(data.cast<Map<String, dynamic>>());
    notifyListeners();
  }

  // Ajouter
  Future<void> ajouterArticle(Map<String, dynamic> produit) async {
    print('🛒 ajouterArticle appelé');
    print('🛒 _utilisateurId = $_utilisateurId');
    _articles.add(produit);
    notifyListeners();
    if (_utilisateurId != 0) {
      await ApiService.ajouterAuPanier(produit, _utilisateurId);
    } else {
      print('⚠️ utilisateurId = 0 → pas envoyé en BDD !');
    }
  }

  // Supprimer un article
  Future<void> supprimerArticle(int index) async {
    final article = _articles[index];
    _articles.removeAt(index);
    notifyListeners();
    if (_utilisateurId != 0 && article['id'] != null) {
      await ApiService.supprimerDuPanier(article['id']);
    }
  }

  // Vider
  Future<void> vider() async {
    _articles.clear();
    notifyListeners();
    if (_utilisateurId != 0) {
      await ApiService.viderPanier(_utilisateurId);
    }
  }
}
