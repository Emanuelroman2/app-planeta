import 'package:flutter/material.dart';
import 'package:myapp/modelos/planeta.dart';
import 'package:myapp/controle/controle_planeta.dart';
import 'package:myapp/telas/tela_planeta.dart';
import 'package:myapp/telas/tela_detalhes_planeta.dart';
import 'package:flutter/material.dart';
import 'package:myapp/modelos/planeta.dart';

class TelaDetalhesPlaneta extends StatelessWidget {
  final Planeta planeta;

  const TelaDetalhesPlaneta({super.key, required this.planeta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Planeta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${planeta.nome}', style: const TextStyle(fontSize: 18)),
            Text('Apelido: ${planeta.apelido ?? "Não informado"}', style: const TextStyle(fontSize: 18)),
            Text('Distância do Sol: ${planeta.distancia} UA', style: const TextStyle(fontSize: 18)),
            Text('Tamanho: ${planeta.tamanho} km', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planetas',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MyHomePage(title: 'Aplicativo - Planeta'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ControlePlaneta _controle = ControlePlaneta();
  List<Planeta> planetas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPlanetas();
  }

  Future<void> _carregarPlanetas() async {
    final lista = await _controle.lerPlanetas();
    setState(() {
      planetas = lista;
      _carregando = false;
    });
  }

  void _incluirPlaneta(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaPlaneta(
          isIncluir: true,
          planeta: Planeta.vazio(),
          onFinalizado: _carregarPlanetas,
        ),
      ),
    );
  }

  void _alterarPlaneta(BuildContext context, Planeta planeta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaPlaneta(
          isIncluir: false,
          planeta: planeta,
          onFinalizado: _carregarPlanetas,
        ),
      ),
    );
  }

  Future<void> _excluirPlaneta(int? id) async {
    if (id == null) return;
    
    // Confirmação antes de excluir
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Planeta'),
        content: const Text('Você tem certeza de que deseja excluir este planeta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _controle.excluirPlaneta(id);
      _carregarPlanetas();
    }
  }

  void _verDetalhesPlaneta(BuildContext context, Planeta planeta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDetalhesPlaneta(planeta: planeta),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : planetas.isEmpty
              ? const Center(child: Text("Nenhum planeta cadastrado."))
              : ListView.builder(
                  itemCount: planetas.length,
                  itemBuilder: (context, index) {
                    final planeta = planetas[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(Icons.public, color: Colors.deepPurple[700]),
                        title: Text(planeta.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Apelido: ${planeta.apelido ?? "Sem apelido"}\nDistância do Sol: ${planeta.distancia} UA\nTamanho: ${planeta.tamanho} km"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _alterarPlaneta(context, planeta),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _excluirPlaneta(planeta.id),
                            ),
                          ],
                        ),
                        onTap: () => _verDetalhesPlaneta(context, planeta), // Navega para a tela de detalhes
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _incluirPlaneta(context),
        tooltip: 'Adicionar Planeta',
        child: const Icon(Icons.add),
      ),
    );
  }
}
