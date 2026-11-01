import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String nom = 'Abdelhadi Elidrissi';
  String email = 'abdelhadi@example.com';

  Future<void> modifierProfil() async {
    final nomController = TextEditingController(text: nom);
    final emailController = TextEditingController(text: email);
    final formKey = GlobalKey<FormState>();

    final resultat = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifier le profil'),
          content: SingleChildScrollView(
                      ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, {
                    'nom': nomController.text.trim(),
                    'email': emailController.text.trim(),
                  });
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (!mounted || resultat == null) return;

    setState(() {
      nom = resultat['nom']!;
      email = resultat['email']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.brown,
              child: Icon(
                Icons.person,
                size: 75,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              nom,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: modifierProfil,
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}