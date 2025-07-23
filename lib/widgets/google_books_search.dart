
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleBooksSearch extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSelected;
  const GoogleBooksSearch({super.key, this.onSelected});

  @override
  State<GoogleBooksSearch> createState() => _GoogleBooksSearchState();
}

class _GoogleBooksSearchState extends State<GoogleBooksSearch> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  Future<void> _searchBooks() async {
    setState(() {
      _loading = true;
      _results = [];
    });

    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final url = 'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(q)}';
    final response = await http.get(Uri.parse(url));

    final decoded = json.decode(response.body);
    if (decoded['items'] != null) {
      setState(() {
        _results = (decoded['items'] as List)
            .map<Map<String, dynamic>>((item) {
          final volume = item['volumeInfo'] ?? {};
          return {
            'id': item['id'],
            'titulo': volume['title'] ?? '',
            'autor': (volume['authors'] != null && (volume['authors'] as List).isNotEmpty)
                ? (volume['authors'] as List).join(', ')
                : 'Desconocido',
            'thumbnail': (volume['imageLinks'] != null) ? volume['imageLinks']['thumbnail'] : null,
            'raw': item,
          };
        }).toList();
      });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  labelText: 'Buscar libro (título, autor, ISBN...)',
                ),
                onSubmitted: (_) => _searchBooks(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _searchBooks,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_results.isNotEmpty)
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_,__) => const Divider(),
              itemBuilder: (_, i) {
                final libro = _results[i];
                return ListTile(
                  leading: libro['thumbnail'] != null
                      ? Image.network(libro['thumbnail'], width: 40)
                      : const Icon(Icons.book_outlined),
                  title: Text(libro['titulo']),
                  subtitle: Text(libro['autor']),
                  onTap: () {
                    if (widget.onSelected != null) {
                      widget.onSelected!(libro);
                    }
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (widget.onSelected != null) {
                        widget.onSelected!(libro);
                      }
                    },
                  ),
                );
              },
            ),
          )
        else
          const Text('Sin resultados'),
      ],
    );
  }
}
