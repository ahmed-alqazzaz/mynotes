import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynotes/helpers/loading/loading_screen_controller.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  LoadingScreenController? _controller;

  void show({
    required BuildContext context,
    required String text,
  }) {
    if (_controller != null) {
      _controller!.update(text);
    } else {
      _controller = _showOverlay(
        context: context,
        text: text,
      );
    }
  }

  void hide() {
    _controller?.close();
    _controller = null;
  }

  LoadingScreenController _showOverlay({
    required BuildContext context,
    required String text,
  }) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _text = StreamController<String>();
    _text.add(text);

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                  constraints: BoxConstraints(
                      maxWidth: size.width * 0.8,
                      maxHeight: size.height * 0.3,
                      minWidth: size.width * 0.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  //SafeArea(child: ,)
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 15),
                          const CircularProgressIndicator(),
                          const SizedBox(height: 30),
                          StreamBuilder(
                            stream: _text.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data as String,
                                  textAlign: TextAlign.center,
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        );
      },
    );

    state?.insert(overlayEntry);
    return LoadingScreenController(
      close: () {
        overlayEntry.remove();
        _text.close();
      },
      update: (String text) {
        _text.add(text);
      },
    );
  }
}
