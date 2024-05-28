import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatController extends GetxController {
  final String token; // Declare a token variable
  /*final socket = IO.io('http://localhost:3000',
      IO.OptionBuilder().setTransports(['websocket']).build());*/
  late final IO.Socket socket;
  final scrollController = ScrollController();
  final textController = TextEditingController();
  final username = ''.obs;
  final message = ''.obs;
  final chatMessages = <Widget>[].obs;

  ChatController({required this.token}) {
    socket = IO.io(
      'http://localhost:3000',
      IO.OptionBuilder()
          .setTransports(['websocket']).setQuery({'token': token}).build(),
    );
  }

  String _convertTimeStamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('hh:mm a').format(date); // Format the date as you need
  }

  @override
  void onInit() async {
    super.onInit();
    await getUsername();
    initSocket();
  }

  /*void initSocket() {
    //final token = Get.arguments;
    //TODO: debug this tomorrow
    socket.connect();
    socket.onConnect((_) {
      openUsernameDialog();
      print('connection established');
      Get.snackbar(
        'Connection Established',
        'You are now connected to the chat server',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    });

    socket.on("messages", (messages) {
      List<Widget> _chatMessages = [];
      for (var msg in messages) {
        print(msg);
        _chatMessages.add(
          ChatMessageWidget(
            username: msg['username'],
            message: msg['message'],
            timestamp: convertTimeStamp(msg['created']),
          ),
        );
      }
      chatMessages.assignAll(_chatMessages);
    });*/

  void initSocket() {
    socket.connect();
    socket.onConnect((_) {
      openUsernameDialog(username.value);
      print('connection established');
      Get.snackbar(
        'Connection Established',
        'You are now connected to the chat server',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    });

    socket.on("chat message", (dynamic data) {
      if (data is Map<String, dynamic>) {
        String msg = data['message'];
        String username = data['username'];
        print('Message from the server ' + msg);

        chatMessages.add(
          ChatMessageWidget(
            username: username,
            message: msg,
            timestamp: _convertTimeStamp(DateTime.now().millisecondsSinceEpoch),
          ),
        );
        scrollToBottom();
      } else if (data is List<dynamic> && data.length >= 3) {
        String msg = data[0];
        String username = data[2];
        print('Message from the server ' + msg);

        chatMessages.add(
          ChatMessageWidget(
            username: username,
            message: msg,
            timestamp: _convertTimeStamp(DateTime.now().millisecondsSinceEpoch),
          ),
        );
        scrollToBottom();
      }
    });
  }

  String convertTimeStamp(int timestamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String convertedDateTime =
        "${dateTime.year.toString()}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}-${dateTime.minute.toString().padLeft(2, '0')}";
    return convertedDateTime;
  }

  void openUsernameDialog(String username) {
    Get.defaultDialog(
      title: "Welcome $username",
      content: Text("You will join the chat room as '$username'."),
      actions: [
        TextButton(
          onPressed: () {
            // Update the username observable with the provided username
            this.username.value = username;
            Get.back();
          },
          child: Text("Join Chat"),
        ),
      ],
    );
  }

  void sendMessage() {
    if (textController.text.isNotEmpty) {
      String message = textController.text;
      int clientOffset = DateTime.now().millisecondsSinceEpoch;
      print('Here is the username: ' +
          username.value +
          ' and the message: ' +
          message +
          ' and the clientOffset: ' +
          clientOffset.toString());

      socket.emit(
        "chat message",
        {
          'message': message,
          'clientOffset': clientOffset.toString(),
          'username': username.value,
        },
      );

      /*
      // Add the sent message to the chatMessages observable list
      chatMessages.add(
        ChatMessageWidget(
          username: username.value,
          message: message,
          timestamp: _convertTimeStamp(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      */

      textController.clear();
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 50),
      );
    }
  }

  Future<void> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? usernameFromPrefs = prefs.getString('username');

    if (usernameFromPrefs == null) {
      throw Exception('Username not found');
    }
    print(usernameFromPrefs);

    // Update the username observable
    this.username.value = usernameFromPrefs;
  }

  @override
  void onClose() {
    socket.disconnect();
    super.onClose();
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    required this.username,
    required this.message,
    required this.timestamp,
    super.key,
  });

  final String username;
  final String message;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: ListTile(
          leading: Text(timestamp),
          title: Text(username),
          subtitle: Text(
            message,
            style: TextStyle(fontSize: 14),
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}
