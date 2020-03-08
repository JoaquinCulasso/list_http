import 'dart:math';

import 'package:flutter/material.dart';
import 'package:app_list_http/network.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:webfeed/domain/rss_item.dart';
import 'package:webview_flutter/webview_flutter.dart';

const swatch_1 = Color(0xff91a1b4);
const swatch_2 = Color(0xffe3e6f3);
const swatch_3 = Color(0xffbabdd2);
const swatch_4 = Color(0xff545c6b);
const swatch_5 = Color(0xff363cb0);
const swatch_6 = Color(0xff09090a);
const swatch_7 = Color(0xff25255b);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIST_HTTP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;

        switch (settings.name) {
          case '/':
            builder =
                (BuildContext context) => MyHomePage(title: 'Latest news');
            break;
          case '/show':
            var args = settings.arguments;
            if (args is RssItem) {
              builder = (BuildContext context) =>
                  ShowPage(title: args.title, content: args.content.value);
            }
            break;
        }

        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}

class ShowPage extends StatefulWidget {
  ShowPage({Key key, this.title, this.content}) : super(key: key);

  final String title;
  final String content;

  @override
  _MyShowPage createState() => _MyShowPage();
}

class _MyShowPage extends State<ShowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: swatch_3.withOpacity(0.5),
        elevation: 0.0,
        centerTitle: false,
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back_ios, color: Colors.black)),
        title: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.0,
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 32.0),
            child: InkWell(
              child: Icon(
                Icons.share,
                color: swatch_1,
              ),
            ),
          )
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    var style =
        "<style>* { font-size: 20px !important;} img { width: 100% !important; height: auto !important;}</style>";
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: WebView(
          initialUrl: Uri.dataFromString(style + widget.content,
                  parameters: {'charset': 'utf-8'}, mimeType: 'text/html')
              .toString()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePage createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  ScrollController _controller;
  double backgroundHeight = 180.0;
  Future<RssFeed> future;

//Inicializamos el scroll controller
  @override
  void initState() {
    super.initState();

    future = getNews();

    getNews().then((rss) {
      print(rss.title);
    });

    _controller = ScrollController(); // creamos una instancia
    _controller.addListener(() {
      setState(() {
        backgroundHeight = max(0, 180.0 - _controller.offset);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: swatch_3.withOpacity(0.5),
        elevation: 0.0,
        centerTitle: false,
        title: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.0,
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 32.0),
            child: InkWell(
              child: Icon(
                Icons.share,
                color: swatch_1,
              ),
            ),
          )
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<RssFeed> snapshot) {
        List<Widget> children;

        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: backgroundHeight,
                color: swatch_3.withOpacity(0.5),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: ListView.builder(
                  controller: _controller,
                  itemCount: snapshot.data.items.length + 2,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: Text(snapshot.data.description));
                    }
                    if (index == 1) {
                      return _bigItem();
                    }

                    return _item(snapshot.data.items[index - 2]);
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          children = <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            )
          ];
        } else {
          children = <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            )
          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        );

        // return Stack(
        //   children: <Widget>[
        //     Container(
        //       width: double.infinity,
        //       height: backgroundHeight,
        //       color: swatch_3.withOpacity(0.5),
        //     ),
        //     Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 32.0),
        //       child: ListView(controller: _controller, children: <Widget>[
        //         Padding(
        //           padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
        //           child: Text("Discover things of this world"),
        //         ),
        //         _bigItem(),
        //         _item('Crafywork', 'images/item_1.jpg'),
        //         _item('Framer', 'images/item_2.jpg'),
        //         _item('Figma Design', 'images/item_3.jpg'),
        //         _item('Crafywork', 'images/item_1.jpg'),
        //         _item('Framer', 'images/item_2.jpg'),
        //         _item('Figma Design', 'images/item_3.jpg'),
        //       ]),
        //     ),
        //   ],
        // );
      },
    );
  }

  _bigItem() {
    var screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: (screenWidth - 64) * 3 / 5,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/big_item.jpg'),
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(32.0)),
          child: Icon(
            Icons.play_arrow,
            color: swatch_7,
            size: 40.0,
          ),
        ),
      ],
    );
  }

  _item(RssItem item) {
    var mediaUrl = _extractImage(item.content.value);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/show', arguments: item);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: IntrinsicHeight(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(21.0),
                            color: swatch_5,
                          ),
                          child: Center(
                            child: Text(
                              item.categories.first.value[0],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          item.categories.first.value,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.dc.creator,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 16.0,
              ),
              mediaUrl != null
                  ? Container(
                      width: 120,
                      height: 120,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'images/item_1.jpg',
                        image: mediaUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox(width: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  String _extractImage(String content) {
    RegExp regExp = RegExp('<img[^>]+src="([^">]+)"');

    Iterable<Match> matches = regExp.allMatches(content);

    if (matches.length > 0) {
      return matches.first.group(1);
    }

    return null;
  }
}
