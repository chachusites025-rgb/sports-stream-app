import 'dart:async';
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/match_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MatchModel> _allMatches = [];
  List<MatchModel> _filteredMatches = [];
  List<String> _sportsList = ['ALL'];
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

      final sportsSet = <String>{};
      for (final m in matches) {
        if (m.sport.isNotEmpty) sportsSet.add(m.sport.toUpperCase());
      }

      if (mounted) {
        setState(() {
          _allMatches = matches;
          _sportsList = ['ALL', ...sportsSet.toList()..sort()];
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
    }

    _filteredMatches = list;
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Futbol Libre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
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
        color: const Color(0xFF23191F),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildSportsRow() {
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
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _sportsList.length,
        itemBuilder: (context, i) {
          final s = _sportsList[i];
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
              decoration: const BoxDecoration(
                color: Color(0xFF23191F),
                shape: BoxShape.circle,
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

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1419),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Search teams, leagues, sports...',
            hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 18),
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
