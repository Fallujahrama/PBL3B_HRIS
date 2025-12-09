import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/position.dart';
import '../services/position_api.dart';
import '../widgets/position_tile.dart';
import '../../../widgets/app_drawer.dart';

class PositionScreen extends StatefulWidget {
  const PositionScreen({super.key});

  @override
  State<PositionScreen> createState() => _PositionScreenState();
}

class _PositionScreenState extends State<PositionScreen> {
  late Future<List<Position>> futureData;

  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 0 && _isFabVisible) {
      setState(() {
        _isFabVisible = false;
      });
    } else if (_scrollController.offset <= 0 && !_isFabVisible) {
      setState(() {
        _isFabVisible = true;
      });
    }
  }

  void _loadData() {
    setState(() {
      futureData = PositionApi.getPositions();
    });
  }

  void _navigateToForm([Position? position]) async {
    final result = await context.push('/positions/form', extra: position);

    if (result == true) {
      _loadData();
    }
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<Position>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Belum ada data posisi."));
        }

        final data = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16).copyWith(bottom: 80), 
            itemCount: data.length,
            itemBuilder: (context, index) {
              return PositionTile(
                item: data[index],
                onTap: () => _navigateToForm(data[index]),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFFF5F6F8), 
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          "Master Posisi",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black), 
      ),
      body: _buildBody(context),

      floatingActionButton: AnimatedOpacity(
        opacity: _isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () => _navigateToForm(),
          child: const Icon(Icons.add, color: Colors.white), 
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      
    );
  }
}