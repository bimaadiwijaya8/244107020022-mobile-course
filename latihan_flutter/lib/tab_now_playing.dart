import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TabNowPlaying extends StatefulWidget {
  const TabNowPlaying({super.key});

  @override
  State<TabNowPlaying> createState() => _TabNowPlayingState();
}

class _TabNowPlayingState extends State<TabNowPlaying> with SingleTickerProviderStateMixin {
  String _audioQuality = 'High (320kbps)';
  bool _isPlaying = false;
  bool _showLyrics = true;
  int _currentIndex = 0;

  final List<Map<String, String>> _playlist = [
    {
      'title': 'Night Changes',
      'artist': 'One Direction',
      'audioPath': 'mp3/One Direction - Night Changes.mp3',
      'coverPath': 'image/OIP.jpg',
      'lyrics': "Going out tonight, changes into something red\n"
          "Her mother doesn't like that kind of dress\n"
          "Everything she never had, she's showing off\n"
          "Driving too fast, moon is breaking through her hair\n"
          "She's headin' for something that she won't forget\n"
          "Having no regrets is all that she really wants\n"
          "We're only getting older, baby\n"
          "And I've been thinking about it lately\n"
          "Does it ever drive you crazy\n"
          "Just how fast the night changes?\n"
          "Everything that you've ever dreamed of\n"
          "Disappearing when you wake up\n"
          "But there's nothing to be afraid of\n"
          "Even when the night changes\n"
          "It will never change me and you\n"
          "Chasing her tonight, doubts are running 'round her head\n"
          "He's waiting, hides behind a cigarette\n"
          "Heart is beating loud, and she doesn't want it to stop\n"
          "Moving too fast, moon is lighting up her skin\n"
          "She's falling, doesn't even know it yet\n"
          "Having no regrets is all that she really wants\n"
          "We're only getting older, baby\n"
          "And I've been thinking about it lately\n"
          "Does it ever drive you crazy\n"
          "Just how fast the night changes?\n"
          "Everything that you've ever dreamed of\n"
          "Disappearing when you wake up\n"
          "But there's nothing to be afraid of\n"
          "Even when the night changes\n"
          "It will never change me and you\n"
          "Going out tonight, changes into something red\n"
          "Her mother doesn't like that kind of dress\n"
          "Reminds her of the missing piece of innocence she lost\n"
          "We're only getting older, baby\n"
          "And I've been thinking about it lately\n"
          "Does it ever drive you crazy\n"
          "Just how fast the night changes?\n"
          "Everything that you've ever dreamed of\n"
          "Disappearing when you wake up\n"
          "But there's nothing to be afraid of\n"
          "Even when the night changes\n"
          "It will never change, baby\n"
          "It will never change, baby\n"
          "It will never change me and you"
    },
    {
      'title': 'Tetap Berdiri',
      'artist': 'Unknown',
      'audioPath': 'mp3/tetap-berdiri.mp3',
      'coverPath': 'lirik',
      'lyrics': "TETAP BERDIRI\n\n"
          "Malam kembali tanpa suara\n"
          "Membawa pikiranku ke tempat yang sama\n"
          "Langkahku berat, arah tak pasti\n"
          "Namun ku tahu, aku belum berhenti\n\n"
          "Bayangan masa lalu mengejar\n"
          "Menarikku kembali ke dasar\n"
          "Berkali-kali hampir menyerah\n"
          "Tapi suara kecil berkata, “Jangan kalah”\n\n"
          "Biar dunia terus menghantam\n"
          "Biar semua terasa tenggelam\n"
          "Ku genggam sisa keberanian\n"
          "Dan ku lawan ketakutan\n\n"
          "AKU MASIH DI SINI!\n"
          "Walau hancur berkali-kali\n"
          "AKU TAKKAN PERGI!\n"
          "Meski luka belum sembuh lagi\n\n"
          "Biar langit runtuh di atas kepala\n"
          "Biar jalan ini penuh air mata\n"
          "Selama jantungku masih berdetak\n"
          "AKU AKAN TETAP BERDIRI!\n\n"
          "Mereka bilang aku takkan mampu\n"
          "Mereka tak tahu apa yang ku lalui\n"
          "Senyum yang terlihat baik-baik saja\n"
          "Menyimpan perang yang tak pernah mereka baca\n\n"
          "Ku pernah kehilangan arah\n"
          "Ku pernah membenci langkahku sendiri\n"
          "Namun setiap luka yang membekas\n"
          "Mengajarkanku untuk kembali berdiri\n\n"
          "Biar dunia terus menghantam\n"
          "Biar semua terasa tenggelam\n"
          "Ku genggam sisa keberanian\n"
          "Dan ku lawan ketakutan\n\n"
          "AKU MASIH DI SINI!\n"
          "Walau hancur berkali-kali\n"
          "AKU TAKKAN PERGI!\n"
          "Meski luka belum sembuh lagi\n\n"
          "Biar langit runtuh di atas kepala\n"
          "Biar jalan ini penuh air mata\n"
          "Selama jantungku masih berdetak\n"
          "AKU AKAN TETAP BERDIRI!\n\n"
          "Jika esok tak membawa jawaban\n"
          "Jika harapan kembali menghilang\n"
          "Aku akan mencari jalanku sendiri\n"
          "Walau harus berjalan seorang diri\n\n"
          "AKU MASIH DI SINI!\n"
          "DENGAR SUARAKU SEKARANG!\n"
          "AKU TAKKAN PERGI!\n"
          "TAK PEDULI SEBERAPA DALAM!\n\n"
          "Biar dunia runtuh dan membakar semua\n"
          "Biar mereka bilang aku takkan bisa\n"
          "Selama jantungku masih berdetak\n"
          "SELAMA NAFASKU BELUM BERHENTI—\n\n"
          "AKU AKAN TETAP BERDIRI!\n\n"
          "Dan jika malam kembali datang\n"
          "Aku takkan lagi menghilang\n"
          "Karena setelah semua yang terjadi\n"
          "Aku tahu...\n"
          "aku masih berdiri."
    }
  ];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    
    // Konfigurasi audioplayer untuk mengambil file dari luar folder 'assets' (yaitu folder 'mp3')
    _audioPlayer.audioCache = AudioCache(prefix: '');
    _audioPlayer.setSource(AssetSource(_playlist[_currentIndex]['audioPath']!));

    _audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        if (_currentIndex < _playlist.length - 1) {
          setState(() {
            _currentIndex++;
          });
          _audioPlayer.setSource(AssetSource(_playlist[_currentIndex]['audioPath']!));
          _audioPlayer.resume();
        } else {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
        }
      }
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280.0,
          pinned: true,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'album_cover',
                  child: _playlist[_currentIndex]['coverPath'] == 'lirik'
                      ? Container(
                          color: Colors.indigo.shade400,
                          child: const Center(
                            child: Icon(Icons.lyrics, size: 150, color: Colors.white),
                          ),
                        )
                      : Image.asset(
                          _playlist[_currentIndex]['coverPath']!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.indigo.shade300,
                            child: const Center(
                              child: Icon(Icons.music_note, size: 100, color: Colors.white),
                            ),
                          ),
                        ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black87, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Text(_playlist[_currentIndex]['title']!, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Text(_playlist[_currentIndex]['artist']!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text('Audio Quality: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      DropdownButton<String>(
                        value: _audioQuality,
                        items: ['High (320kbps)', 'Medium (128kbps)', 'Low (64kbps)']
                            .map((String q) => DropdownMenuItem(value: q, child: Text(q)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            if (val != null) _audioQuality = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(_formatDuration(_position)),
                      Expanded(
                        child: Slider(
                          min: 0.0,
                          max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                          value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0),
                          onChanged: (val) async {
                            final position = Duration(seconds: val.toInt());
                            await _audioPlayer.seek(position);
                          },
                        ),
                      ),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: const Icon(Icons.shuffle, size: 28), color: Colors.grey, onPressed: () => _showMessage('Shuffle')),
                      const SizedBox(width: 16),
                      IconButton(icon: const Icon(Icons.skip_previous, size: 36), onPressed: () async {
                        if (_currentIndex > 0) {
                          setState(() {
                            _currentIndex--;
                          });
                          await _audioPlayer.setSource(AssetSource(_playlist[_currentIndex]['audioPath']!));
                          if (_isPlaying) {
                            await _audioPlayer.resume();
                          }
                          _showMessage('Playing ${_playlist[_currentIndex]['title']}');
                        } else {
                          _showMessage('First song in playlist');
                        }
                      }),
                      const SizedBox(width: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: _isPlaying ? Colors.redAccent : Colors.indigo,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              key: ValueKey<bool>(_isPlaying),
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          onPressed: () async {
                            if (_isPlaying) {
                              await _audioPlayer.pause();
                            } else {
                              await _audioPlayer.resume();
                            }
                            
                            setState(() {
                              _isPlaying = !_isPlaying;
                            });
                            _showMessage(_isPlaying ? 'Playing ${_playlist[_currentIndex]['title']}' : 'Paused');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(icon: const Icon(Icons.skip_next, size: 36), onPressed: () async {
                        if (_currentIndex < _playlist.length - 1) {
                          setState(() {
                            _currentIndex++;
                          });
                          await _audioPlayer.setSource(AssetSource(_playlist[_currentIndex]['audioPath']!));
                          if (_isPlaying) {
                            await _audioPlayer.resume();
                          }
                          _showMessage('Playing ${_playlist[_currentIndex]['title']}');
                        } else {
                          _showMessage('Last song in playlist');
                        }
                      }),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(_showLyrics ? Icons.lyrics : Icons.lyrics_outlined, size: 28),
                        color: _showLyrics ? Colors.indigo : Colors.grey,
                        onPressed: () {
                          setState(() {
                            _showLyrics = !_showLyrics;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  AnimatedOpacity(
                    opacity: _showLyrics ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: Text(
                      _playlist[_currentIndex]['lyrics']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
