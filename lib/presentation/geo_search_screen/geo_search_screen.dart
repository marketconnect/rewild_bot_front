import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/geo_constants.dart';
import 'package:rewild_bot_front/domain/entities/geo_search_model.dart';
import 'package:rewild_bot_front/domain/entities/wb_search_log.dart';
import 'package:rewild_bot_front/presentation/geo_search_screen/geo_search_view_model.dart';
import 'package:rewild_bot_front/widgets/custom_elevated_button.dart';
import 'package:rewild_bot_front/widgets/progress_indicator.dart';

class GeoSearchScreen extends StatefulWidget {
  const GeoSearchScreen({super.key, this.initQuery});
  final String? initQuery;

  @override
  // ignore: library_private_types_in_public_api
  _GeoSearchScreenState createState() => _GeoSearchScreenState();
}

class _GeoSearchScreenState extends State<GeoSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late Map<String, bool> _selectedGeos;
  final ScrollController _scrollController = ScrollController();
  String? _errorText;
  @override
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_controller.text.trim().isNotEmpty) {
        setState(() {
          _errorText = null;
        });
      }
    });
    _selectedGeos = geoDistance.map((key, value) => MapEntry(key, false));
    _selectedGeos['Москва'] = true;

    // Загрузка начального запроса если он существует
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initQuery != null) {
        _controller.text = widget.initQuery!;
        _showSearchBottomSheet();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Adjusts to the content size
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: IconButton(
                            onPressed: () => Navigator.pop(bottomSheetContext),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                            )),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      errorText: _errorText,
                      labelText: 'Введите запрос',
                      suffixIcon: _controller.text.isNotEmpty
                          ? Align(
                              heightFactor: 1,
                              widthFactor: 1,
                              child: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  // Also clear the error text when the clear button is pressed
                                  setState(() {
                                    _errorText = null;
                                  });
                                },
                              ),
                            )
                          : null,
                    ),
                    onChanged: (text) {
                      // Clear the error text as soon as the user starts typing
                      if (_errorText != null && text.isNotEmpty) {
                        setState(() {
                          _errorText = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.trim().isEmpty) {
                        setState(() {
                          _errorText = 'Поле не может быть пустым';
                        });
                        return;
                      }
                      setState(() {
                        _errorText = null;
                      });

                      _onSearchPressed();
                      Navigator.pop(bottomSheetContext);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      child: Text(
                        'Поиск',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Выберите города:",
                      ),
                      ..._selectedGeos.keys.map((geo) {
                        return CheckboxListTile(
                          title: Text(geo),
                          value: _selectedGeos[geo],
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedGeos[geo] = value!;
                            });
                          },
                        );
                      }),
                    ]),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onSearchPressed() {
    List<String> selectedGNums = _selectedGeos.entries
        .where((entry) => entry.value)
        .map((entry) => geoDistance[entry.key]!)
        .toList();
    context
        .read<GeoSearchViewModel>()
        .searchProducts(selectedGNums, _controller.text);
    // Navigator.pop(context); // Close the bottom sheet after search
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GeoSearchViewModel>();
    final adverts = model.adverts;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Позиции и ставки'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _showSearchBottomSheet,
                ),
              ],
              scrolledUnderElevation: 2,
              shadowColor: Colors.black,
              surfaceTintColor: Colors.transparent,
              bottom: TabBar(splashFactory: NoSplash.splashFactory, tabs: [
                SizedBox(
                  width: model.screenWidth * 0.5,
                  child: const Tab(
                    child: Text('Поиск'),
                  ),
                ),
                SizedBox(
                  width: model.screenWidth * 0.5,
                  child: const Tab(
                    child: Text('Ставки'),
                  ),
                ),
              ]),
            ),
            body: TabBarView(children: [
              _buildBody(context),
              _Advert(adverts: adverts),
            ])));
  }

  Widget _buildBody(BuildContext context) {
    final model = context.watch<GeoSearchViewModel>();
    final productsByGeo = model.productsByGeo;
    final searchPerformed = model.searchPerformed;
    final isLoading = model.isLoading;
    return isLoading
        ? const MyProgressIndicator()
        : productsByGeo.isEmpty && !searchPerformed
            ? Center(
                // Show message if search is not performed
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    onTap: () {
                      _showSearchBottomSheet();
                    },
                    text: "Введите запрос",
                    buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.onPrimary)),
                    height: model.screenWidth * 0.2,
                    margin: EdgeInsets.fromLTRB(
                        model.screenWidth * 0.1,
                        model.screenHeight * 0.1,
                        model.screenWidth * 0.1,
                        model.screenHeight * 0.1),
                  ),
                ],
              ))
            : _buildWidget(); // search performed
  }

  Widget _buildWidget() {
    final model = context.watch<GeoSearchViewModel>();
    final productsByGeo = model.productsByGeo;
    final searchPerformed = model.searchPerformed;

    return productsByGeo.isEmpty && searchPerformed
        ? Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: const Text(
                      'По запросу не найдено совпадений с Вашими карточками.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  CustomElevatedButton(
                    onTap: () {
                      _showSearchBottomSheet();
                    },
                    text: "Попробовать снова",
                    buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.onPrimary)),
                    height: model.screenWidth * 0.2,
                    margin: EdgeInsets.fromLTRB(
                        model.screenWidth * 0.1,
                        model.screenHeight * 0.05,
                        model.screenWidth * 0.1,
                        model.screenHeight * 0.1),
                  ),
                ],
              ),
            ),
          )
        : const _Cards();
  }
}

class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GeoSearchViewModel>();
    final onCardTap = model.onCardTap;
    return ListView.builder(
      itemCount: model.productsByGeo.length,
      itemBuilder: (BuildContext context, int index) {
        int nmId = model.productsByGeo.keys.elementAt(index);
        Map<String, GeoSearchModel> geoIndices = model.productsByGeo[nmId]!;
        String imageUrl = model.imageForProduct(nmId);

        // If in advert
        final geo = geoIndices.entries.first.value;
        Column? col;
        if (geo.advCpm != null && geo.advPosition != null) {
          col = Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Реклама'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: const Text('cpm')),
                  Text('${geo.advCpm}')
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: const Text('Промо поз.')),
                  Text('${geo.position + 1}'),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: const Text('Позиция')),
                  Text('${geo.advPosition! + 1}'),
                ],
              ),
            ],
          );
        }

        // Creating a list of DataRow for each geo index
        List<DataRow> dataRows = geoIndices.entries.map((entry) {
          return DataRow(
            cells: [
              DataCell(Text(getDistanceCity(entry.key))), // City
              DataCell(Text('${entry.value.position + 1}')), // Qty
            ],
          );
        }).toList();

        return GestureDetector(
          onTap: () => onCardTap(nmId),
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                imageUrl.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.network(
                            imageUrl,
                            width: MediaQuery.of(context).size.width * 0.2,
                            fit: BoxFit.cover,
                            height: 100,
                          ),
                          if (col != null) col
                        ],
                      )
                    : const Placeholder(fallbackHeight: 100),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Город')),
                    DataColumn(label: Text('Позиция')),
                  ],
                  rows: dataRows,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Advert extends StatefulWidget {
  const _Advert({
    required this.adverts,
  });

  final List<WbSearchLog> adverts;

  @override
  State<_Advert> createState() => _AdvertState();
}

class _AdvertState extends State<_Advert> {
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    final cities =
        widget.adverts.map((e) => getDistanceCity(e.geo)).toSet().toList();

    final model = context.watch<GeoSearchViewModel>();
    final isLoading = model.isLoading;
    final searchPerformed = model.searchPerformed;
    final widthCoef = selectedCity != null ? 0.3 : 0.2;

    if (isLoading) {
      return const MyProgressIndicator();
    }
    if (widget.adverts.isEmpty && !searchPerformed) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: const Text(
                  'По Вашему запросу не найдено данных о рекламных кампаниях.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: cities.isEmpty
              ? null
              : DropdownButton<String>(
                  hint: const Text("Выбрать город"),
                  value: selectedCity,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCity = newValue;
                    });
                  },
                  items: cities.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                DataTable(
                    columnSpacing: 0,
                    horizontalMargin: 0,
                    dividerThickness: 0,
                    columns: [
                      if (selectedCity == null)
                        const DataColumn(
                            label: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Город'),
                          ],
                        )),
                      DataColumn(
                          label: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * widthCoef,
                              child: const Text('CPM',
                                  textAlign: TextAlign.center)),
                        ],
                      )),
                      DataColumn(
                          label: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width:
                                MediaQuery.of(context).size.width * widthCoef,
                            child: Text(
                              selectedCity == null
                                  ? 'Промо\nместо'
                                  : 'Промо место',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                      DataColumn(
                          label: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width:
                                MediaQuery.of(context).size.width * widthCoef,
                            child: const Text(
                              'Место',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                    ],
                    rows: widget.adverts
                        .where((advert) =>
                            selectedCity == null ||
                            getDistanceCity(advert.geo) == selectedCity)
                        .map((geoPosCpm) {
                      return DataRow(cells: [
                        if (selectedCity == null)
                          DataCell(SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: Text(getDistanceCity(geoPosCpm.geo)),
                          )),
                        DataCell(SizedBox(
                            width:
                                MediaQuery.of(context).size.width * widthCoef,
                            child: Text(
                              geoPosCpm.cpm.toString(),
                              textAlign: TextAlign.center,
                            ))),
                        DataCell(SizedBox(
                          width: MediaQuery.of(context).size.width * widthCoef,
                          child: Text(
                            (geoPosCpm.promoPosition + 1).toString(),
                            textAlign: TextAlign.center,
                          ),
                        )),
                        DataCell(SizedBox(
                          width: MediaQuery.of(context).size.width * widthCoef,
                          child: Text(
                            (geoPosCpm.position + 1).toString(),
                            textAlign: TextAlign.center,
                          ),
                        )),
                      ]);
                    }).toList()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
