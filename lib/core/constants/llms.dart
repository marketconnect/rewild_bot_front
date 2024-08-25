enum LLMName { gigaChat, gigaChatPlus, gigaChatPro, yandexGpt }

class LLM {
  final String name;
  final List<String> params;
  final int? pricePerMillionTokens;

  const LLM._(this.name, this.params, this.pricePerMillionTokens);

  static const List<String> _defaultGigachatParams = [
    "ClientId",
    "ClientSecret"
  ];

  const LLM.gigaChat({int? pricePerMillionTokens})
      : name = "GigaChat",
        params = _defaultGigachatParams,
        pricePerMillionTokens = pricePerMillionTokens ?? 0;

  const LLM.gigaChatPlus({int? pricePerMillionTokens})
      : name = "GigaChat-Plus",
        params = _defaultGigachatParams,
        pricePerMillionTokens = pricePerMillionTokens ?? 0;

  const LLM.gigaChatPro({int? pricePerMillionTokens})
      : name = "GigaChat-Pro",
        params = _defaultGigachatParams,
        pricePerMillionTokens = pricePerMillionTokens ?? 0;

  // copyWith
  LLM copyWith({
    String? name,
    List<String>? params,
    int? pricePerMillionTokens,
  }) {
    return LLM._(
      name ?? this.name,
      params ?? this.params,
      pricePerMillionTokens ?? this.pricePerMillionTokens,
    );
  }

  LLM getModel(LLMName name) {
    switch (name) {
      case LLMName.gigaChat:
        return const LLM.gigaChat();
      case LLMName.gigaChatPlus:
        return const LLM.gigaChatPlus();
      case LLMName.gigaChatPro:
        return const LLM.gigaChatPro();

      default:
        return const LLM.gigaChat();
    }
  }
}

// Пример использования:
const List<LLM> llms = [
  LLM.gigaChat(),
  LLM.gigaChatPlus(),
  LLM.gigaChatPro(),
];
