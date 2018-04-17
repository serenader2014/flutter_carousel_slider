import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

void main() => runApp(new CarouselDemo());

class CarouselDemo extends StatelessWidget {
  CarouselSlider instance;

  nextSlider() {
    instance.nextPage(duration: new Duration(milliseconds: 300), curve: Curves.linear);
  }

  prevSlider() {
    instance.previousPage(duration: new Duration(milliseconds: 800), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    instance = new CarouselSlider(
      items: imgList.map((url) {
        return new Container(
          margin: new EdgeInsets.symmetric(horizontal: 5.0),
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
            image: new DecorationImage(
              image: new NetworkImage(url),
              fit: BoxFit.cover
            )
          ),
        );
      }).toList(),
      viewportFraction: 0.9,
      aspectRatio: 2.0,
    );
    // print(instance.nextPage());
    return new MaterialApp(
      title: 'demo',
      home: new Scaffold(
        appBar: new AppBar(title: new Text('Carousel slider demo')),
        body: new ListView(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.symmetric(vertical: 15.0),
              child: instance
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new RaisedButton(
                    onPressed: nextSlider,
                    child: new Text('next slider')
                  ),
                ),
                new Expanded(
                  child: new RaisedButton(
                    onPressed: prevSlider,
                    child: new Text(' prev slider')
                  )
                )
              ],
            ),
            new Padding(
              padding: new EdgeInsets.symmetric(vertical: 15.0),
              child: new CarouselSlider(
                items: [1,2,3,4,5].map((i) {
                  return new Builder(
                    builder: (BuildContext context) {
                      return new Container(
                        width: MediaQuery.of(context).size.width,
                        margin: new EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: new BoxDecoration(
                          color: Colors.amber
                        ),
                        child: new Text('text $i', style: new TextStyle(fontSize: 16.0),)
                      );
                    },
                  );
                }).toList(),
                height: 400.0
              )
            ),
          ],
        )
      )
    );
  }
}