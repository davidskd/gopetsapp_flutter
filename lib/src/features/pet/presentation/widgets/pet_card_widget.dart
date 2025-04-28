import 'package:flutter/material.dart';
// Removed import 'package:uywapets_flutter/src/theme/uywa_colors.dart'

import '../../domain/models/pet_dto.dart';

class PetCard extends StatelessWidget {
  final PetDto pet;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PetCard({
    super.key,
    required this.pet,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Find the principal image URL (logic remains the same)
    String? principalImageUrl;
    if (pet.petImgs != null && pet.petImgs!.isNotEmpty) {
      try {
        final principalImage = pet.petImgs!.firstWhere(
          (img) => img.petImgIsPrincipal == true,
          orElse: () => pet.petImgs!.first, // Fallback
        );
        principalImageUrl = principalImage.petImgUrl;
      } catch (e) {
        print('Error finding principal image: $e');
        principalImageUrl = null;
      }
    }

    // Format age string
    String ageString = 'Edad desconocida';
    if (pet.petOld != null) {
      ageString = '${pet.petOld} ${pet.petTypeOld ?? (pet.petOld == 1 ? 'año' : 'años')}';
      // Handle "meses" if petTypeOld provides it
      if (pet.petTypeOld?.toLowerCase() == 'meses') {
         ageString = '${pet.petOld} ${pet.petOld == 1 ? 'mes' : 'meses'}';
      }
    }


    return Card(
      clipBehavior: Clip.antiAlias, // Use Clip.antiAlias for rounded corners on the image
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap, // Use onTap for the whole card or specifically for the button later
        child: Row(
          children: [
            // Left side: Image
            SizedBox(
              width: 100, // Adjust width as needed
              height: 130, // Adjust height as needed
              child: ClipRRect( // Clip the image with rounded corners if needed, Card already does this
                // borderRadius: BorderRadius.circular(16.0), // Match Card's radius if needed separately
                child: principalImageUrl != null && principalImageUrl.isNotEmpty
                    ? Image.network(
                        principalImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                                child: Icon(Icons.pets, size: 40, color: Colors.grey)),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                            child: Icon(Icons.pets, size: 40, color: Colors.grey)),
                      ),
              ),
            ),

            // Right side: Info and Actions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween to push button down
                  children: [
                    // Top Section: Name, Icons, Breed, Age
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row for Name and Icons
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align top
                          children: [
                            // Pet Name (takes available space)
                            Expanded(
                              child: Text(
                                pet.petName ?? 'Nombre no disponible',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Edit/Delete Icons (aligned right)
                            //if (onEdit != null || onDelete != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //if (onEdit != null)
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        color: Colors.blue,
                                        onPressed: onEdit,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Editar',
                                      ),
                                    ),
                                  //if (onEdit != null && onDelete != null)
                                    const SizedBox(width: 8),
                                  //if (onDelete != null)
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18),
                                        color: Colors.red,
                                        onPressed: onDelete,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Eliminar',
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 6), // Space below name/icons row
                        // Breed
                        Text(
                          pet.petBreedName ?? 'Raza desconocida',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4), // Space between breed and age
                        // Age
                        Text(
                          ageString, // Use the formatted age string
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Bottom: "Empezar" Button (pushed down by MainAxisAlignment.spaceBetween)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        ),
                        child: const Text('Empezar'),
                      ),
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