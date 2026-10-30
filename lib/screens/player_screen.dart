import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final MatchModel match;

  const PlayerScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;
  bool _isFullScreen = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Mobile; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                if (progress >= 95) {
                  _isLoading = false;
                }
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only report main frame errors
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _errorMessage = 'Failed to load stream. Please check connection.';
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            // Block ad redirects, store redirects, and unwanted schemes
            if (uri.scheme == 'intent' ||
                uri.scheme == 'market' ||
                uri.scheme == 'appcenter' ||
                request.url.contains('doubleclick') ||
                request.url.contains('popads') ||
                request.url.contains('acscdn') ||
                request.url.contains('visariomedia')) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    if (widget.match.hasStream) {
      controller.loadRequest(Uri.parse(widget.match.iframeUrl));
    } else {
      _errorMessage = 'No stream URL available for this match.';
    }

    _controller = controller;
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _openExternalBrowser() async {
    final uri = Uri.parse(widget.match.iframeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open browser for this URL.')),
        );
      }
    }
  }

  void _shareStream() {
    Share.share(
      'Watch ${widget.match.matchTitle} live on Sports Stream!\n${widget.match.iframeUrl}',
      subject: 'Live Stream: ${widget.match.matchTitle}',
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Widget _buildTeamBadge(String url, String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (url.isNotEmpty)
          CachedNetworkImage(
            imageUrl: url,
            width: 44,
            height: 44,
            errorWidget: (context, _, __) => const Icon(Icons.sports_soccer, color: Colors.white70, size: 36),
          )
        else
          const Icon(Icons.sports_soccer, color: Colors.white70, size: 36),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      // Fullscreen Player View
      return WillPopScope(
        onWillPop: () async {
          _toggleFullScreen();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: WebViewWidget(controller: _controller),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    onPressed: _toggleFullScreen,
                    child: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.match.matchTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Fullscreen Mode',
            icon: const Icon(Icons.fullscreen_rounded, color: AppTheme.primaryGreen),
            onPressed: _toggleFullScreen,
          ),
          IconButton(
            tooltip: 'Reload Stream',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _controller.reload();
            },
          ),
          IconButton(
            tooltip: 'Share Stream',
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareStream,
          ),
          PopupMenuButton<String>(
            color: AppTheme.darkCard,
            onSelected: (val) {
              if (val == 'browser') _openExternalBrowser();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'browser',
                child: Row(
                  children: [
                    Icon(Icons.open_in_browser_rounded, size: 18, color: AppTheme.primaryGreen),
                    SizedBox(width: 8),
                    Text('Open in Browser', style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stream Video Container
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child: WebViewWidget(controller: _controller),
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppTheme.primaryGreen),
                          const SizedBox(height: 12),
                          Text(
                            'Loading stream... $_loadingProgress%',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_errorMessage != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.9),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppTheme.accentLiveRed, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                                _isLoading = true;
                              });
                              _controller.reload();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Fullscreen floating button overlay
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 22),
                      onPressed: _toggleFullScreen,
                      tooltip: 'Toggle Fullscreen',
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress / 100.0,
              backgroundColor: AppTheme.darkSurface,
              color: AppTheme.primaryGreen,
              minHeight: 3,
            ),

          // Scrollable Match Info & Quick Action Cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Match Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkCardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentLiveRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.accentLiveRed.withOpacity(0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(radius: 4, backgroundColor: AppTheme.accentLiveRed),
                                SizedBox(width: 6),
                                Text(
                                  'LIVE BROADCAST',
                                  style: TextStyle(
                                    color: AppTheme.accentLiveRed,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTeamBadge(widget.match.team1Logo, widget.match.team1)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(child: _buildTeamBadge(widget.match.team2Logo, widget.match.team2)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.darkCardBorder),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailItem(Icons.sports, 'Sport', widget.match.sport),
                          _buildDetailItem(Icons.emoji_events_rounded, 'League', widget.match.league),
                          _buildDetailItem(Icons.access_time_rounded, 'Time', widget.match.time),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Controls and Guide Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkCardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppTheme.primaryCyan, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Streaming Instructions',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Tap the Play button inside the player window above.\n'
                        '• For the best viewing experience, tap the fullscreen icon to switch to theater mode.\n'
                        '• If the in-app player experiences buffering, use "Open in Browser" below.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryCyan,
                                side: const BorderSide(color: AppTheme.primaryCyan),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _openExternalBrowser,
                              icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                              label: const Text('Open in Browser'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _controller.reload(),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Reload Stream'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : '-',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
