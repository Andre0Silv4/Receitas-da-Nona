import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(ReceitasApp());

class ReceitasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(139, 0, 170, 255),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF00AA),
            foregroundColor: Color(0xFFFFAA00),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(199, 170, 0, 255),
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFAAFF00),
          ),
          centerTitle: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFAAFF00),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFFFFAA00),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: ReceitasPage(),
    );
  }
}

class ReceitasPage extends StatefulWidget {
  @override
  _ReceitasPageState createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  List<Map<String, String>> receitas = [];

  @override
  void initState() {
    super.initState();
    _loadReceitas();
  }

_loadReceitas() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? receitasString = prefs.getString('receitas');

  setState(() {
    receitas.addAll(_receitasPreDefinidas());
  });

  _salvarReceitas();
}

  List<Map<String, String>> _receitasPreDefinidas() {
    return [
      {
        'titulo': 'Bolo de Chocolate',
        'ingredientes': '- 3 ovos\n- 2 xícaras de farinha\n- 1 xícara de açúcar\n- 1 xícara de chocolate em pó',
        'modoPreparo': '1. Misture todos os ingredientes.\n2. Asse por 40 minutos.'
      },
      {
        'titulo': 'Lasanha Quatro Queijos',
        'ingredientes': '- Massa para lasanha\n- Molho branco\n- Queijo mussarela\n- Queijo parmesão\n- Queijo gorgonzola\n- Queijo prato',
        'modoPreparo': '1. Monte a lasanha alternando camadas de massa e queijo.\n2. Asse por 35 minutos.'
      },
      {
        'titulo': 'Bolinho de Chuva',
        'ingredientes': '- 2 ovos\n- 2 xícaras de farinha\n- 1 xícara de açúcar\n- 1 colher de fermento em pó\n- Óleo para fritar',
        'modoPreparo': '1. Misture todos os ingredientes e frite pequenas porções de massa até dourar.'
      },
    ];
  }

  _salvarReceitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('receitas', json.encode(receitas));
  }

  _adicionarReceita(String titulo, String ingredientes, String modoPreparo) {
    setState(() {
      receitas.add({
        'titulo': titulo,
        'ingredientes': _formatarIngredientes(ingredientes),
        'modoPreparo': modoPreparo,
      });
    });
    _salvarReceitas();
  }

  // Função para formatar os ingredientes
  String _formatarIngredientes(String ingredientes) {
    List<String> listaIngredientes = ingredientes.split(RegExp(r'[,\n]')).map((item) => item.trim()).toList();
    return listaIngredientes.map((item) => "- $item").join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receitas da Nona'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdicionarReceitaPage(
                    onSave: _adicionarReceita,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: receitas.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(receitas[index]['titulo']!),
              subtitle: Text('Ingredientes: ${receitas[index]['ingredientes']!}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalhesReceitaPage(
                      titulo: receitas[index]['titulo']!,
                      ingredientes: receitas[index]['ingredientes']!,
                      modoPreparo: receitas[index]['modoPreparo']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetalhesReceitaPage extends StatelessWidget {
  final String titulo;
  final String ingredientes;
  final String modoPreparo;

  DetalhesReceitaPage({
    required this.titulo,
    required this.ingredientes,
    required this.modoPreparo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingredientes:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(ingredientes, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              'Modo de Preparo:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(modoPreparo, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class AdicionarReceitaPage extends StatefulWidget {
  final Function(String, String, String) onSave;

  AdicionarReceitaPage({required this.onSave});

  @override
  _AdicionarReceitaPageState createState() => _AdicionarReceitaPageState();
}

class _AdicionarReceitaPageState extends State<AdicionarReceitaPage> {
  final _tituloController = TextEditingController();
  final _ingredientesController = TextEditingController();
  final _modoPreparoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Receita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _ingredientesController,
              decoration: InputDecoration(labelText: 'Ingredientes (separe por vírgulas ou quebre linhas)'),
              maxLines: 3,
            ),
            TextField(
              controller: _modoPreparoController,
              decoration: InputDecoration(labelText: 'Modo de Preparo'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_tituloController.text.isNotEmpty &&
                    _ingredientesController.text.isNotEmpty &&
                    _modoPreparoController.text.isNotEmpty) {
                  widget.onSave(
                    _tituloController.text,
                    _ingredientesController.text,
                    _modoPreparoController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Salvar Receita'),
            ),
          ],
        ),
      ),
    );
  }
}
