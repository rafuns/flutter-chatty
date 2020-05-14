import 'package:chatty/screens/widgets/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import '../screens/chat_screen.dart';
import '../screens/new_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/utils.dart';

class AllChats extends StatefulWidget {
  AllChats({this.userID, this.auth, this.logoutCallback});

  final String userID;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  @override
  _AllChatsState createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  List<DocumentSnapshot> _allChats;
  User sender;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('All Chats \n ${sender?.fullname}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              dispose();
              widget.auth.signOut();
              widget.logoutCallback();
            },
          ),
        ],
      ),
      body: FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, userData) {
          if (userData.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final user = userData.data;
          

          sender = User(
            fullname: user.displayName,
            email: user.email,
            imageUrl: user.photoUrl,
            uid: user.uid,
            username: 'username',
          );

          final String senderID = sender.uid;
          final Firestore db = Firestore.instance;
          final CollectionReference chatsListCollectionRef =
              db.collection('users/$senderID/chats_list');

          return StreamBuilder<QuerySnapshot>(
            stream: chatsListCollectionRef.snapshots(),
            builder: (ctx, chatsListSnapshot) {
              if (chatsListSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              var allChats = chatsListSnapshot.data.documents;
              _allChats = allChats;

              return ListView.builder(
                itemCount: allChats.length,
                itemBuilder: (ctx, index) {
                  final DocumentReference chatDocRef = chatsListCollectionRef
                      .document(allChats[index].documentID);

                  var user = allChats[index];

                  final User receiver = User(
                    key: ValueKey(user['receiverID']),
                    fullname: user['fullname'],
                    username: user['username'],
                    uid: user['receiverID'],
                    email: user['email'],
                    imageUrl: user['imageUrl'],
                  );

                  return Container(
                    color: Theme.of(context).primaryColor,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey[900],
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image: new NetworkImage(receiver.imageUrl),
                            ),
                          ),
                        ),
                      ),
                      title: Text(allChats[index]['username']),
                      subtitle: Text('last message'),
                      onTap: () {
                        return Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ChatScreen(
                              sender: sender,
                              receiver: receiver,
                              isNewChat: false,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => NewChat(_allChats),
            ),
          );
        },
        child: Icon(Icons.create),
      ),
    );
  }
}
