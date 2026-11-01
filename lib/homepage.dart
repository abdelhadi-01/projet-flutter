import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application multitaches',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Commence sur la page Accueil.
  int currIndex = 0;

  final List<Widget> pages = const [
    HomeView(),
    CartView(),
    ProfileView(),
    LoginView(),
  ];

  void changerPage(int index) {
    setState(() {
      currIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text(
          'Application multitaches',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
          ),
        ),
      ),

      // Affiche la page sélectionnée et conserve l'état des pages.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: IndexedStack(
            index: currIndex,
            children: pages,
          ),
        ),
      ),

      // Barre de navigation en bas.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currIndex,
        onTap: changerPage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Connexion',
          ),
        ],
      ),
    );
  }
}

// Page Accueil.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Page Accueil',
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

// Page Panier.
class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Page Panier',
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

// Page Profil.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Page Profil',
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}

// Page Connexion.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Page Connexion',
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}