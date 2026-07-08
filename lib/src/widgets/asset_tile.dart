import 'package:flutter/material.dart';

import '../models/asset_model.dart';
import 'app_card.dart';

class AssetTile extends StatelessWidget {
  const AssetTile({super.key, required this.asset, required this.onTap});

  final AssetModel asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE3F3EF),
            child: Text(
              '${asset.health}',
              style: const TextStyle(
                color: Color(0xFF1B6B5F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asset.code,
                  style: const TextStyle(color: Color(0xFF60746F)),
                ),
                Text(
                  '${asset.location} - ${asset.status}',
                  style: const TextStyle(color: Color(0xFF60746F)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_left),
        ],
      ),
    );
  }
}
