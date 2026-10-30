import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../theme/app_theme.dart';
import '../screens/player_screen.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({Key? key, required this.match}) : super(key: key);

  void _openPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(match: match),
      ),
    );
  }

  Widget _buildTeamLogo(String url, String teamName) {
    Widget imageContent;

    if (url.isEmpty) {
      imageContent = Center(
        child: Text(
          teamName.isNotEmpty ? teamName[0].toUpperCase() : 'S',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
      );
    } else {
      imageContent = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => Center(
          child: Text(
            teamName.isNotEmpty ? teamName[0].toUpperCase() : 'S',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

    // Logo with circular dedicated background (NO BORDER as requested)
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: imageContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = match.time.isNotEmpty ? match.time : 'LIVE';
    final leagueName = match.league.isNotEmpty ? match.league : match.sport;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkCard, // Solid background
        borderRadius: BorderRadius.circular(12), // Exact 12px radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openPlayer(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Top Centered Time Badge (League Box removed as requested)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.brandGreenSubtle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⏱ $timeStr',
                      style: const TextStyle(
                        color: AppTheme.brandGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Matchup Row (Home/Away removed, guaranteed non-overlapping)
                Row(
                  children: [
                    // Left Team: Logo + Single line name with ellipsis
                    Expanded(
                      child: Row(
                        children: [
                          _buildTeamLogo(match.team1Logo, match.team1),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.team1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center VS (No border)
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          color: AppTheme.brandGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    // Right Team: Single line name with ellipsis + Logo
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              match.team2,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildTeamLogo(match.team2Logo, match.team2),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
