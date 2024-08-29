import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:rewild_bot_front/.env.dart';
import 'package:rewild_bot_front/core/utils/telegram.dart';

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
    final dbFactory = getIdbFactory();
    if (dbFactory == null) {
      throw Exception("Failed to get IDB factory.");
    }

    // Открываем базу данных и обновляем её при необходимости
    final db = await dbFactory.open(
      'b_rewild.db',
      version: 1,
      onUpgradeNeeded: _onUpgrade,
    );

    return db;
  }

  Future<void> _onUpgrade(VersionChangeEvent event) async {
    sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
        "${event.oldVersion} -> ${event.newVersion}");
    if (event.oldVersion < 1) {
      await _onCreate(event);
    }
    // final db = event.database;
    // if (event.oldVersion < 2) {
    //   if (!db.objectStoreNames.contains('keywords')) {
    //     final store = db.createObjectStore('keywords',
    //         keyPath: 'campaignId_keyword', autoIncrement: false);
    //     store.createIndex('keyword', 'keyword', unique: false);
    //     store.createIndex('campaignId', 'campaignId', unique: false);

    //     // final store = db.createObjectStore('tracking_queries',
    //     //     keyPath: 'id', autoIncrement: true);
    //     // store.createIndex('nmId', 'nmId', unique: false);
    //     // store.createIndex('query_geo', ['query', 'geo'], unique: false);
    //   }
    // }
    // Do not delete me !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // final db = event.database;                                            !!!
    // if (event.oldVersion < 2) {                                           !!!
    //   if (db.objectStoreNames.contains('initial_stocks')) {               !!!
    //     final store = event.transaction.objectStore('initial_stocks');    !!!
    //     if (!store.indexNames.contains('nmId_date')) {                    !!!
    //       store.createIndex('nmId_date', ['nmId', 'date']);               !!!
    //     }                                                                 !!!
    //   }                                                                   !!!
    // }                                                                     !!!
    //                                                                       !!!
    // if (event.oldVersion < 5) {                                           !!!
    //   if (db.objectStoreNames.contains('initial_stocks')) {               !!!
    //     final store = event.transaction.objectStore('initial_stocks');    !!!
    //     if (!store.indexNames.contains('nmId_wh_size_date')) {            !!!
    //       store.createIndex(                                              !!!
    //       'nmId_wh_size_date', ['nmId', 'wh', 'sizeOptionId', 'date']);   !!!
    //     }                                                                 !!!
    //   }                                                                   !!!
    // }                                                                     !!!
    // Do not delete me !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
      db.createObjectStore('tariffs',
          keyPath: 'whIdwhType', autoIncrement: false); // Указываем keyPath
    });

    createStoreIfNotExists('supplies', () {
      final store = db.createObjectStore('supplies', autoIncrement: true);
      store.createIndex('nmId_wh_sizeOptionId', ['nmId', 'wh', 'sizeOptionId'],
          unique: true);
    });

    createStoreIfNotExists('cards', () {
      db.createObjectStore('cards', keyPath: 'nmId');
    });

    createStoreIfNotExists('initial_stocks', () {
      final store = db.createObjectStore('initial_stocks',
          keyPath: 'nmIdWhSizeOptionId', autoIncrement: false);

      store.createIndex('nmId_wh_sizeOptionId', ['nmId', 'wh', 'sizeOptionId'],
          unique: true);

      store.createIndex('nmId_date', ['nmId', 'date']);

      store.createIndex(
          'nmId_wh_size_date', ['nmId', 'wh', 'sizeOptionId', 'date']);
    });

    createStoreIfNotExists('stocks', () {
      final store = db.createObjectStore('stocks',
          keyPath: 'nmIdWhSizeOptionId', autoIncrement: false);

      store.createIndex('nmId', 'nmId', unique: false);
    });

    createStoreIfNotExists('keywords', () {
      final store = db.createObjectStore('keywords',
          keyPath: 'campaignIdKeyword', autoIncrement: false);
      store.createIndex('keyword', 'keyword', unique: false);
      store.createIndex('campaignId', 'campaignId', unique: false);
    });

    createStoreIfNotExists('answers', () {
      db.createObjectStore('answers', keyPath: 'id', autoIncrement: true);
    });

    createStoreIfNotExists('orders', () {
      final store = db.createObjectStore('orders',
          keyPath: 'skuWarehousePeriod', autoIncrement: false);

      store.createIndex('sku', 'sku', unique: false);
      store.createIndex('updatedAt', 'updatedAt', unique: false);
    });

    createStoreIfNotExists('card_keywords', () {
      final store = db.createObjectStore('card_keywords',
          keyPath: 'cardId', autoIncrement: true);
      store.createIndex('cardId', 'cardId');
      store.createIndex('updatedAt', 'updatedAt');
      store.createIndex('cardId_keyword', ['cardId', 'keyword'], unique: true);
    });

    createStoreIfNotExists('cached_kw_by_autocomplite', () {
      db.createObjectStore('cached_kw_by_autocomplite', keyPath: 'keyword');
    });

    createStoreIfNotExists('cached_kw_by_lemma', () {
      final store = db.createObjectStore('cached_kw_by_lemma',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('lemmaID_keyword', ['lemmaID', 'keyword'],
          unique: true);
    });

    createStoreIfNotExists('cached_kw_by_word', () {
      final store = db.createObjectStore('cached_kw_by_word',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('lemmaID_keyword', ['lemmaID', 'keyword'],
          unique: true);
      store.createIndex('lemma', 'lemma'); // Добавляем индекс на поле 'lemma'
    });

    createStoreIfNotExists('filters', () {
      final store =
          db.createObjectStore('filters', keyPath: 'id', autoIncrement: true);
      store.createIndex('sectionName_itemId', ['sectionName', 'itemId'],
          unique: true);
    });

    createStoreIfNotExists('tracking_results', () {
      final store = db.createObjectStore('tracking_results',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('date', 'date');
      store.createIndex('keyword_geo_date', ['keyword', 'geo', 'date']);
      store.createIndex(
          'keyword_geo_product_date', ['keyword', 'geo', 'product_id', 'date'],
          unique: true);
    });

    createStoreIfNotExists('cached_lemmas', () {
      final store = db.createObjectStore('cached_lemmas',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('subjectId_lemmaId', ['subjectId', 'lemmaId'],
          unique: true);
      store.createIndex('subjectId', 'subjectId');
    });

    createStoreIfNotExists('notifications', () {
      final store = db.createObjectStore('notifications',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('parentId_condition', ['parentId', 'condition'],
          unique: true);
      store.createIndex('parentId', 'parentId');
      store.createIndex('condition', 'condition');
    });

    createStoreIfNotExists('total_cost_calculator', () {
      final store = db.createObjectStore('total_cost_calculator',
          keyPath: "nmId_expenseName", autoIncrement: false);
      store.createIndex('nmId', 'nmId', unique: false);
    });

    createStoreIfNotExists('sellers', () {
      db.createObjectStore('sellers', keyPath: 'supplierId');
    });

    createStoreIfNotExists('subs', () {
      final store =
          db.createObjectStore('subs', keyPath: 'id', autoIncrement: true);
      store.createIndex('card_id', 'card_id', unique: true);
      store.createIndex('end_date', 'end_date');
    });

    createStoreIfNotExists('groups', () {
      final store =
          db.createObjectStore('groups', keyPath: 'id', autoIncrement: true);
      store.createIndex('nmId_name', ['nmId', 'name'], unique: true);
    });

    createStoreIfNotExists('nm_ids', () {
      db.createObjectStore('nm_ids', keyPath: 'nmId', autoIncrement: false);
    });

    createStoreIfNotExists('commissions', () {
      final store = db.createObjectStore('commissions',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('id', 'id', unique: true);
    });

    createStoreIfNotExists('filterValues', () {
      final store = db.createObjectStore('filterValues',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('filterName', 'filterName', unique: false);
      store.createIndex('updatedAt', 'updatedAt', unique: false);
    });
    createStoreIfNotExists('seo_kw_by_lemma', () {
      final store =
          db.createObjectStore('seo_kw_by_lemma', keyPath: ['nmId', 'keyword']);
      store.createIndex('lemma', 'lemma', unique: false);
      store.createIndex('nmId', 'nmId', unique: false);
      store.createIndex('freq', 'freq', unique: false);
      store.createIndex('lemmaID', 'lemmaID', unique: false);
    });

    createStoreIfNotExists('tracking_queries', () {
      final store = db.createObjectStore('tracking_queries',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('nmId', 'nmId', unique: false);
      store.createIndex('query_geo', ['query', 'geo'], unique: false);
    });

    db.createObjectStore('orders_history', keyPath: 'id', autoIncrement: true)
      ..createIndex('nmId', 'nmId', unique: false)
      ..createIndex('nmId_updatetAt', ['nmId', 'updatetAt'], unique: false);
  }

  Future<void> cleanInvalidRecords() async {
    final db = await DatabaseHelper().database;
    final txn = db.transaction('stocks', idbModeReadWrite);
    final store = txn.objectStore('stocks');

    final result = await store.getAll();
    for (var item in result) {
      final map = item as Map<String, dynamic>;

      await store.delete(map['id']);
    }

    await txn.completed;
  }

  Future<void> clearAllTables() async {
    final db = await database;

    final storeNames = db.objectStoreNames;

    for (var storeName in storeNames) {
      final txn = db.transaction(storeName, idbModeReadWrite);
      final store = txn.objectStore(storeName);

      try {
        await store.clear();
        await txn.completed;
        sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
            "Successfully cleared store: $storeName");
      } catch (e) {
        sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
            "Failed to clear store $storeName: $e");
      }
    }
  }

  Future<void> checkDatabaseIntegrity() async {
    final db = await DatabaseHelper().database;
    final txn = db.transaction('stocks', idbModeReadOnly);
    final store = txn.objectStore('stocks');

    final result = await store.getAll();

    for (var item in result) {
      final map = item as Map<String, dynamic>;
      if (map['nmId'] == null) {
        sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
            "Error: Missing nmId in record: $map");
        // print("Error: Missing nmId in record: $map");
      }
    }

    await txn.completed;
  }

  Future<void> close() async {
    _database?.close();
  }
}
