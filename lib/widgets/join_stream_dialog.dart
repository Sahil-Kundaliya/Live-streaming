import 'package:flutter/material.dart';
import 'package:live_streaming/features/live_streaming/screens/stream_viewer_screen.dart';

class JoinStreamDialog extends StatefulWidget {
  const JoinStreamDialog({super.key});

  @override
  State<JoinStreamDialog> createState() => _JoinStreamDialogState();
}

class _JoinStreamDialogState extends State<JoinStreamDialog> {
  final _channelController = TextEditingController();

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Stream'),
      content: TextField(
        controller: _channelController,
        decoration: const InputDecoration(
          labelText: 'Enter Channel ID',
          hintText: 'Channel ID shared by broadcaster',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_channelController.text.isNotEmpty) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreamViewerScreen(
                    channelName: _channelController.text,
                  ),
                ),
              );
            }
          },
          child: const Text('Join'),
        ),
      ],
    );
  }
}