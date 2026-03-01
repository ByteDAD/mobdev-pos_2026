class PurchaseLine {
  const PurchaseLine({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  double get subtotal => unitPrice * quantity;
}

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.code,
    required this.supplierId,
    required this.supplierName,
    required this.user,
    required this.createdAt,
    required this.status,
    required this.lines,
  });

  final int id;
  final String code;
  final int supplierId;
  final String supplierName;
  final String user;
  final DateTime createdAt;
  final String status;
  final List<PurchaseLine> lines;

  PurchaseOrder copyWith({
    String? status,
  }) {
    return PurchaseOrder(
      id: id,
      code: code,
      supplierId: supplierId,
      supplierName: supplierName,
      user: user,
      createdAt: createdAt,
      status: status ?? this.status,
      lines: lines,
    );
  }
}
