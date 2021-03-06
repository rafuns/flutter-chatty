import 'dart:async';

import 'package:chatty/models/chat_settings.dart';
import 'package:chatty/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/chat.dart';
import 'base_bloc.dart';

class ChatsBloc implements Bloc {
  ChatsBloc(this.chat) {
    _firestore
        .collection('chats/${chat.chatID}/messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((event) {
      _messagesSink.add(event.documents
          .map((e) => Message.fromJson(e.documentID, e.data))
          .toList());
    });
  }

  void sendMessage(Message message) {
    _firestore.collection('chats/${chat.chatID}/messages')
      ..add(
        message.toJson(),
      );
  }

  void updateMessage(Message message) {
    if (isCurrentUser(otherId: message.userId)) {
      _firestore
          .collection('chats/${chat.chatID}/messages')
          .document(message.id)
          .setData(message.toJson());
    }
  }

  void deleteMessage(Message message) {
    if (isCurrentUser(otherId: message.userId)) {
      _firestore
          .collection('chats/${chat.chatID}/messages')
          .document(message.id)
          .delete();
    }
  }

  void addContact(String uid) {
    _firestore.collection('users/$uid/chats_list')
      ..add(
        chat.receiver.toJson(),
      );
  }

  final Chat chat;
  final Firestore _firestore = Firestore.instance;

//  List<DocumentSnapshot> _messages = [];

  final _messagesStreamController = StreamController<List<Message>>();

  StreamSink<List<Message>> get _messagesSink => _messagesStreamController.sink;

  Stream<List<Message>> get messagesStream => _messagesStreamController.stream;

  final messageEditStreamController = StreamController<Message>();

  Stream<ChatSettings> get chatSettingsStream =>
      _firestore.document('chats/${chat.chatID}').snapshots().map(
        (event) {
          return ChatSettings.fromJson(event.data);
        },
      );

  bool isCurrentUser({@required String otherId}) {
    return otherId.compareTo(chat.sender.uid) == 0;
  }

  @override
  void dispose() {
    _messagesStreamController.close();
    messageEditStreamController.close();
  }
}
