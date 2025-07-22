import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final bool isRead;
  final VoidCallback? onMarkRead;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.isRead,
    this.onMarkRead,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 90,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 90,
                        height: 120,
                        color: AdminLteColors.light,
                        child: Icon(Icons.book, size: 50, color: AdminLteColors.primary),
                      ),
                    )
                  : Container(
                      width: 90,
                      height: 120,
                      color: AdminLteColors.light,
                      child: Icon(Icons.book, size: 50, color: AdminLteColors.primary),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.sourceSans3(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AdminLteColors.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      author,
                      style: GoogleFonts.sourceSans3(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: AdminLteColors.gray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (isRead)
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: AdminLteColors.accent, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                "Leído",
                                style: GoogleFonts.sourceSans3(
                                  color: AdminLteColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (!isRead && onMarkRead != null)
                          ElevatedButton.icon(
                            onPressed: onMarkRead,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text("Marcar como leído"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminLteColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: GoogleFonts.sourceSans3(fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
