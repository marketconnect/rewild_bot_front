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
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: GestureDetector(
        onTap: () {
          _showLocationDialog(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              geoDistanceCity,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      centerTitle: true,
    );
  }

  void _showLocationDialog(BuildContext context) {
    final model = context.read<AllAdvertsWordsViewModel>();
    final setgNum = model.setGNum;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Выберите локацию для анализа ставок'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: geoDistance.entries
                  .map(
                    (e) => ListTile(
                      title: Text(e.key),
                      onTap: () {
                        setgNum(e.value);
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
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
      width: screenWidth,
      height: MediaQuery.of(context).size.height * 0.14,
      margin: const EdgeInsets.only(
        bottom: 25,
      ),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
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
          SizedBox(width: screenWidth * 0.05),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advert.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subjects == null ? "" : subjects.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
