import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:logger/logger.dart';

class VoiceInput extends StatefulWidget {
  final TextEditingController controller;
  final void Function(bool isListening) onListeningChanged;

  const VoiceInput({
    super.key,
    required this.controller,
    required this.onListeningChanged,
  });

  @override
  State<VoiceInput> createState() => VoiceInputState();
}

class VoiceInputState extends State<VoiceInput> {
  final SpeechToText _speech = SpeechToText();
  final Logger _logger = Logger();
  bool _isListening = false;
  bool _speechEnabled = false;
  String _currentLocaleId = 'es-MX';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onError: (error) => _logger.e('Error: ${error.errorMsg}'),
        onStatus: (status) => _logger.i('Status: $status'),
      );
      if (available) {
        var systemLocale = await _speech.systemLocale();
        setState(() {
          _currentLocaleId = systemLocale?.localeId ?? 'es-MX';
          _speechEnabled = true;
        });
      }
    } catch (e) {
      setState(() {
        _speechEnabled = false;
      });
    }
  }

  void _handleVoiceInput() {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (!_isListening) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (result) {
        setState(() {
          widget.controller.text = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            widget.onListeningChanged(_isListening);
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: _currentLocaleId,
      onDevice: false,
      listenMode: ListenMode.confirmation,
    );
    setState(() {
      _isListening = true;
      widget.onListeningChanged(_isListening);
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      widget.onListeningChanged(_isListening);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      onPressed: _handleVoiceInput,
    );
  }
}
