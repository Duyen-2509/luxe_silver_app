class VoucherModel {
  final int? id;
  final int minOrder;
  final int discount;
  final int quantity;
  final String? content;
  final String type;
  final String dateStart;
  final String dateEnd;

  VoucherModel({
    this.id,
    required this.minOrder,
    required this.discount,
    required this.quantity,
    this.content,
    required this.type,
    required this.dateStart,
    required this.dateEnd,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      minOrder: json['min_order'],
      discount: json['discount'],
      quantity: json['quantity'],
      content: json['content'],
      type: json['type'],
      dateStart: json['date_start'],
      dateEnd: json['date_end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'min_order': minOrder,
      'discount': discount,
      'quantity': quantity,
      'content': content,
      'type': type,
      'date_start': dateStart,
      'date_end': dateEnd,
    };
  }
}
