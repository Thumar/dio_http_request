import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo1',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  String url = "https://swapi.co/api/people";

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: this._fetchData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      DioError error = snapshot.error;
                      String message = error.message;
                      if (error.type == DioErrorType.CONNECT_TIMEOUT)
                        message = 'Connection Timeout';
                      else if (error.type == DioErrorType.RECEIVE_TIMEOUT)
                        message = 'Receive Timeout';
                      else if (error.type == DioErrorType.RESPONSE)
                        message =
                            '404 server not found ${error.response.statusCode}';
                      return Text('Error: ${message}');
                    }
                    List<String> people = new List<String>();
                    Response response = snapshot.data;
                    for (int i = 0; i < response.data['results'].length; i++) {
                      people.add(response.data['results'][i]['name']);
                    }
                    return Expanded(
                        child: ListView.builder(
                      itemCount: people.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(people[index]),
                        );
                      },
                    ));
                }
              },
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _fetchData() async {
    Dio dio = new Dio();
    dio.options.baseUrl = url;
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 30000;
    Response response = await dio.get(url);

    return response;
  }
}
