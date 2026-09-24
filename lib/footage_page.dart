import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'menu_page.dart'; 

void main() {
  runApp(MaterialApp(home: FootagePage()));
}

class FootagePage extends StatefulWidget {
  @override
  _FootagePageState createState() => _FootagePageState();
}

class _FootagePageState extends State<FootagePage> {
  
  final String rtspUrl = 'rtsp://admin:YAPDNK@192.168.8.137/h264/ch1/main/av_stream';
  late VlcPlayerController _vlcController;

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      rtspUrl,
      hwAcc: HwAcc.auto,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _vlcController.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenCamera(rtspUrl: rtspUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuPage(),
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Color(0xFFF2F2F2),
        elevation: 0,
        foregroundColor: Colors.black,
        title: Center(
          child: Text("Live Footage", style: TextStyle(fontWeight: FontWeight.normal)),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [SizedBox(width: 48)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: _openFullscreen,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: VlcPlayer(
                    controller: _vlcController,
                    aspectRatio: 16 / 9,
                    placeholder: Center(child: CircularProgressIndicator()),
                  ),
                ),
                Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 48),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Text(
                    "Security Camera", // Change this to whatever general name you want
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FullscreenCamera extends StatefulWidget {
  final String rtspUrl;
  const FullscreenCamera({required this.rtspUrl});

  @override
  State<FullscreenCamera> createState() => _FullscreenCameraState();
}

class _FullscreenCameraState extends State<FullscreenCamera> {
  late VlcPlayerController _fullscreenController;

  @override
  void initState() {
    super.initState();
    _fullscreenController = VlcPlayerController.network(
      widget.rtspUrl,
      hwAcc: HwAcc.auto,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _fullscreenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String cameraName = "Security Camera";
    String dateTime = "${DateTime.now().toLocal()}";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: VlcPlayer(
              controller: _fullscreenController,
              aspectRatio: 16 / 9,
              placeholder: Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 40),
            ),
          ),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  cameraName,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                dateTime,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
