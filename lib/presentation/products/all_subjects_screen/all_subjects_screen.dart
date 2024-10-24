import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:provider/provider.dart';
import 'package:rewild_bot_front/core/constants/image_constant.dart';
import 'package:rewild_bot_front/presentation/products/all_subjects_screen/all_subjects_view_model.dart';

class AllSubjectsScreen extends StatelessWidget {
  const AllSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllSubjectsViewModel>();
    final subjects = model.subjects;
    final isLoading = model.isLoading;

    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      overlayBackgroundColor: Colors.black,
      circularProgressColor: const Color(0xff83735c),
      appIcon: Image.asset(ImageConstant.imgLogoForLoading),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Все предметы',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1f1f1f),
            ),
          ),
          centerTitle: true,
          elevation: 2,
          shadowColor: Colors.black54,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Color(0xFF1f1f1f)),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (String result) {
                model.sortSubjects(result);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'alphabeticalAsc',
                  child: Text('По алфавиту'),
                ),
                const PopupMenuItem<String>(
                  value: 'percentageSkusWithoutOrdersAsc',
                  child: Text('По товарам без заказов'),
                ),
                const PopupMenuItem<String>(
                  value: 'totalVolumeDesc',
                  child: Text('По объему поисковых запросов'),
                ),
                const PopupMenuItem<String>(
                    value: 'totalOrdersDesc',
                    child: Text('По количеству заказов')),
                const PopupMenuItem<String>(
                    value: 'totalRevenueDesc',
                    child: Text('По суммарной выручке заказов')),
                const PopupMenuItem<String>(
                    value: 'averageCheck', child: Text('По среднему чеку')),
                const PopupMenuItem<String>(
                    value: 'conversionToOrdersDesc',
                    child: Text('По конверсии в заказ')),
              ],
            ),
          ],
        ),
        body: subjects.isEmpty
            ? const Center(child: Text('Предметы отсутствуют.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final commission = model.getCommission(subject.subjectId);
                  final bool isKiz = commission.isKiz;
                  final conversionInOrder = subject.conversionInOrder();
                  final goToSubject = model.goToSubject;
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        goToSubject(subject.subjectId, subject.name);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                if (isKiz)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'KIZ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.percent,
                              'Комиссия WB',
                              '${commission.commission}%',
                            ),
                            _buildInfoRow(
                              Icons.show_chart,
                              'Конверсия в заказ',
                              conversionInOrder < 100
                                  ? '${conversionInOrder.toStringAsFixed(2)}%'
                                  : '—',
                            ),
                            _buildInfoRow(
                              Icons.shopping_cart,
                              'Всего заказов',
                              '${subject.totalOrders} шт.',
                              showInfoIcon: subject.totalOrders < 100,
                              onInfoIconPressed: () =>
                                  _showZeroOrdersInfoDialog(context),
                            ),
                            _buildInfoRow(
                              Icons.attach_money,
                              'На сумму',
                              '${_formatString(subject.totalRevenue)} ₽',
                            ),
                            _buildInfoRow(
                              Icons.inventory,
                              'Всего товаров',
                              '${subject.totalSkus}',
                            ),
                            _buildInfoRow(
                              Icons.remove_shopping_cart,
                              'Товары без заказов',
                              '${subject.percentageSkusWithoutOrders}%',
                            ),
                            _buildInfoRow(
                              Icons.search,
                              'Объем поисковых запросов',
                              '${subject.totalVolume}',
                            ),
                            _buildInfoRow(
                              Icons.receipt_long,
                              'Средний чек',
                              '${subject.averageCheck()} ₽',
                            ),
                            // _buildInfoRow(
                            //   Icons.monetization_on,
                            //   'Ожидаемый CPM',
                            //   '${subject.cpmAverage.toStringAsFixed(0)} ₽',
                            // ),
                            // _buildInfoRow(
                            //   Icons.paid,
                            //   'Ожидаемый CPA',
                            //   conversionInOrder > 0
                            //       ? '${(subject.cpmAverage / (conversionInOrder * 10)).toStringAsFixed(0)} ₽'
                            //       : '—',
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showZeroOrdersInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Информация'),
          content: const Text(
            'Учитываются заказы только для первых двух страниц поисковой выдачи миллиона самых популярных запросов предыдущей недели. С остальных страниц поисковой выдачи заказы не учитываются.',
          ),
          actions: [
            TextButton(
              child: const Text('Понятно'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatString(int input) {
    return input.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]} ');
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool showInfoIcon = false,
    VoidCallback? onInfoIconPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showInfoIcon && onInfoIconPressed != null)
                IconButton(
                  icon: const Icon(Icons.info_outline,
                      color: Colors.blueGrey, size: 20),
                  onPressed: onInfoIconPressed,
                ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1f1f1f),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Информация'),
          content: const Text(
            'Данные предоставляются за последнюю календарную неделю и охватывают первые две страницы поисковой выдачи для миллиона самых популярных запросов.',
          ),
          actions: [
            TextButton(
              child: const Text('Понятно'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Подробнее'),
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем текущий диалог
                _showDetailsDialog(context); // Открываем новый диалог
              },
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context) {
    final infoItems = [
      {
        'title': 'Комиссия WB',
        'description':
            'Комиссия, которую взимает маркетплейс Wildberries с поставщиков в данной категории, не считая логистики и стоимости хранения.',
      },
      {
        'title': 'Конверсия в заказ',
        'description':
            'Показатель, отражающий эффективность категории в превращении интереса покупателей в реальные продажи.\n\n**Как рассчитывается:**\n\n1. **Сбор популярных запросов:** Берётся миллион самых популярных поисковых запросов за последнюю неделю.\n\n2. **Определение участия категории:** Для каждого запроса вычисляется доля товаров вашей категории среди первых двух страниц выдачи (примерно 200 товаров). Например, если в выдаче по запросу ваша категория занимает 30%, то доля участия составляет 0,3.\n\n3. **Расчёт вклада категории в запрос:** Доля участия категории умножается на частотность запроса (количество поисков за неделю), получая вклад категории в этот запрос.\n\n4. **Суммирование вкладов:** Вклады по всем запросам суммируются, получая общий объём поисковых запросов для категории.\n\n5. **Расчёт конверсии в заказ:**\n\nКонверсия в заказ (%) = (Всего заказов / Общий объём поисковых запросов) × 100',
      },
      {
        'title': 'Всего заказов',
        'description':
            'Общее количество заказов, сделанных в данной категории за последнюю неделю.',
      },
      {
        'title': 'На сумму',
        'description':
            'Суммарная выручка от заказов в данной категории за последнюю неделю.',
      },
      {
        'title': 'Всего товаров',
        'description':
            'Общее количество товаров, представленных в данной категории на первых двух страницах поисковой выдачи для миллиона самых популярных запросов.',
      },
      {
        'title': 'Товары без заказов',
        'description':
            'Процент товаров в категории, которые не имели заказов за последнюю неделю.',
      },
      {
        'title': 'Объем поисковых запросов',
        'description':
            '\n\n**Как рассчитывается:**\n\n1. **Сбор популярных запросов:** Берётся миллион самых популярных поисковых запросов за последнюю неделю.\n\n2. **Определение участия категории:** Для каждого запроса вычисляется доля товаров вашей категории среди первых двух страниц выдачи (примерно 200 товаров). Например, если в выдаче по запросу ваша категория занимает 30%, то доля участия составляет 0,3.\n\n3. **Расчёт вклада категории в запрос:** Доля участия категории умножается на частотность запроса (количество поисков за неделю), получая вклад категории в этот запрос.\n\n4. **Суммирование вкладов:** Вклады по всем запросам суммируются, получая общий объём поисковых запросов для категории.\n\n',
      },
      {
        'title': 'Средний чек',
        'description':
            'Средняя сумма, потраченная на один заказ в данной категории.\n\nРасчет:\nСредний чек = Суммарная выручка / Общее количество заказов',
      },
      // {
      //   'title': 'Ожидаемый CPM',
      //   'description':
      //       'Ожидаемая стоимость тысячи показов рекламного объявления для новой карточки в данной категории (берется стоимость показов в автоматических кампаниях с бустингом с нижних позиций на первую страницу).',
      // },
      // {
      //   'title': 'Ожидаемый CPA',
      //   'description':
      //       'Ожидаемая стоимость привлечения одного покупателя в данной категории.\n\nРасчет:\nCPA = CPM / (конверсия в заказ * 10)',
      // },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подробнее'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: infoItems.length,
              itemBuilder: (context, index) {
                final item = infoItems[index];
                return ListTile(
                  title: Text(item['title']!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pop(); // Закрываем список
                    _showItemDetailDialog(
                        context, item['title']!, item['description']!);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Назад'),
              onPressed: () {
                Navigator.of(context).pop();
                _showInfoDialog(context); // Возвращаемся к предыдущему диалогу
              },
            ),
          ],
        );
      },
    );
  }

  void _showItemDetailDialog(
      BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.6, // Ограничиваем высоту
            ),
            child: SingleChildScrollView(
              child: Text(description),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Назад'),
              onPressed: () {
                Navigator.of(context).pop();
                _showDetailsDialog(context); // Возвращаемся к списку
              },
            ),
          ],
        );
      },
    );
  }
}
