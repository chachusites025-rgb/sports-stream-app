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
  List<String> _sportsCategories = ['ALL'];
  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _autoRefreshTimer;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-refresh match schedule every 60 seconds
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
      final sports = ApiService.extractSports(matches);

      if (mounted) {
        setState(() {
          _allMatches = matches;
          _sportsCategories = sports;
          _lastUpdated = DateTime.now();
          _applyFilters();
          _isLoading = false;
          _errorMessage = null;
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
        if (isBackground) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Auto-update error: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _applyFilters() {
    List<MatchModel> list = _allMatches;

    // Filter by category
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

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search teams, leagues, sports...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
                ),
                onChanged: _onSearchChanged,
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.live_tv_rounded, color: AppTheme.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gamez Stream',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Live Sports Broadcast',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  _searchQuery = '';
                  _applyFilters();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Matches',
            onPressed: () => _loadData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chips bar
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sportsCategories.length,
              itemBuilder: (context, index) {
                final category = _sportsCategories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _onCategorySelected(category),
                    backgroundColor: AppTheme.darkSurface,
                    selectedColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.darkCardBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          // Matches header status bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentLiveRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_filteredMatches.length} Available Streams',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (_lastUpdated != null)
                  Text(
                    'Updated: ${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Content body
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _allMatches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryGreen),
            SizedBox(height: 16),
            Text(
              'Loading Live Sports Schedule...',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _allMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppTheme.accentLiveRed, size: 54),
              const SizedBox(height: 16),
              const Text(
                'Unable to Connect',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _loadData(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, color: AppTheme.textMuted, size: 48),
              const SizedBox(height: 12),
              const Text(
                'No Matches Found',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try selecting another sport or clear your search term.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'ALL';
                    _searchQuery = '';
                    _searchController.clear();
                    _applyFilters();
                  });
                },
                child: const Text('Reset All Filters', style: TextStyle(color: AppTheme.primaryGreen)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryGreen,
      backgroundColor: AppTheme.darkSurface,
      onRefresh: () => _loadData(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredMatches.length,
        itemBuilder: (context, index) {
          final match = _filteredMatches[index];
          return MatchCard(match: match);
        },
      ),
    );
  }
}