import 'package:flutter/material.dart';
import 'package:vidacoletiva/data/models/event_model.dart';
import 'package:vidacoletiva/data/models/media_model.dart';
import 'package:vidacoletiva/resources/assets/colour_pallete.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class EventPage extends StatelessWidget {
  final EventModel event;

  const EventPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          event.title ?? "",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: MediaQuery.of(context).size.height / 25,
          color: AppColors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title ?? "",
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                event.text ?? "",
              ),
              Text(event.description ?? ""),
              imageCarousel(context),
            ],
          ),
        ),
      ),
    );
  }

  Iterable<Widget> photoList() {
    final list = event.mediaModelList ?? [];
    return list.map((media) {
      return FutureBuilder<String>(
        future: media.getUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.network(
              snapshot.data!,
              fit: BoxFit.fitWidth,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    });
  }

  Widget imageCarousel(BuildContext context) {
    return CarouselSlider(
        options: CarouselOptions(
          height: 400,
          viewportFraction: 1,
          enableInfiniteScroll: false,
          clipBehavior: Clip.hardEdge,
        ),
        items: (event.mediaModelList ?? [])
            .map((e) => carouselImage(context, e))
            .toList());
  }

  Widget carouselImage(BuildContext context, MediaModel media) {
    return FutureBuilder<String>(
        future: media.getUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final url = snapshot.data!;
          final lower = url.toLowerCase();
          final isAudio = lower.endsWith('.mp3') ||
              lower.endsWith('.wav') ||
              lower.endsWith('.m4a') ||
              lower.endsWith('.ogg') ||
              lower.endsWith('.aac');
          if (isAudio) {
            // Retorna widget de player de áudio
            return Container(
              color: Colors.black12,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: AudioPlayerWidget(url: url),
            );
          }
          // Tenta carregar como imagem; se falhar (arquivo não é imagem válida),
          // faz fallback para o player de áudio.
          return Center(
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                // Fallback para áudio quando a URL não é uma imagem válida
                return Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16),
                  child: AudioPlayerWidget(url: url),
                );
              },
            ),
          );
        });
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  const AudioPlayerWidget({super.key, required this.url});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _durSub = _player.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });
    _posSub = _player.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
    _stateSub = _player.onPlayerStateChanged.listen((s) {
      setState(() => _playerState = s);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await _player.play(UrlSource(widget.url));
  }

  Future<void> _pause() async {
    await _player.pause();
  }

  Future<void> _seek(Duration pos) async {
    await _player.seek(pos);
  }

  String _format(Duration d) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final mm = twoDigits(d.inMinutes.remainder(60));
    final ss = twoDigits(d.inSeconds.remainder(60));
    return "$mm:$ss";
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;
    final max = (_duration.inMilliseconds > 0)
        ? _duration.inMilliseconds.toDouble()
        : 1.0;
    final value = _position.inMilliseconds.toDouble().clamp(0.0, max);

    // nome fixo para todos
    final fileName = 'audio';

    return Card(
      color: Colors.grey.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // centraliza verticalmente
          children: [
            // botão grande play/pause com cor do app
            GestureDetector(
              onTap: () {
                if (isPlaying) {
                  _pause();
                } else {
                  _play();
                }
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: Offset(0, 3))
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // info + slider
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment
                    .center, // centraliza conteúdo da coluna verticalmente
                children: [
                  // título fixo "audio"
                  Text(
                    fileName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // slider estilizado
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryOrange,
                      inactiveTrackColor:
                          AppColors.primaryOrange.withOpacity(0.25),
                      thumbColor: AppColors.primaryOrange,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayColor: AppColors.primaryOrange.withOpacity(0.12),
                    ),
                    child: Slider(
                      min: 0,
                      max: max,
                      value: value,
                      onChanged: (v) {
                        final seekTo = Duration(milliseconds: v.toInt());
                        _seek(seekTo);
                      },
                    ),
                  ),
                  // tempo atual / duração
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _format(_position),
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        _format(_duration),
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // removido ícone de "mais" (três pontinhos)
          ],
        ),
      ),
    );
  }
}
