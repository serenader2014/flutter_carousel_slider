import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {

  group('initial page', () {
    testWidgets('default initial page', (WidgetTester tester) async {

      final CarouselController carouselController = CarouselController();

      Widget build() {
        return boilerPlate(
          CarouselSlider(
            carouselController: carouselController,
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

      //jump to third page
      carouselController.jumpToPage(2);
      await tester.pumpAndSettle();

      expect(find.text('page1'), findsNothing);
      expect(find.text('page3'), findsOneWidget);

      //jump to page which does not exist
      carouselController.jumpToPage(6);
      expect(find.text('page3'), findsOneWidget);

    });

    testWidgets('nextPage() and previousPage()', (WidgetTester tester) async {

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

      carouselController.nextPage(duration: const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('page1'), findsNothing);
      expect(find.text('page2'), findsOneWidget);

      carouselController.previousPage(duration: const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('page1'), findsOneWidget);
      expect(find.text('page2'), findsNothing);
    });

    testWidgets('Should not change from last page to first page when infinite scroll is set to false', (WidgetTester tester) async {

      final CarouselController carouselController = CarouselController();

      Widget build() {
        return boilerPlate(
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(viewportFraction: 1.0, enableInfiniteScroll: false),
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

      carouselController.previousPage(duration: const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('page1'), findsOneWidget);
    });

    testWidgets('Should not change from first page to last page when infinite scroll is set to false', (WidgetTester tester) async {

      final CarouselController carouselController = CarouselController();

      Widget build() {
        return boilerPlate(
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              initialPage: 4,
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
      
      expect(find.text('page5'), findsOneWidget);      

      carouselController.nextPage(duration: const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('page5'), findsOneWidget);
    });

    testWidgets('animateTo', (WidgetTester tester) async {

      final CarouselController carouselController = CarouselController();

      Widget build() {
        return boilerPlate(
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              viewportFraction: 1.0
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

      carouselController.animateToPage(2, duration: const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('page3'), findsOneWidget);
    });

    testWidgets('should loop throught when page does not exist & infityScroll is true', (WidgetTester tester) async {

      final CarouselController carouselController = CarouselController();

      Widget build() {
        return boilerPlate(
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              viewportFraction: 1.0
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

      carouselController.animateToPage(6, duration: const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // since the infinty scroll is true, it will loop through a cycle
      expect(find.text('page2'), findsOneWidget);
    });

    testWidgets('should animate to last page when page does not exist and infityScroll is set to true', (WidgetTester tester) async {

      final CarouselController carouselController = CarouselController();

      Widget build() {
        return boilerPlate(
          CarouselSlider(
            carouselController: carouselController,
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

      carouselController.animateToPage(6, duration: const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('page5'), findsOneWidget);
    });
    
  });

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
