import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('viewportFraction', () {
    testWidgets('default viewportFraction', (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);

      // expect to find both side widget since viewports defaults to 0.8
      expect(find.text('page2'), findsOneWidget);
      expect(find.text('page5'), findsOneWidget);

      expect(find.text('page3'), findsNothing);

      // drag from page 1 to page 2
      await tester.dragUntilVisible(
          find.text('page2'), find.text('page1'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();
      expect(find.text('page3'), findsOneWidget);
      expect(find.text('page5'), findsNothing);
    });

    testWidgets('viewportFraction set to full screen - 1.0',
        (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1.0,
            ),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);

      // expect to find none of the side screen widget since viewports is at 1.0
      expect(find.text('page2'), findsNothing);
      expect(find.text('page5'), findsNothing);

      // drag from page 1 to page 2
      await tester.dragUntilVisible(
          find.text('page2'), find.text('page1'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();
      expect(find.text('page2'), findsOneWidget);
      expect(find.text('page1'), findsNothing);
    });
  });

  group('initial page', () {
    testWidgets('default initial page', (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1.0,
            ),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);
      expect(find.text('page2'), findsNothing);
    });

    testWidgets('custom initial page', (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(viewportFraction: 1.0, initialPage: 1),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsNothing);
      expect(find.text('page2'), findsOneWidget);
    });
  });

  group('infinite scroll loop', () {
    testWidgets('by default infinite scroll loop is set to true',
        (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(viewportFraction: 1.0),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);

      // drag page1 to right side
      await tester.drag(find.text('page1'), const Offset(500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('page5'), findsOneWidget);
      expect(find.text('page1'), findsNothing);
    });

    testWidgets('set infinite scroll loop to false',
        (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
            ),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);

      // drag page1 to right side
      await tester.drag(find.text('page1'), const Offset(500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('page5'), findsNothing);
      expect(find.text('page1'), findsOneWidget);
    });
  });

  group('autoPlay & autoPlayInterval', () {
    testWidgets('by default auto play is set to false',
        (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(viewportFraction: 1.0),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);

      tester.binding.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.text('page2'), findsNothing);
      expect(find.text('page1'), findsOneWidget);
    });

    testWidgets('set auto play to true',
        (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1.0,
              autoPlay: true,
            ),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);

      tester.binding.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.text('page1'), findsNothing);
      expect(find.text('page2'), findsOneWidget);
    });

    testWidgets('decrease auto play interval time',
        (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 2),
            ),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);

      tester.binding.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('page1'), findsNothing);
      expect(find.text('page2'), findsOneWidget);
    });

    
    testWidgets('increase auto play interval time',
        (WidgetTester tester) async {
      Widget build() {
        return boilerPlate(
          CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 6),
            ),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);

      tester.binding.delayed(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      expect(find.text('page1'), findsNothing);
      expect(find.text('page2'), findsOneWidget);
    });

  });

 /* group('carousel controller: start and stop auto play', () {
    testWidgets('start and stop auto play using controller', (WidgetTester tester) async {

      final CarouselController carouselController = CarouselController();

      Widget build() {
        return boilerPlate(
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(viewportFraction: 1.0),
            items: ['page1', 'page2', 'page3', 'page4', 'page5']
                .map(
                  (item) => Center(
                    child: Text(item),
                  ),
                )
                .toList(),
          ),
        );
      }

      await tester.pumpWidget(build());

      expect(find.text('page1'), findsOneWidget);
      
      carouselController.startAutoPlay();
      tester.binding.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.text('page2'), findsOneWidget);
      expect(find.text('page1'), findsNothing);

      carouselController.stopAutoPlay();
      tester.binding.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.text('page2'), findsOneWidget);
      expect(find.text('page1'), findsNothing);

    });

    
  });*/

}

Widget boilerPlate(Widget carouselWidget) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MaterialApp(
      color: const Color(0x00ff0000),
      home: Scaffold(
        body: Center(
          child: carouselWidget,
        ),
      ),
    ),
  );
}
