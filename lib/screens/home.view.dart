import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tableau de bord',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bienvenue dans votre application !',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Statistiques de démonstration.
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 600 ? 4 : 2;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  statisticCard(
                    width: cardWidth,
                    title: 'Utilisateurs',
                    value: '120',
                    icon: Icons.people,
                    color: Colors.indigo,
                  ),
                  statisticCard(
                    width: cardWidth,
                    title: 'Commandes',
                    value: '45',
                    icon: Icons.shopping_cart,
                    color: Colors.orange,
                  ),
                  statisticCard(
                    width: cardWidth,
                    title: 'Livraisons',
                    value: '32',
                    icon: Icons.local_shipping,
                    color: Colors.green,
                  ),
                  statisticCard(
                    width: cardWidth,
                    title: 'En attente',
                    value: '13',
                    icon: Icons.pending_actions,
                    color: Colors.pink,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          const Text(
            'Activités récentes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFE8EAF6),
                    child: Icon(
                      Icons.shopping_bag,
                      color: Colors.indigo,
                    ),
                  ),
                  title: Text('Nouvelle commande'),
                  subtitle: Text('Commande #001 créée'),
                  trailing: Text('10 min'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  title: Text('Livraison terminée'),
                  subtitle: Text('Commande #002 livrée'),
                  trailing: Text('30 min'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(
                      Icons.person_add,
                      color: Colors.orange,
                    ),
                  ),
                  title: Text('Nouvel utilisateur'),
                  subtitle: Text('Un nouveau compte a été créé'),
                  trailing: Text('1 h'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Données de démonstration',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget statisticCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}