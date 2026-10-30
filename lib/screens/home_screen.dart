import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/match_card.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MatchModel> _allMatches = [];
  List<MatchModel> _filteredMatches = [];
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadData(isBackground: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final matches = await ApiService.fetchSchedule();

      if (mounted) {
        setState(() {
          _allMatches = matches;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_allMatches.isEmpty) {
            _errorMessage = e.toString();
          }
        });
      }
    }
  }

  void _applyFilters() {
    List<MatchModel> list = _allMatches;

    // Filter by sport category
    if (_selectedCategory != 'ALL') {
      list = list.where((m) => m.sport.toUpperCase() == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((m) {
        return m.team1.toLowerCase().contains(q) ||
            m.team2.toLowerCase().contains(q) ||
            m.league.toLowerCase().contains(q) ||
            m.sport.toLowerCase().contains(q);
      }).toList();
    } else if (_selectedCategory == 'ALL' && list.length > 1) {
      // Exclude featured match from repeating in the list below when viewing ALL without search
      list = list.sublist(1);
    }

    _filteredMatches = list;
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.accentRed, Color(0xFFFFA502)],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Faizan Ali',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildCircleButton(Icons.chat_bubble_outline_rounded),
              const SizedBox(width: 8),
              Stack(
                children: [
                  _buildCircleButton(Icons.notifications_none_rounded),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentPink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.darkCardBorder),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildSportsRow() {
    final sportsSet = <String>{};
    for (final m in _allMatches) {
      if (m.sport.isNotEmpty) sportsSet.add(m.sport.toUpperCase());
    }
    final sportsList = ['ALL', ...sportsSet.toList()..sort()];

    final iconMap = {
      'ALL': '🏆',
      'LALIGA': '⚽',
      'FRENCH-LIGUE-1': '⚽',
      'BUNDESLIGA': '⚽',
      'BRAZIL-SERIE-A': '⚽',
      'NBA': '🏀',
      'MOTORSPORTS': '🏎️',
      'NHL': '🏒',
      'CFB': '🏈',
    };

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sportsList.length,
        itemBuilder: (context, i) {
          final s = sportsList[i];
          final isSelected = s == _selectedCategory;
          final icon = iconMap[s] ?? '⚡';
          final label = s == 'ALL' ? 'All Sports' : s.replaceAll('-', ' ');

          if (isSelected) {
            return Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentRed,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentRed.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = s;
                _applyFilters();
              });
            },
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.darkCardBorder),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 16)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard() {
    if (_allMatches.isEmpty) {
      return const SizedBox.shrink();
    }

    final match = _allMatches[0];

    return GestureDetector(
      onTap: () {
        if (match.hasStream) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlayerScreen(match: match)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppTheme.darkCardBorder),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Match', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                // Real League Logo & League Name
                Column(
                  children: [
                    if (match.leagueLogo.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: match.leagueLogo,
                        height: 22,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      match.league,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const Text('Live', style: TextStyle(color: AppTheme.accentPink, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Team 1
                Expanded(
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: match.team1Logo,
                        width: 50,
                        height: 50,
                        errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer, color: Colors.white, size: 38),
                      ),
                      const SizedBox(height: 6),
                      Text(match.team1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                      const Text('Home', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),

                // Center Score
                Column(
                  children: [
                    Text(match.time.isNotEmpty ? match.time : 'LIVE',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.liveGreen.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.liveGreen.withOpacity(0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.play_arrow_rounded, color: AppTheme.liveGreen, size: 14),
                          SizedBox(width: 4),
                          Text('LIVE NOW', style: TextStyle(color: AppTheme.liveGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),

                // Team 2
                Expanded(
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: match.team2Logo,
                        width: 50,
                        height: 50,
                        errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer, color: Colors.white, size: 38),
                      ),
                      const SizedBox(height: 6),
                      Text(match.team2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                      const Text('Away', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.darkCardBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Search teams, leagues, sports...',
            hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            icon: Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accentRed,
          onRefresh: () => _loadData(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopHeader()),
              SliverToBoxAdapter(child: _buildSportsRow()),
              SliverToBoxAdapter(child: _buildFeaturedCard()),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 14, 18, 4),
                  child: Text(
                    'Live Matches & Streams',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildSearchBox()),
              if (_isLoading && _allMatches.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.accentRed)),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return MatchCard(match: _filteredMatches[index]);
                    },
                    childCount: _filteredMatches.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
