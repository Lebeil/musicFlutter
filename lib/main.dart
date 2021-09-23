import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'musique.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MusicFlutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Musique> maListeDeMusiques = [
    Musique('Theme Swift', 'Coda', 'assets/un.jpg', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    Musique('Theme Flutter', 'Coda', 'assets/deux.jpg', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
  ];

  late AudioPlayer audioPlayer;
  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;
  late Musique maMusiqueActuelle;
  Duration position = const Duration(seconds: 0);
  Duration duree = const Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[index];
    configurationAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              elevation: 9,
              child: SizedBox(
                width: MediaQuery.of(context).size.height / 2.5,
                child: Image.asset(maMusiqueActuelle.imagePath),
              ),
            ),
            texteAvecStyle(maMusiqueActuelle.titre, 1.5),
            texteAvecStyle(maMusiqueActuelle.artiste, 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30, ActionMusic.rewind),
                bouton((statut == PlayerState.playing) ? Icons.pause : Icons.play_arrow, 45, (statut == PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),
                bouton(Icons.fast_forward, 30, ActionMusic.forward),
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texteAvecStyle(fromDuration(position), 0.8),
                texteAvecStyle(fromDuration(duree), 0.8)
              ],
            ),
            Slider(
              value: position.inSeconds.toDouble(),
              min: 0,
              max: 30,
              inactiveColor: Colors.white,
              activeColor: Colors.red,
              onChanged: (double d) {
                setState((){
                  Duration nouvelleDuration = Duration(seconds: d.toInt());
                  position = nouvelleDuration;
                });
              },
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action){
    return IconButton(
      iconSize: taille,
      color: Colors.white,
      icon: Icon(icone),
      onPressed: (){
        switch (action) {
          case ActionMusic.play:
            play();
            break;
          case ActionMusic.pause:
            pause();
            break;
          case ActionMusic.forward:
            forward();
            break;
          case ActionMusic.rewind:
            rewind();
            break;
        }
      },
    );
  }

  Text texteAvecStyle(String data, double scale) {
    return Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontStyle: FontStyle.italic
      ),
    );
  }

  void configurationAudio() {
    audioPlayer = AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
        (pos) => setState(()=> position = pos)
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state){
      if (state == AudioPlayerState.PLAYING){
        setState((){
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState((){
          statut = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print('erreur: $message');
      setState((){
        statut = PlayerState.stopped;
        duree = const Duration(seconds: 0);
        position = const Duration(seconds: 0);
      });
    }
    );
  }

  Future play() async {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward() {
    if (index == maListeDeMusiques.length - 1) {
      index = 0;
    } else {
      index++;
    }
    maMusiqueActuelle = maListeDeMusiques[index];
    audioPlayer.stop();
    configurationAudio();
    play();
  }

  String fromDuration(Duration duree) {
    print(duree);
    return duree.toString().split('.').first;
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.00);
    } else {
      if (index == 0) {
        index = maListeDeMusiques.length - 1;
      } else {
        index--;
      }
      maMusiqueActuelle = maListeDeMusiques[index];
      audioPlayer.stop();
      configurationAudio();
      play();
    }
  }
}

enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}

enum PlayerState {
  playing,
  stopped,
  paused
}