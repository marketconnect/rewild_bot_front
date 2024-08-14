import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    // Check if the database is already initialized
    if (_database != null) {
      return _database!;
    }
    // Initialize the database if it is null
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    // Ensure the database factory is not null
    final dbFactory = getIdbFactory();
    if (dbFactory == null) {
      throw Exception("Failed to get IDB factory.");
    }

    // Open the database and check if it succeeded
    final db = await dbFactory.open('rewild.db',
        version: 20, onUpgradeNeeded: _onCreate);

    return db;
  }

  Future<void> _onCreate(VersionChangeEvent event) async {
    final db = event.database;

    // Create the user_sellers store
    final userSellersStore =
        db.createObjectStore('user_sellers', keyPath: 'sellerId');
    userSellersStore.createIndex('sellerId', 'sellerId', unique: true);

    // Create the tariffs store with a composite key for uniqueness (storeId and type)
    final tariffsStore =
        db.createObjectStore('tariffs', keyPath: 'id', autoIncrement: true);
    tariffsStore.createIndex('storeId_type', ['storeId', 'type'], unique: true);

    // Create the supplies store with a composite key for uniqueness (nmId, wh, sizeOptionId)
    final suppliesStore =
        db.createObjectStore('supplies', keyPath: 'id', autoIncrement: true);
    suppliesStore.createIndex(
        'nmId_wh_sizeOptionId', ['nmId', 'wh', 'sizeOptionId'],
        unique: true);

    // Create the cards store
    final _ = db.createObjectStore('cards', keyPath: 'nmId');
    // Optionally create indexes based on what queries you plan to run
    // Example: cardsStore.createIndex('sellerId', 'sellerId');

    // Create the initial_stocks store with a composite key for uniqueness (nmId, wh, sizeOptionId)
    final initialStocksStore = db.createObjectStore('initial_stocks',
        keyPath: 'id', autoIncrement: true);
    initialStocksStore.createIndex(
        'nmId_wh_sizeOptionId', ['nmId', 'wh', 'sizeOptionId'],
        unique: true);

    // Create the stocks store with a composite key for uniqueness (nmId, wh, sizeOptionId)
    final stocksStore =
        db.createObjectStore('stocks', keyPath: 'id', autoIncrement: true);
    stocksStore.createIndex(
        'nmId_wh_sizeOptionId', ['nmId', 'wh', 'sizeOptionId'],
        unique: true);

    final ordersStore =
        db.createObjectStore('orders', keyPath: 'id', autoIncrement: true);
    ordersStore.createIndex(
        'sku_warehouse_period', ['sku', 'warehouse', 'period'],
        unique: true);

    final cardKeywordsStore = db.createObjectStore('card_keywords',
        keyPath: 'id', autoIncrement: true);
    cardKeywordsStore.createIndex('cardId_keyword_freq', ['cardId', 'keyword'],
        unique: true);

    db.createObjectStore('cached_kw_by_autocomplite', keyPath: 'keyword');

    final cachedKwByLemmaStore =
        db.createObjectStore('cached_kw_by_lemma', keyPath: 'lemmaID');
    cachedKwByLemmaStore.createIndex(
        'lemmaID_keyword_freq', ["lemmaID", "keyword"],
        unique: true);

    final cachedKwByWord =
        db.createObjectStore('cached_kw_by_word', keyPath: 'lemmaID');
    cachedKwByWord.createIndex("lemmaID_keyword_freq", ["lemmaID", "keyword"],
        unique: true);

    final filtersStore = db.createObjectStore('filters', autoIncrement: true);
    filtersStore.createIndex(
      'sectionName_itemId',
      ['sectionName', 'itemId'],
      unique: true,
    );

    final filterValuesStore =
        db.createObjectStore('filterValues', autoIncrement: true);

    filterValuesStore.createIndex('filterName_value', ["filterName", "value"],
        unique: true);

    final trackingStore =
        db.createObjectStore('tracking_results', autoIncrement: true);

    // Create indexes to ensure uniqueness similar to UNIQUE(keyword, geo, product_id, date) ON CONFLICT REPLACE
    trackingStore.createIndex(
        'keyword_geo_product_date', ['keyword', 'geo', 'product_id', 'date'],
        unique: true);

    final cachedLemmasStore =
        db.createObjectStore('cached_lemmas', autoIncrement: true);
    cachedLemmasStore.createIndex('subjectId_lemma', ["subjectId", 'lemma'],
        unique: true);

    final notificationsStore = db.createObjectStore('notifications',
        keyPath: 'id', autoIncrement: true);

    notificationsStore.createIndex(
        'parentId_condition', ['parentId', 'condition'],
        unique: true);

    db.createObjectStore('total_cost_calculator',
        keyPath: ['nmId', 'expenseName']);

    db.createObjectStore('sellers', keyPath: 'supplierId');

    db.createObjectStore('subs', keyPath: 'id', autoIncrement: true);
    ;
  }

  Future<void> close() async {
    _database?.close();
  }
}
