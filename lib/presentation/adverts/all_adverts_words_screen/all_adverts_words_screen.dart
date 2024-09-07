import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/advertising_constants.dart';
import 'package:rewild_bot_front/core/constants/geo_constants.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/domain/entities/advert_base.dart';
import 'package:rewild_bot_front/presentation/adverts/all_adverts_words_screen/all_adverts_words_view_model.dart';
import 'package:rewild_bot_front/routes/main_navigation_route_names.dart';
import 'package:rewild_bot_front/widgets/network_image.dart';

class AllAdvertsWordsScreen extends StatelessWidget {
  const AllAdvertsWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllAdvertsWordsViewModel>();
    final gNum = model.gNum;
    final adverts = model.adverts;
    final autoAdverts = adverts
        .where((advert) => advert.type == AdvertTypeConstants.auto)
        .toList();

    final isLoading = model.isLoading;
    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _AppBar(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      children: [
                        if (autoAdverts.isNotEmpty)
                          const _Title(text: 'Автоматические'),
                        Column(
                          children: autoAdverts
                              .map(
                                (advert) => GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        MainNavigationRouteNames
                                            .autoStatWordsScreen,
                                        arguments: (
                                          advert.campaignId,
                                          advert.subjectId,
                                          gNum
                                        ));
                                    return;
                                  },
                                  child: _Card(
                                    advert: advert,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Row(
          children: [
            Text(text,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.065,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
      ],
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllAdvertsWordsViewModel>();
    final gNum = model.gNum;
    final geoDistanceCity = getDistanceCity(gNum);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.transparent,
              )),
              child: const Padding(
                padding:
                    EdgeInsets.only(left: 8.0, right: 16, top: 16, bottom: 16),
                child: Icon(Icons.arrow_back),
              ),
            ),
          ),
          Text(geoDistanceCity),
          IconButton(
              onPressed: () {
                _showBottomSheet(context);
              },
              icon: Icon(
                Icons.location_on_outlined,
                color: Theme.of(context).colorScheme.primary,
              )),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext parentContext) {
    final model = parentContext.read<AllAdvertsWordsViewModel>();
    final setgNum = model.setGNum;
    showModalBottomSheet(
        context: parentContext,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          //
          double screenHeight = MediaQuery.of(context).size.height;
          return SizedBox(
            height: screenHeight * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListWheelScrollView(
                itemExtent: MediaQuery.of(context).size.height * 0.2,
                diameterRatio: 1.5,
                children: geoDistance.entries
                    .map((e) => GestureDetector(
                          onTap: () {
                            setgNum(e.value);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(e.key,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          );
        });
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.advert});

  final Advert advert;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllAdvertsWordsViewModel>();
    final image = model.image(advert.campaignId);
    final subjects = model.subjects[advert.campaignId];
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.14,
      margin: const EdgeInsets.only(
        bottom: 25,
      ),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
              spreadRadius: 0,
              blurStyle: BlurStyle.outer,
              blurRadius: 5,
              offset: const Offset(0, 1),
            )
          ],
          color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.15 / 2),
            ),
            width: screenWidth * 0.17,
            height: screenWidth * 0.17,
            child: ClipOval(
              child: Stack(
                children: [
                  Positioned(
                    child: ReWildNetworkImage(
                      image: image,
                      width: screenWidth * 0.17,
                      height: screenWidth * 0.17,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.05,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  advert.name,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  subjects == null ? "" : subjects.join(', '),
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.02,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
