
class Libro {
  final String id;
  final String titulo;
  final String autor;
  final bool leido;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    this.leido = false,
  });

  Libro copyWith({bool? leido}) => Libro(
        id: id,
        titulo: titulo,
        autor: autor,
        leido: leido ?? this.leido,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'autor': autor,
        'leido': leido,
      };

  factory Libro.fromJson(Map<String, dynamic> json) => Libro(
        id: json['id'],
        titulo: json['titulo'],
        autor: json['autor'],
        leido: json['leido'] ?? false,
      );
}
