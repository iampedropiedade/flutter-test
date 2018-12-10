import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "src/google_sign_in.dart";

void main() => runApp(MyApp());


final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care takers',
      theme: new ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: new SignIn(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}



class MySettingsForm extends StatefulWidget {
  @override
  MySettingsFormState createState() {
    return MySettingsFormState();
  }
}

class MySettingsFormState extends State<MySettingsForm> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    return
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your first name';
                    }
                  },
                )
              ),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your last name';
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, we want to show a Snackbar
                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text('Save')));
                    }
                  },
                  child: Text('Save'),
                ),
              ),
            ],
          ),
          key: _formKey,
        )
      );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('My care takers'),
          actions: <Widget>[
            new IconButton(icon: const Icon(Icons.list), onPressed: _viewSettings),
          ],
      ),
      body: _buildBody(context),
    );
  }

  void _viewSettings() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return SignIn();
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.lastname),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.getName()),
          subtitle: Text(record.email),
          trailing: new Icon(Icons.settings, color: Colors.black54),
            onTap: () => Firestore.instance.runTransaction((transaction) async {
              final freshSnapshot = await transaction.get(record.reference);
              final fresh = Record.fromSnapshot(freshSnapshot);

              await transaction
                  .update(record.reference, {'clicks': fresh.clicks + 1});
            }),
        ),
      ),
    );
  }

  void _viewRecordSettings(reference) {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Settings'),
            ),

          );
        },
      ),
    );
  }
}

class Record {
  final String firstname;
  final String lastname;
  final String email;
  final int clicks;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['firstname'] != null),
        assert(map['lastname'] != null),
        firstname = map['firstname'],
        lastname = map['lastname'],
        email = map['email'],
        clicks= map['clicks'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  String getName() => "$firstname $lastname";

  @override
  String toString() => "$firstname $lastname";
}