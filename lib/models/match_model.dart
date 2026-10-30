class MatchModel {
  final String matchId;
  final String sport;
  final String league;
  final String leagueLogo;
  final String team1;
  final String team1Logo;
  final String team2;
  final String team2Logo;
  final String date;
  final String time;
  final String tvGuide;
  final String iframeUrl;

  MatchModel({
    required this.matchId,
    required this.sport,
    required this.league,
    required this.leagueLogo,
    required this.team1,
    required this.team1Logo,
    required this.team2,
    required this.team2Logo,
    required this.date,
    required this.time,
    required this.tvGuide,
    required this.iframeUrl,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: (json['MatchID'] ?? json['id'] ?? '').toString(),
      sport: (json['Sport'] ?? 'SPORTS').toString().trim(),
      league: (json['League'] ?? 'Live Match').toString().trim(),
      leagueLogo: (json['LeagueLogo'] ?? '').toString().trim(),
      team1: (json['Team1'] ?? 'Team 1').toString().trim(),
      team1Logo: (json['Team1Logo'] ?? '').toString().trim(),
      team2: (json['Team2'] ?? 'Team 2').toString().trim(),
      team2Logo: (json['Team2Logo'] ?? '').toString().trim(),
      date: (json['Date'] ?? '').toString().trim(),
      time: (json['Time'] ?? '').toString().trim(),
      tvGuide: (json['TVGuide'] ?? 'Live Stream').toString().trim(),
      iframeUrl: (json['IframeURL'] ?? json['iframeUrl'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MatchID': matchId,
      'Sport': sport,
      'League': league,
      'LeagueLogo': leagueLogo,
      'Team1': team1,
      'Team1Logo': team1Logo,
      'Team2': team2,
      'Team2Logo': team2Logo,
      'Date': date,
      'Time': time,
      'TVGuide': tvGuide,
      'IframeURL': iframeUrl,
    };
  }

  String get matchTitle {
    if (team2.isEmpty || team2.toLowerCase() == 'live streams') {
      return team1;
    }
    return '$team1 vs $team2';
  }

  String get normalizedSport {
    final s = sport.toUpperCase();
    if (s.contains('LIGUE') || s.contains('LALIGA') || s.contains('BUNDES') || s.contains('SERIE')) {
      return 'FOOTBALL';
    }
    if (s.contains('NBA') || s.contains('BASKETBALL')) {
      return 'BASKETBALL';
    }
    if (s.contains('MOTOR') || s.contains('F1')) {
      return 'MOTORSPORTS';
    }
    if (s.contains('NHL') || s.contains('HOCKEY')) {
      return 'ICE HOCKEY';
    }
    if (s.contains('CFB') || s.contains('NFL')) {
      return 'AMERICAN FOOTBALL';
    }
    return sport.replaceAll('-', ' ');
  }

  bool get hasStream => iframeUrl.isNotEmpty && iframeUrl.startsWith('http');
}

