class RealizationReport {
  final int realizationreportId;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime? createDt;
  final String? currencyName;
  final String? suppliercontractCode;
  final int? rrdId;
  final int? giId;
  final String? subjectName;
  final int? nmId;
  final String? brandName;
  final String? saName;
  final String? tsName;
  final String? barcode;
  final String? docTypeName;
  final int? quantity;
  final double? retailPrice;
  final double? retailAmount;
  final double? salePercent;
  final double? commissionPercent;
  final String? officeName;
  final String? supplierOperName;
  final DateTime? orderDt;
  final DateTime? saleDt;
  final DateTime? rrDt;
  final int? shkId;
  final double? retailPriceWithdiscRub;
  final double? deliveryAmount;
  final double? returnAmount;
  final double? deliveryRub;
  final String? giBoxTypeName;
  final double? productDiscountForReport;
  final double? supplierPromo;
  final int? rid;
  final double? ppvzSppPrc;
  final double? ppvzKvwPrcBase;
  final double? ppvzKvwPrc;
  final double? supRatingPrcUp;
  final int? isKgvpV2;
  final double? ppvzSalesCommission;
  final double? ppvzForPay;
  final double? ppvzReward;
  final double? acquiringFee;
  final String? acquiringBank;
  final double? ppvzVw;
  final double? ppvzVwNds;
  final int? ppvzOfficeId;
  final String? ppvzOfficeName;
  final int? ppvzSupplierId;
  final String? ppvzSupplierName;
  final String? ppvzInn;
  final String? declarationNumber;
  final String? bonusTypeName;
  final String? stickerId;
  final String? siteCountry;
  final double? penalty;
  final double? additionalPayment;
  final double? rebillLogisticCost;
  final String? rebillLogisticOrg;
  final String? kiz;
  final String? srid;
  final double? storageFee;
  final double? deduction;

  RealizationReport({
    required this.realizationreportId,
    required this.dateFrom,
    required this.dateTo,
    this.createDt,
    this.currencyName,
    this.suppliercontractCode,
    this.rrdId,
    this.giId,
    this.subjectName,
    this.nmId,
    this.brandName,
    this.saName,
    this.tsName,
    this.barcode,
    this.docTypeName,
    this.quantity,
    this.retailPrice,
    this.retailAmount,
    this.salePercent,
    this.commissionPercent,
    this.officeName,
    this.supplierOperName,
    this.orderDt,
    this.saleDt,
    this.rrDt,
    this.shkId,
    this.retailPriceWithdiscRub,
    this.deliveryAmount,
    this.returnAmount,
    this.deliveryRub,
    this.giBoxTypeName,
    this.productDiscountForReport,
    this.supplierPromo,
    this.rid,
    this.ppvzSppPrc,
    this.ppvzKvwPrcBase,
    this.ppvzKvwPrc,
    this.supRatingPrcUp,
    this.isKgvpV2,
    this.ppvzSalesCommission,
    this.ppvzForPay,
    this.ppvzReward,
    this.acquiringFee,
    this.acquiringBank,
    this.ppvzVw,
    this.ppvzVwNds,
    this.ppvzOfficeId,
    this.ppvzOfficeName,
    this.ppvzSupplierId,
    this.ppvzSupplierName,
    this.ppvzInn,
    this.declarationNumber,
    this.bonusTypeName,
    this.stickerId,
    this.siteCountry,
    this.penalty,
    this.additionalPayment,
    this.rebillLogisticCost,
    this.rebillLogisticOrg,
    this.kiz,
    this.srid,
    this.storageFee,
    this.deduction,
  });

  factory RealizationReport.fromJson(Map<String, dynamic> json) {
    return RealizationReport(
      realizationreportId: json['realizationreport_id'],
      dateFrom: DateTime.parse(json['date_from']),
      dateTo: DateTime.parse(json['date_to']),
      createDt:
          json['create_dt'] != null ? DateTime.parse(json['create_dt']) : null,
      currencyName: json['currency_name'],
      suppliercontractCode: json['suppliercontract_code'],
      rrdId: json['rrd_id'],
      giId: json['gi_id'],
      subjectName: json['subject_name'],
      nmId: json['nm_id'],
      brandName: json['brand_name'],
      saName: json['sa_name'],
      tsName: json['ts_name'],
      barcode: json['barcode'],
      docTypeName: json['doc_type_name'],
      quantity: json['quantity'],
      retailPrice: json['retail_price']?.toDouble(),
      retailAmount: json['retail_amount']?.toDouble(),
      salePercent: json['sale_percent']?.toDouble(),
      commissionPercent: json['commission_percent']?.toDouble(),
      officeName: json['office_name'],
      supplierOperName: json['supplier_oper_name'],
      orderDt:
          json['order_dt'] != null ? DateTime.parse(json['order_dt']) : null,
      saleDt: json['sale_dt'] != null ? DateTime.parse(json['sale_dt']) : null,
      rrDt: json['rr_dt'] != null ? DateTime.parse(json['rr_dt']) : null,
      shkId: json['shk_id'],
      retailPriceWithdiscRub: json['retail_price_withdisc_rub']?.toDouble(),
      deliveryAmount: json['delivery_amount']?.toDouble(),
      returnAmount: json['return_amount']?.toDouble(),
      deliveryRub: json['delivery_rub']?.toDouble(),
      giBoxTypeName: json['gi_box_type_name'],
      productDiscountForReport: json['product_discount_for_report']?.toDouble(),
      supplierPromo: json['supplier_promo']?.toDouble(),
      rid: json['rid'],
      ppvzSppPrc: json['ppvz_spp_prc']?.toDouble(),
      ppvzKvwPrcBase: json['ppvz_kvw_prc_base']?.toDouble(),
      ppvzKvwPrc: json['ppvz_kvw_prc']?.toDouble(),
      supRatingPrcUp: json['sup_rating_prc_up']?.toDouble(),
      isKgvpV2: json['is_kgvp_v2'],
      ppvzSalesCommission: json['ppvz_sales_commission']?.toDouble(),
      ppvzForPay: json['ppvz_for_pay']?.toDouble(),
      ppvzReward: json['ppvz_reward']?.toDouble(),
      acquiringFee: json['acquiring_fee']?.toDouble(),
      acquiringBank: json['acquiring_bank'],
      ppvzVw: json['ppvz_vw']?.toDouble(),
      ppvzVwNds: json['ppvz_vw_nds']?.toDouble(),
      ppvzOfficeId: json['ppvz_office_id'],
      ppvzOfficeName: json['ppvz_office_name'],
      ppvzSupplierId: json['ppvz_supplier_id'],
      ppvzSupplierName: json['ppvz_supplier_name'],
      ppvzInn: json['ppvz_inn'],
      declarationNumber: json['declaration_number'],
      bonusTypeName: json['bonus_type_name'],
      stickerId: json['sticker_id'],
      siteCountry: json['site_country'],
      penalty: json['penalty']?.toDouble(),
      additionalPayment: json['additional_payment']?.toDouble(),
      rebillLogisticCost: json['rebill_logistic_cost']?.toDouble(),
      rebillLogisticOrg: json['rebill_logistic_org'],
      kiz: json['kiz'],
      srid: json['srid'],
      storageFee: json['storage_fee']?.toDouble(),
      deduction: json['deduction']?.toDouble(),
    );
  }
}
