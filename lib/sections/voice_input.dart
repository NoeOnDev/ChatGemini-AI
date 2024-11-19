import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:logger/logger.dart';

class VoiceInput extends StatefulWidget {
  final TextEditingController controller;
  final void Function(bool isListening) onListeningChanged;
  final String language;

  const VoiceInput({
    super.key,
    required this.controller,
    required this.onListeningChanged,
    required this.language,
  });

  @override
  State<VoiceInput> createState() => VoiceInputState();
}

class VoiceInputState extends State<VoiceInput> {
  final SpeechToText _speech = SpeechToText();
  final Logger _logger = Logger();
  bool _isListening = false;
  bool _speechEnabled = false;

  String get _selectedLocaleId =>
      widget.language == 'Spanish' ? 'es-MX' : 'en-US';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _errorListener(SpeechRecognitionError error) {
    _logger.e('Error: ${error.errorMsg}');
  }

  void _statusListener(String status) {
    _logger.i('Status: $status');
    if (status == "done" && _speechEnabled) {
      setState(() {
        _isListening = false;
        widget.onListeningChanged(_isListening);
      });
    }
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onError: _errorListener,
      onStatus: _statusListener,
    );
    setState(() {});
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

  Future<void> _startListening() async {
    await _stopListening();
    await Future.delayed(const Duration(milliseconds: 50));
    _speech.listen(
      onResult: _onSpeechResult,
      localeId: _selectedLocaleId,
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation,
      ),
    );
    setState(() {
      _isListening = true;
      widget.onListeningChanged(_isListening);
    });
  }

  Future<void> _stopListening() async {
    setState(() {
      _isListening = false;
      widget.onListeningChanged(_isListening);
    });
    await _speech.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      widget.controller.text = result.recognizedWords;
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
