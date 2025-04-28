import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/models/person.dart';

class ProfileHeader extends StatelessWidget {
  final Person person;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    Key? key,
    required this.person,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          // Avatar con botón de edición
          Stack(
            children: [
              // Avatar de perfil
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _getProfileImage(),
                child: person.personProfileImage == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
              
              // Botón de edición
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onEditPressed,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Nombre
          Text(
            person.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Email
          if (person.personEmail != null)
            _buildInfoRow(Icons.email_outlined, person.personEmail!),
          
          // Teléfono
          if (person.personCellphone != null)
            _buildInfoRow(Icons.phone_outlined, person.personCellphone!),
          
          // Dirección
          if (person.address != null)
            _buildInfoRow(Icons.location_on_outlined, person.address!),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (person.personProfileImage != null && person.personProfileImage!.isNotEmpty) {
      return CachedNetworkImageProvider(person.personProfileImage!);
    }
    return null;
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 32.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}