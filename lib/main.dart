import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_stack_card/flutter_stack_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MagicHome());
}

class MagicHome extends StatefulWidget {
  @override
  _MagicHomeState createState() => _MagicHomeState();
}

class _MagicHomeState extends State<MagicHome> {
  int _page = 1;
  int _pageSize = 5;
  Color _currentColor = blackColor;
  int _currentCardIndex = 0;
  List<dynamic> _cards = [];

  static const goldColor = Color(0xffDECD7D);
  static const blackColor = Color(0xff090606);
  static const greenColor = Color(0xffDAE1D2);

  String getUrl() {
    return "https://api.magicthegathering.io/v1/cards?page=$_page&pageSize=$_pageSize&contains=imageUrl";
  }

  dynamic _getCards() async {
    print(getUrl());
    http.Response response;
    response = await http.get(getUrl());
    dynamic data = json.decode(response.body);
    _cards = data["cards"];
    _currentCardIndex = 0;
    _cards.forEach((element) {
      print(element["name"]);
    });
    return data;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gerador de Decks',
        home: Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                setState(() {
                  _page += 1;
                });
              },
              child: Icon(Icons.refresh, color: goldColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            backgroundColor: greenColor,
            appBar: AppBar(
              title: Text(
                'Gerador de Decks - Deck $_page',
                style: TextStyle(color: goldColor),
              ),
              backgroundColor: _currentColor,
            ),
            body: Column(
              children: [
                Padding(padding: EdgeInsets.all(10)),
                Expanded(
                  child: FutureBuilder(
                    future: _getCards(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_currentColor),
                              strokeWidth: 5.0,
                            ),
                          );
                        default:
                          if (snapshot.hasError)
                            return Container();
                          else
                            return _createGiftTable(context, snapshot);
                      }
                    },
                  ),
                ),
              ],
            )));
  }

  Widget _createGiftTable(BuildContext context, AsyncSnapshot snapshot) {
    return StackCard.builder(
      onSwap: (value) => {_currentCardIndex = value - 1},
      stackType: StackType.right,
      itemCount: _pageSize,
      itemBuilder: (BuildContext context, int index) {
        return AnimationConfiguration.staggeredList(
          position: _currentCardIndex,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            child: FadeInAnimation(
              child: renderCard(snapshot.data["cards"], index),
            ),
          ),
        );
      },
    );
  }

  Widget _drawCircles(dynamic currentCard) {
    dynamic colors = currentCard["colors"];
    if (colors.length == 0) {
      return Container(
        child: Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text('-'),
        ),
      );
    }

    for (var color in colors)
      return FractionalTranslation(
        translation: Offset(0.0, 0.5),
        child: new Container(
          alignment: new FractionalOffset(0.0, 0.0),
          decoration: new BoxDecoration(
            border: new Border.all(
              color: _getColor(color),
              width: 10.0,
            ),
            shape: BoxShape.circle,
          ),
        ),
      );
  }

  Widget renderCard(cards, int index) {
    dynamic currentCard = cards[index];
    bool hasColor = currentCard["colors"].length > 0;
    Color currentColor = _getColor(hasColor
        ? currentCard["colors"][currentCard["colors"].length - 1]
        : '');
    String imageUrl = currentCard["imageUrl"] != null
        ? currentCard["imageUrl"]
        : 'https://www.publicdomainpictures.net/pictures/280000/velka/not-found-image-15383864787lu.jpg';
    return Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(1)),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(imageUrl), fit: BoxFit.cover)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Nome: ' + currentCard["name"],
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: Text(
                              'Cores: ',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          _drawCircles(currentCard),
                        ],
                      ),
                    ],
                  )),
            )
          ],
        ));
  }

  Color _getColor(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return Colors.red.withOpacity(0.5);
      case 'white':
        return Colors.white.withOpacity(0.5);
      case 'blue':
        return Colors.blue.withOpacity(0.5);
      case 'black':
        return Colors.black.withOpacity(0.5);
      case 'yellow':
        return Colors.yellow.withOpacity(0.5);
      case 'green':
        return Colors.green.withOpacity(0.5);
      case 'orange':
        return Colors.orange.withOpacity(0.5);
      default:
        return Colors.black;
    }
  }
}
