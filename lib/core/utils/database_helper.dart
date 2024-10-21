import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

import 'package:rewild_bot_front/core/utils/telegram.dart';
import 'package:rewild_bot_front/env.dart';

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

    final db = await dbFactory.open(
      'mb.db',
      version: 4,
      onUpgradeNeeded: _onUpgrade,
    );

    return db;
  }

  Future<void> _onUpgrade(VersionChangeEvent event) async {
    final db = event.database;

    if (event.oldVersion < 1) {
      await _onCreate(event);
    }

    if (event.oldVersion < 3) {
      if (!db.objectStoreNames.contains('top_products')) {
        final store = db.createObjectStore('top_products', keyPath: 'sku');
        store.createIndex('total_orders', 'total_orders', unique: false);
        store.createIndex('total_revenue', 'total_revenue', unique: false);
        store.createIndex('subject_id', 'subject_id', unique: false);
        store.createIndex('name', 'name', unique: false);
        store.createIndex('supplier', 'supplier', unique: false);
        store.createIndex('review_rating', 'review_rating', unique: false);
        store.createIndex('feedbacks', 'feedbacks', unique: false);
        store.createIndex('img', 'img', unique: false);
        store.createIndex('last_updated', 'last_updated', unique: false);
      }
    }

    // if (event.oldVersion < 2) {
    //   if (!db.objectStoreNames.contains('subjects')) {
    //     final store = db.createObjectStore('subjects', keyPath: 'subjectId');
    //     store.createIndex('subjectId', 'subjectId', unique: true);
    //     store.createIndex('name', 'name', unique: false);
    //   }
    //   if (!db.objectStoreNames.contains('subject_commissions')) {
    //     final store =
    //         db.createObjectStore('subject_commissions', keyPath: 'id');
    //     store.createIndex('catName', 'catName', unique: false);
    //     store.createIndex('createdAt', 'createdAt', unique: false);
    //   }
    //   if (!db.objectStoreNames.contains('categories')) {
    //     final store =
    //         db.createObjectStore('categories', keyPath: 'categoryName');
    //     store.createIndex('categoryName', 'categoryName', unique: true);
    //     store.createIndex('updatedAt', 'updatedAt', unique: false);
    //   }
    // }
    // if (event.oldVersion < 3) {
    //   if (!db.objectStoreNames.contains('product_cards')) {
    //     final store =
    //         db.createObjectStore('product_cards', keyPath: ['sku', 'mp']);
    //     store.createIndex('sku', 'sku', unique: true);
    //     store.createIndex('img', 'img', unique: false);
    //     store.createIndex('mp', 'mp', unique: false);
    //   }
    // }

    // if (event.oldVersion < 4) {
    //   if (db.objectStoreNames.contains('product_cards')) {
    //     db.deleteObjectStore('product_cards');
    //     final store = db.createObjectStore('product_cards', keyPath: 'sku_mp');
    //     store.createIndex('sku', 'sku', unique: true);
    //     store.createIndex('img', 'img', unique: false);
    //     store.createIndex('mp', 'mp', unique: false);
    //   }
    // }
    // final db = event.database;                                            !!!
    // if (event.oldVersion < 5) {
    //   if (db.objectStoreNames.contains('product_cards')) {
    //     sendMessageToTelegramBot(
    //         TBot.tBotErrorToken, TBot.tBotErrorChatId, "contains");
    //     db.deleteObjectStore('product_cards');
    //     sendMessageToTelegramBot(
    //         TBot.tBotErrorToken, TBot.tBotErrorChatId, "deleteObjectStore");
    //     final store = event.transaction.objectStore(
    //       'product_cards',
    //     );

    //     sendMessageToTelegramBot(
    //         TBot.tBotErrorToken, TBot.tBotErrorChatId, "createObjectStore");
    //     store.createIndex('sku_mp', 'sku_mp', unique: true);
    //     store.createIndex('sku', 'sku', unique: true);
    //     store.createIndex('img', 'img', unique: false);
    //     store.createIndex('mp', 'mp', unique: false);
    //     sendMessageToTelegramBot(
    //         TBot.tBotErrorToken, TBot.tBotErrorChatId, "added indexes");
    //   }
    // }
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

    createStoreIfNotExists('top_products', () {
      final store = db.createObjectStore('top_products', keyPath: 'sku');
      store.createIndex('total_orders', 'total_orders', unique: false);
      store.createIndex('total_revenue', 'total_revenue', unique: false);
      store.createIndex('subject_id', 'subject_id', unique: false);
      store.createIndex('name', 'name', unique: false);
      store.createIndex('supplier', 'supplier', unique: false);
      store.createIndex('review_rating', 'review_rating', unique: false);
      store.createIndex('feedbacks', 'feedbacks', unique: false);
      store.createIndex('img', 'img', unique: false);
      store.createIndex('last_updated', 'last_updated',
          unique: false); // Поле для даты последнего обновления
    });

    createStoreIfNotExists('product_cards', () {
      final store = db.createObjectStore('product_cards', keyPath: 'sku_mp');
      store.createIndex('sku', 'sku', unique: true);
      store.createIndex('img', 'img', unique: false);
      store.createIndex('mp', 'mp', unique: false);
      store.createIndex('name', 'name', unique: false);
    });

    createStoreIfNotExists('subjects', () {
      final store = db.createObjectStore('subjects', keyPath: 'subjectId');
      store.createIndex('subjectId', 'subjectId', unique: true);
    });

    createStoreIfNotExists('subject_commissions', () {
      final store = db.createObjectStore('subject_commissions', keyPath: 'id');
      store.createIndex('catName', 'catName', unique: false);
      store.createIndex('createdAt', 'createdAt', unique: false);
    });
    createStoreIfNotExists('categories', () {
      final store = db.createObjectStore('categories', keyPath: 'categoryName');
      store.createIndex('categoryName', 'categoryName', unique: true);
      store.createIndex('updatedAt', 'updatedAt', unique: false);
    });
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
          keyPath: 'cardIdKeyword', autoIncrement: false);
      store.createIndex('cardId', 'cardId');
      store.createIndex('updatedAt', 'updatedAt');
    });

    createStoreIfNotExists('cached_kw_by_autocomplite', () {
      db.createObjectStore('cached_kw_by_autocomplite', keyPath: 'keyword');
    });

    createStoreIfNotExists('cached_kw_by_lemma', () {
      final store = db.createObjectStore('cached_kw_by_lemma',
          keyPath: 'lemmaID_keyword', autoIncrement: false);
      store.createIndex('lemmaID', 'lemmaID');
    });

    createStoreIfNotExists('cached_kw_by_word', () {
      final store = db.createObjectStore('cached_kw_by_word',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('lemmaID_keyword', ['lemmaID', 'keyword'],
          unique: true);
      store.createIndex('lemma', 'lemma'); // Добавляем индекс на поле 'lemma'
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
          keyPath: 'parentIdConditionWh', autoIncrement: false);

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
      db.createObjectStore('subs', keyPath: 'id', autoIncrement: false);
    });

    createStoreIfNotExists('subscribed_cards', () {
      db.createObjectStore('subscribed_cards',
          keyPath: 'sku', autoIncrement: false);
    });

    createStoreIfNotExists('groups', () {
      final store = db.createObjectStore('groups',
          keyPath: 'nmId_name', autoIncrement: false);

      store.createIndex('nmId', 'nmId', unique: false);
      store.createIndex('name', 'name', unique: false);
    });

    createStoreIfNotExists('nm_ids', () {
      db.createObjectStore('nm_ids', keyPath: 'nmId', autoIncrement: false);
    });

    createStoreIfNotExists('commissions', () {
      final store = db.createObjectStore('commissions',
          keyPath: 'id', autoIncrement: true);
      store.createIndex('id', 'id', unique: true);
    });

    // createStoreIfNotExists('filterValues', () {
    //   final store = db.createObjectStore('filterValues',
    //       keyPath: 'id', autoIncrement: true);
    //   store.createIndex('filterName', 'filterName', unique: false);
    //   store.createIndex('updatedAt', 'updatedAt', unique: false);
    // });
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

    createStoreIfNotExists('orders_history', () {
      db.createObjectStore('orders_history', keyPath: 'id', autoIncrement: true)
        ..createIndex('nmId', 'nmId', unique: false)
        ..createIndex('nmId_updatetAt', ['nmId', 'updatetAt'], unique: false);
    });
  }

  Future<void> cleanInvalidRecords() async {
    final db = await DatabaseHelper().database;
    final txn = db.transaction('groups', idbModeReadWrite);
    final store = txn.objectStore('groups');

    final result = await store.getAll();
    for (var item in result) {
      final map = item as Map<String, dynamic>;

      await store.delete(map['id']);
    }

    await txn.completed;
  }

  Future<void> clearTable(String storeName) async {
    final db = await database;
    final txn = db.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);

    try {
      await store.clear();
      await txn.completed;
    } catch (e) {
      sendMessageToTelegramBot(TBot.tBotErrorToken, TBot.tBotErrorChatId,
          "Failed to clear store $storeName: $e");
    }
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
