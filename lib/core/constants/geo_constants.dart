Map<String, String> geoDistance = {
  'Москва': '-1257218',
  'Санкт-Петербург': '-1257786',
  'Минск': '-59252',
  'Екатеринбург': '-5817698',
  'Краснодар': '12358058',
  'Казань': '-2133462',
  'Омск': '-3902444',
  'Новосибирск': '-365401',
  'Новый Уренгой': '123585917',
  'Красноярск': '-5854093',
  'Алматы': '232',
  'Норильск': '123586210',
  'Иркутск': '-5827226',
  'Якутск': '123585755',
  'Магадан': '123585707',
  'Владивосток': '123586013'
};
String geoDistanceKey(String city) {
  return geoDistance[city] ?? geoDistance.entries.first.key;
}

String getDistanceCity(String dist) {
  return geoDistance.entries
      .firstWhere((entry) => entry.value == dist,
          orElse: () => const MapEntry('', ''))
      .key;
}
