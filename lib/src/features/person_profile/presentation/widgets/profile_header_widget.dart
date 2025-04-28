import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String? image;
  final String name;
  final String email;
  final VoidCallback onEditPressed;

  const ProfileHeaderWidget({
    super.key,
    this.image,
    required this.name,
    required this.email,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 24),
            child: Column(
              children: [
                // Imagen de perfil
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: image != null && image!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(image!),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                  ),
                  child: image == null || image!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                        )
                      : null,
                ),
                
                const SizedBox(height: 16),
                
                // Nombre del usuario
                Text(
                  name.isNotEmpty ? name : 'Nombre no definido',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 4),
                
                // Email del usuario
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black26,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Botón de editar perfil
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: Theme.of(context).primaryColor,
                onPressed: onEditPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}