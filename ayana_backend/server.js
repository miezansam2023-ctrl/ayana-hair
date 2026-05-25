const express = require('express');
const mysql2 = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

// Connexion MySQL
const db = mysql2.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'ayana_hair'
});

db.connect((err) => {
  if (err) {
    console.log('❌ Erreur connexion MySQL:', err);
  } else {
    console.log('✅ Connecté à MySQL - ayana_hair');
  }
});

// ==================== ROUTES ====================

// Test
app.get('/', (req, res) => {
  res.json({ message: 'Ayana Hair API fonctionne !' });
});

// INSCRIPTION
app.post('/api/inscription', async (req, res) => {
  const { nom, email, mot_de_passe, type_cheveux } = req.body;
  const hash = await bcrypt.hash(mot_de_passe, 10);
  const sql = 'INSERT INTO utilisateurs (nom, email, mot_de_passe, type_cheveux) VALUES (?, ?, ?, ?)';
  db.query(sql, [nom, email, hash, type_cheveux], (err, result) => {
    if (err) return res.status(400).json({ erreur: 'Email déjà utilisé' });
    res.json({ message: 'Inscription réussie !' });
  });
});


// CONNEXION
app.post('/api/connexion', (req, res) => {
  const { email, mot_de_passe } = req.body;
  const sql = 'SELECT * FROM utilisateurs WHERE email = ?';
  db.query(sql, [email], async (err, results) => {
    if (err || results.length === 0)
      return res.status(401).json({ erreur: 'Email ou mot de passe incorrect' });
    const user = results[0];
    const valide = user.role === 'admin'
      ? mot_de_passe === user.mot_de_passe
      : await bcrypt.compare(mot_de_passe, user.mot_de_passe);
    if (!valide)
      return res.status(401).json({ erreur: 'Email ou mot de passe incorrect' });
    const token = jwt.sign({ id: user.id, role: user.role }, 'ayana_secret', { expiresIn: '24h' });
    res.json({ token, role: user.role, nom: user.nom, id: user.id });
  });
});

// ADMIN - Statistiques
app.get('/api/admin/stats', (req, res) => {
  db.query(`
    SELECT 
      (SELECT COUNT(*) FROM commandes) as total_commandes,
      (SELECT COALESCE(SUM(total), 0) FROM commandes) as chiffre_affaires,
      (SELECT COUNT(*) FROM commandes WHERE statut = 'en_attente') as en_attente,
      (SELECT COUNT(*) FROM utilisateurs WHERE role != 'admin') as total_clients
  `, (err, results) => {
    if (err) return res.status(500).json({ erreur: err.message });
    res.json(results[0]);
  });
});

// ADMIN - Toutes les commandes
app.get('/api/admin/commandes', (req, res) => {
  db.query(`
    SELECT c.*, u.nom as client_nom, u.email as client_email, u.type_cheveux
    FROM commandes c
    LEFT JOIN utilisateurs u ON c.utilisateur_id = u.id
    ORDER BY c.created_at DESC
  `, (err, results) => {
    if (err) return res.status(500).json({ erreur: err.message });
    res.json(results);
  });
});

// ADMIN - Changer statut commande
app.put('/api/admin/commandes/:id/statut', (req, res) => {
  const { statut } = req.body;

  // D'abord récupérer la commande pour avoir l'utilisateur_id
  db.query('SELECT * FROM commandes WHERE id = ?', [req.params.id], (err, results) => {
    if (err || results.length === 0)
      return res.status(404).json({ erreur: 'Commande introuvable' });

    const commande = results[0];

    // Mettre à jour le statut
    db.query('UPDATE commandes SET statut = ? WHERE id = ?',
      [statut, req.params.id],
      (err) => {
        if (err) return res.status(500).json({ erreur: err.message });

        // Créer la notification
        const messages = {
          'confirmee': {
            titre: 'Commande confirmée ✅',
            message: `Votre commande #${commande.id} a été confirmée. Montant : ${commande.total} FCFA.`,
          },
          'en_livraison': {
            titre: 'Commande en livraison 🚚',
            message: `Votre commande #${commande.id} est en cours de livraison. Livraison estimée : 24h.`,
          },
          'livree': {
            titre: 'Commande livrée 🎉',
            message: `Votre commande #${commande.id} a été livrée avec succès. Merci pour votre confiance !`,
          },
          'annulee': {
            titre: 'Commande annulée ❌',
            message: `Votre commande #${commande.id} a été annulée. Contactez-nous pour plus d'informations.`,
          },
          'en_attente': {
            titre: 'Commande en attente ⏳',
            message: `Votre commande #${commande.id} est en attente de traitement.`,
          },
        };

        const notif = messages[statut];
        if (notif) {
          db.query(
            'INSERT INTO notifications (utilisateur_id, titre, message, type) VALUES (?, ?, ?, ?)',
            [commande.utilisateur_id, notif.titre, notif.message, 'commande'],
            (err) => { if (err) console.log('Erreur notif:', err.message); }
          );
        }

        res.json({ message: 'Statut mis à jour !' });
      }
    );
  });
});

// ADMIN - Stocks depuis BDD
app.get('/api/admin/stocks', (req, res) => {
  db.query('SELECT * FROM produits ORDER BY nom', (err, results) => {
    if (err) return res.status(500).json({ erreur: err.message });
    res.json(results);
  });
});

// ADMIN - Modifier stock
app.put('/api/admin/stocks/:id', (req, res) => {
  const { stock } = req.body;
  db.query('UPDATE produits SET stock = ? WHERE id = ?',
    [stock, req.params.id],
    (err) => {
      if (err) return res.status(500).json({ erreur: err.message });
      res.json({ message: 'Stock mis à jour !' });
    });
});


// PRODUITS - Liste
app.get('/api/produits', (req, res) => {
  db.query('SELECT * FROM produits', (err, results) => {
    if (err) return res.status(500).json({ erreur: err.message });
    res.json(results);
  });
});

// STOCKS - Modifier
app.put('/api/produits/:id/stock', (req, res) => {
  const { stock } = req.body;
  db.query('UPDATE produits SET stock = ? WHERE id = ?',
    [stock, req.params.id],
    (err) => {
      if (err) return res.status(500).json({ erreur: err.message });
      res.json({ message: 'Stock mis à jour !' });
    });
});

// COMMANDES - Créer
app.post('/api/commandes', (req, res) => {
  const { utilisateur_id, total, produits, nom_livraison, telephone, adresse, mode_paiement } = req.body;
  db.query(
    'INSERT INTO commandes (utilisateur_id, total, nom_livraison, telephone, adresse, mode_paiement) VALUES (?, ?, ?, ?, ?, ?)',
    [utilisateur_id, total, nom_livraison, telephone, adresse, mode_paiement],
    (err, result) => {
      if (err) return res.status(500).json({ erreur: err.message });
      const commandeId = result.insertId;
      if (produits && produits.length > 0) {
        produits.forEach((p) => {
          db.query(
            'INSERT INTO commande_details (commande_id, produit_id, nom_produit, quantite, prix_unitaire) VALUES (?, ?, ?, ?, ?)',
            [commandeId, p.id || 0, p.nom || '', p.quantite || 1, p.prix]
          );
        });
      }
      res.json({ message: 'Commande créée !', commande_id: commandeId });
    }
  );
});

// MODIFIER PROFIL
app.put('/api/utilisateurs/:id', (req, res) => {
  const { nom, email, type_cheveux } = req.body;
  const sql = 'UPDATE utilisateurs SET nom = ?, email = ?, type_cheveux = ? WHERE id = ?';
  db.query(sql, [nom, email, type_cheveux, req.params.id], (err) => {
    if (err) return res.status(500).json({ erreur: err.message });
    res.json({ message: 'Profil mis à jour !' });
  });
});

// MODIFIER MOT DE PASSE
app.put('/api/utilisateurs/:id/password', async (req, res) => {
  const { ancien, nouveau } = req.body;
  db.query('SELECT * FROM utilisateurs WHERE id = ?', [req.params.id], async (err, results) => {
    if (err || results.length === 0)
      return res.status(404).json({ erreur: 'Utilisateur introuvable' });
    const user = results[0];
    const valide = await bcrypt.compare(ancien, user.mot_de_passe);
    if (!valide)
      return res.status(401).json({ erreur: 'Ancien mot de passe incorrect' });
    const hash = await bcrypt.hash(nouveau, 10);
    db.query('UPDATE utilisateurs SET mot_de_passe = ? WHERE id = ?',
      [hash, req.params.id], (err) => {
        if (err) return res.status(500).json({ erreur: err.message });
        res.json({ message: 'Mot de passe modifié !' });
      });
  });
});

// PANIER - Sauvegarder
app.post('/api/panier', (req, res) => {
  const { utilisateur_id, produit_id, nom, prix, image } = req.body;
  db.query('SELECT * FROM panier WHERE utilisateur_id = ? AND produit_id = ?',
    [utilisateur_id, produit_id],
    (err, results) => {
      if (results && results.length > 0) {
        db.query('UPDATE panier SET quantite = quantite + 1 WHERE utilisateur_id = ? AND produit_id = ?',
          [utilisateur_id, produit_id],
          (err) => {
            if (err) return res.status(500).json({ erreur: err.message });
            res.json({ message: 'Quantité mise à jour !' });
          });
      } else {
        db.query('INSERT INTO panier (utilisateur_id, produit_id, nom, prix, image) VALUES (?, ?, ?, ?, ?)',
          [utilisateur_id, produit_id, nom, prix, image],
          (err) => {
            if (err) return res.status(500).json({ erreur: err.message });
            res.json({ message: 'Produit ajouté au panier !' });
          });
      }
    });
});

// PANIER - Récupérer
app.get('/api/panier/:utilisateur_id', (req, res) => {
  db.query('SELECT * FROM panier WHERE utilisateur_id = ?',
    [req.params.utilisateur_id],
    (err, results) => {
      if (err) return res.status(500).json({ erreur: err.message });
      res.json(results);
    });
});

// PANIER - Supprimer un article
app.delete('/api/panier/:id', (req, res) => {
  db.query('DELETE FROM panier WHERE id = ?', [req.params.id], (err) => {
    if (err) return res.status(500).json({ erreur: err.message });
    res.json({ message: 'Article supprimé !' });
  });
});

// PANIER - Vider
app.delete('/api/panier/vider/:utilisateur_id', (req, res) => {
  db.query('DELETE FROM panier WHERE utilisateur_id = ?',
    [req.params.utilisateur_id],
    (err) => {
      if (err) return res.status(500).json({ erreur: err.message });
      res.json({ message: 'Panier vidé !' });
    });
});

// COMMANDE - Détails d'une commande
app.get('/api/commandes/details/:commande_id', (req, res) => {
  db.query(
    `SELECT cd.*, 
     COALESCE(p.nom, cd.nom_produit) as nom
     FROM commande_details cd
     LEFT JOIN produits p ON cd.produit_id = p.id
     WHERE cd.commande_id = ?`,
    [req.params.commande_id],
    (err, results) => {
      if (err) return res.status(500).json({ erreur: err.message });
      res.json(results);
    }
  );
});

// COMMANDES - Historique d'un utilisateur
app.get('/api/commandes/:utilisateur_id', (req, res) => {
  db.query(
    `SELECT c.*, 
     GROUP_CONCAT(cd.produit_id) as produit_ids,
     GROUP_CONCAT(cd.quantite) as quantites,
     GROUP_CONCAT(cd.prix_unitaire) as prix_unitaires
     FROM commandes c
     LEFT JOIN commande_details cd ON c.id = cd.commande_id
     WHERE c.utilisateur_id = ?
     GROUP BY c.id
     ORDER BY c.created_at DESC`,
    [req.params.utilisateur_id],
    (err, results) => {
      if (err) return res.status(500).json({ erreur: err.message });
      res.json(results);
    }
  );
});

// NOTIFICATIONS - Récupérer
app.get('/api/notifications/:utilisateur_id', (req, res) => {
  db.query(
    'SELECT * FROM notifications WHERE utilisateur_id = ? ORDER BY created_at DESC',
    [req.params.utilisateur_id],
    (err, results) => {
      if (err) return res.status(500).json({ erreur: err.message });
      res.json(results);
    }
  );
});

// NOTIFICATIONS - Marquer comme lu
app.put('/api/notifications/:id/lu', (req, res) => {
  db.query('UPDATE notifications SET lu = 1 WHERE id = ?',
    [req.params.id],
    (err) => {
      if (err) return res.status(500).json({ erreur: err.message });
      res.json({ message: 'Notification lue !' });
    }
  );
});

// NOTIFICATIONS - Tout marquer comme lu
app.put('/api/notifications/tout-lire/:utilisateur_id', (req, res) => {
  db.query(
    'UPDATE notifications SET lu = 1 WHERE utilisateur_id = ?',
    [req.params.utilisateur_id],
    (err) => {
      if (err) return res.status(500).json({ erreur: err.message });
      res.json({ message: 'Toutes notifications lues !' });
    }
  );
});

// Démarrage serveur
app.listen(3000, () => {
  console.log('Serveur Ayana Hair démarré sur http://localhost:3000');
});