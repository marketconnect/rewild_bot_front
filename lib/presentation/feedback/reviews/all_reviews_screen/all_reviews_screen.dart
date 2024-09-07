import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/icon_constant.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/core/utils/date_time_utils.dart';
import 'package:rewild_bot_front/domain/entities/review_model.dart';
import 'package:rewild_bot_front/presentation/feedback/reviews/all_reviews_screen/all_reviews_view_model.dart';
import 'package:rewild_bot_front/widgets/expandable_image.dart';
import 'package:rewild_bot_front/widgets/rate_stars.dart';

class AllReviewsScreen extends StatefulWidget {
  const AllReviewsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AllReviewsScreenState createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllReviewsViewModel>();
    final reviews = model.reviews;
    final screenWidth = MediaQuery.of(context).size.width;
    final navigateToReviewDetailsScreen = model.navigateToReviewDetailsScreen;
    // Search
    final setSearchQuery = model.setSearchQuery;
    final clearSearchQuery = model.clearSearchQuery;
    final searchQuery = model.searchQuery;
    final ratingStatistics = model.ratingStatistics;
    final isLoading = model.isLoading;
    final productName = model.name;
    final displayedReviews = reviews.where((q) {
      if (q.answer != null) {
        return q.text.toLowerCase().contains(searchQuery.toLowerCase()) ||
            q.answer!.text.toLowerCase().contains(searchQuery.toLowerCase());
      }
      return q.text.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 2,
            shadowColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      clearSearchQuery();
                    }
                  });
                },
              ),
            ],
            title: _isSearching
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                      });
                    },
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setSearchQuery(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Поиск...',
                        border: InputBorder.none,
                      ),
                    ),
                  )
                : Text(productName),
            bottom: ratingStatistics == null
                ? null
                : PreferredSize(
                    preferredSize: Size.fromHeight(screenWidth * 0.25),
                    child: Container(
                      height: screenWidth * 0.25,
                      alignment: Alignment.center,
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Рейтинг:',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                    Text(
                                      'За неделю: ',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                    Text(
                                      'За месяц:',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      ratingStatistics.averageRating
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                    Text(
                                      ratingStatistics.lastWeekRating
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                          color: ratingStatistics
                                                      .lastWeekRating >
                                                  ratingStatistics.averageRating
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .error),
                                    ),
                                    Text(
                                      ratingStatistics.lastMonthRating
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                          color: ratingStatistics
                                                      .lastMonthRating >
                                                  ratingStatistics.averageRating
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .error),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            _RatingsCountAppBarBottom(
                                screenWidth: screenWidth,
                                ratingStatistics: ratingStatistics),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          body: Column(children: [
            Expanded(
                child: ListView.builder(
                    itemCount: displayedReviews.length,
                    itemBuilder: (context, index) {
                      var review = displayedReviews[index];
                      // ignore: prefer_null_aware_operators
                      final answer = review.answer?.text;
                      return GestureDetector(
                        onTap: () async {
                          if (answer != null) {
                            return;
                          }
                          await navigateToReviewDetailsScreen(
                              displayedReviews[index]);
                        },
                        child: _ReviewCard(
                          reviewText: review.text,
                          answer: answer,
                          createdAt: review.createdDate,
                          valuation: review.productValuation,
                          photoLinks: review.photoLinks,
                          userName: review.userName,
                        ),
                      );
                    }))
          ])),
    );
  }
}

class _RatingsCountAppBarBottom extends StatelessWidget {
  const _RatingsCountAppBarBottom({
    required this.screenWidth,
    required this.ratingStatistics,
  });

  final double screenWidth;
  final RatingStatistics ratingStatistics;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RateStars(
              valuation: 5,
              starHeight: screenWidth * 0.04,
            ),
            SizedBox(
              width: screenWidth * 0.02,
            ),
            Text(
              '${ratingStatistics.ratingCount[5] ?? 0}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: screenWidth * 0.03),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RateStars(valuation: 4, starHeight: screenWidth * 0.04),
            SizedBox(
              width: screenWidth * 0.02,
            ),
            Text(
              '${ratingStatistics.ratingCount[4] ?? 0}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: screenWidth * 0.03),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RateStars(valuation: 3, starHeight: screenWidth * 0.04),
            SizedBox(
              width: screenWidth * 0.02,
            ),
            Text(
              '${ratingStatistics.ratingCount[3] ?? 0}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: screenWidth * 0.03),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RateStars(valuation: 2, starHeight: screenWidth * 0.04),
            SizedBox(
              width: screenWidth * 0.02,
            ),
            Text(
              '${ratingStatistics.ratingCount[2] ?? 0}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: screenWidth * 0.03),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RateStars(valuation: 1, starHeight: screenWidth * 0.04),
            SizedBox(
              width: screenWidth * 0.02,
            ),
            Text(
              '${ratingStatistics.ratingCount[1] ?? 0}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: screenWidth * 0.03),
            )
          ],
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(
      {required this.reviewText,
      required this.createdAt,
      required this.userName,
      this.photoLinks = const [],
      this.answer,
      required this.valuation});
  final String reviewText;
  final DateTime createdAt;
  final String userName;
  final int valuation;
  final List<PhotoLink> photoLinks;
  final String? answer;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    final dateText = formatReviewDate(createdAt);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06, vertical: screenWidth * 0.08),
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.085,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        // borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: Column(children: [
        Row(
          children: [
            _Ava(valuation: valuation),
            SizedBox(
              width: screenWidth * 0.04,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenWidth * 0.55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.3,
                        child: Text(userName,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.75),
                            )),
                      ),
                      SizedBox(
                        width: screenWidth * 0.2,
                        child: Text(
                          dateText,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                RateStars(valuation: valuation)
              ],
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: screenWidth * 0.75,
              child: Text(reviewText),
            ),
          ],
        ),
        if (photoLinks.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: screenWidth * 0.05),
            width: screenWidth,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: photoLinks
                      .map((link) => ReWildExpandableImage(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            expandedImagePath: link.fullSize,
                            colapsedImagePath: link.miniSize,
                          ))
                      .toList(),
                )),
          ),
        if (answer != null && answer!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CustomExpansionTile(
              title: "Ответ",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: screenWidth * 0.75, child: Text(answer!)),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}

class _Ava extends StatelessWidget {
  const _Ava({required this.valuation});
  final int valuation;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.08),
        color: const Color(0xFFd9d9d9),
      ),
      padding: EdgeInsets.all(screenWidth * 0.03),
      alignment: Alignment.center,
      width: screenWidth * 0.15,
      height: screenWidth * 0.15,
      child: Image.asset(
        valuation == 5
            ? IconConstant.iconHappyFemale
            : valuation == 4
                ? IconConstant.iconGoodFemale
                : valuation == 3
                    ? IconConstant.iconNormalFemale
                    : valuation == 2
                        ? IconConstant.iconBadFemale
                        : IconConstant.iconWorstFemale,
      ),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(widget.title,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(),
          secondChild: widget.child,
          firstCurve: Curves.fastOutSlowIn,
          secondCurve: Curves.fastOutSlowIn,
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
