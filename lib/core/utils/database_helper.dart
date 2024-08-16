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
    final db = await dbFactory.open('rewild-1.db',
        version: 24, onUpgradeNeeded: _onCreate);

    return db;
  }

  Future<void> _onCreate(VersionChangeEvent event) async {
    final db = event.database;

    // Utility to create object stores only if they don't exist
    void createStoreIfNotExists(String storeName, void Function() createStore) {
      if (!db.objectStoreNames.contains(storeName)) {
        createStore();
      }
    }

    createStoreIfNotExists('user_sellers', () {
      final store = db.createObjectStore('user_sellers', keyPath: 'sellerId');
      store.createIndex('sellerId', 'sellerId', unique: true);
    });

    createStoreIfNotExists('tariffs', () {
      final store =
          db.createObjectStore('tariffs', keyPath: 'id', autoIncrement: true);
      store.createIndex('storeId_type', ['storeId', 'type'], unique: true);
    });

    createStoreIfNotExists('supplies', () {
      final store =
          db.createObjectStore('supplies', keyPath: 'id', autoIncrement: true);
      store.createIndex('nmId_wh_sizeOptionId', ['nmId', 'wh', 'sizeOptionId'],
          unique: true);
    });

    createStoreIfNotExists('cards', () {
      db.createObjectStore('cards', keyPath: 'nmId');
    });

    createStoreIfNotExists('initial_stocks', () {
      final store = db.createObjectStore('initial_stocks',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('nmId_wh_sizeOptionId', ['nmId', 'wh', 'sizeOptionId'],
          unique: true);
    });

    createStoreIfNotExists('stocks', () {
      final store =
          db.createObjectStore('stocks', keyPath: 'id', autoIncrement: true);
      store.createIndex('nmId_wh_sizeOptionId', ['nmId', 'wh', 'sizeOptionId'],
          unique: true);
    });

    createStoreIfNotExists('orders', () {
      final store =
          db.createObjectStore('orders', keyPath: 'id', autoIncrement: true);
      store.createIndex('sku_warehouse_period', ['sku', 'warehouse', 'period'],
          unique: true);
    });

    createStoreIfNotExists('card_keywords', () {
      final store = db.createObjectStore('card_keywords',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('cardId_keyword_freq', ['cardId', 'keyword'],
          unique: true);
    });

    createStoreIfNotExists('cached_kw_by_autocomplite', () {
      db.createObjectStore('cached_kw_by_autocomplite', keyPath: 'keyword');
    });

    createStoreIfNotExists('cached_kw_by_lemma', () {
      final store =
          db.createObjectStore('cached_kw_by_lemma', keyPath: 'lemmaID');
      store.createIndex('lemmaID_keyword_freq', ['lemmaID', 'keyword'],
          unique: true);
    });

    createStoreIfNotExists('cached_kw_by_word', () {
      final store =
          db.createObjectStore('cached_kw_by_word', keyPath: 'lemmaID');
      store.createIndex('lemmaID_keyword_freq', ['lemmaID', 'keyword'],
          unique: true);
    });

    createStoreIfNotExists('filters', () {
      final store = db.createObjectStore('filters', autoIncrement: true);
      store.createIndex('sectionName_itemId', ['sectionName', 'itemId'],
          unique: true);
    });

    createStoreIfNotExists('tracking_results', () {
      final store =
          db.createObjectStore('tracking_results', autoIncrement: true);
      store.createIndex(
          'keyword_geo_product_date', ['keyword', 'geo', 'product_id', 'date'],
          unique: true);
    });

    createStoreIfNotExists('cached_lemmas', () {
      final store = db.createObjectStore('cached_lemmas', autoIncrement: true);
      store.createIndex('subjectId_lemma', ['subjectId', 'lemma'],
          unique: true);
    });

    createStoreIfNotExists('notifications', () {
      final store = db.createObjectStore('notifications',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('parentId_condition', ['parentId', 'condition'],
          unique: true);
    });

    createStoreIfNotExists('total_cost_calculator', () {
      db.createObjectStore('total_cost_calculator',
          keyPath: ['nmId', 'expenseName']);
    });

    createStoreIfNotExists('sellers', () {
      db.createObjectStore('sellers', keyPath: 'supplierId');
    });

    createStoreIfNotExists('subs', () {
      db.createObjectStore('subs', keyPath: 'id', autoIncrement: true);
    });

    createStoreIfNotExists('groups', () {
      final store = db.createObjectStore('groups', autoIncrement: true);
      store.createIndex('name_nmId', ['name', 'nmId'], unique: true);
    });

    // CardItems
  }

  Future<void> close() async {
    _database?.close();
  }
}
