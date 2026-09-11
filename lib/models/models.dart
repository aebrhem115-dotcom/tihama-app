class User {
  final int id;
  final String? name;
  final String phone;
  final String? email;
  final String? clientId;
  final String status;
  final String? lang;
  final String? memberId;
  final double? walletBalance;

  User({required this.id, this.name, required this.phone, this.email, this.clientId, this.status = 'active', this.lang, this.memberId, this.walletBalance});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'],
      clientId: json['client_id']?.toString(),
      status: json['status'] ?? 'active',
      lang: json['lang'],
      memberId: json['member_id'],
      walletBalance: json['wallet_balance']?.toDouble(),
    );
  }
}

class Wallet {
  final double balance;
  final String currency;
  Wallet({required this.balance, required this.currency});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      currency: json['currency'] ?? 'YER',
    );
  }
}

class Service {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? icon;
  final String? imageUrl;
  final String? color;
  final int? order;
  final String? serviceType;
  final String? targetRoute;
  final String? externalUrl;

  Service({required this.id, required this.nameAr, this.nameEn, this.icon, this.imageUrl, this.color, this.order, this.serviceType, this.targetRoute, this.externalUrl});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'],
      icon: json['icon'],
      imageUrl: json['image_url'],
      color: json['color'],
      order: json['order'],
      serviceType: json['service_type'],
      targetRoute: json['target_route'],
      externalUrl: json['external_url'],
    );
  }
}

class Game {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? logoUrl;
  final String? category;

  Game({required this.id, required this.nameAr, this.nameEn, this.logoUrl, this.category});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'],
      logoUrl: json['logo_url'],
      category: json['category'],
    );
  }
}

class Product {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? productType;
  final double unitPrice;
  final double? costPrice;
  final double? fee;
  final String? feeType;
  final String? currency;
  final String? priceSource;
  final List<ProductField>? fields;
  final Game? game;
  final App? app;
  final CardModel? card;

  Product({required this.id, required this.nameAr, this.nameEn, this.productType, this.unitPrice = 0, this.costPrice, this.fee, this.feeType, this.currency, this.priceSource, this.fields, this.game, this.app, this.card});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'],
      productType: json['product_type'],
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0,
      costPrice: double.tryParse(json['cost_price']?.toString() ?? '0'),
      fee: double.tryParse(json['fee']?.toString() ?? '0'),
      feeType: json['fee_type'],
      currency: json['currency'],
      priceSource: json['price_source'],
      fields: (json['fields'] as List?)?.map((f) => ProductField.fromJson(f)).toList(),
      game: json['game'] != null ? Game.fromJson(json['game']) : null,
      app: json['app'] != null ? App.fromJson(json['app']) : null,
      card: json['card'] != null ? CardModel.fromJson(json['card']) : null,
    );
  }
}

class ProductField {
  final String key;
  final String? labelAr;
  final String? labelEn;
  final String? type;
  final List? options;
  final String? placeholder;
  final bool required;

  ProductField({required this.key, this.labelAr, this.labelEn, this.type, this.options, this.placeholder, this.required = false});

  factory ProductField.fromJson(Map<String, dynamic> json) {
    return ProductField(
      key: json['key'] ?? '',
      labelAr: json['label_ar'],
      labelEn: json['label_en'],
      type: json['type'],
      options: json['options'],
      placeholder: json['placeholder'],
      required: json['required'] ?? false,
    );
  }
}

class App {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? logoUrl;
  final String? category;

  App({required this.id, required this.nameAr, this.nameEn, this.logoUrl, this.category});

  factory App.fromJson(Map<String, dynamic> json) {
    return App(
      id: json['id'] ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'],
      logoUrl: json['logo_url'],
      category: json['category'],
    );
  }
}

class CardModel {
  final int id;
  final String name;
  final dynamic price;
  final String? duration;
  final String? description;
  final String? provider;
  final String? status;

  CardModel({required this.id, required this.name, this.price, this.duration, this.description, this.provider, this.status});

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'],
      duration: json['duration'],
      description: json['description'],
      provider: json['provider'],
      status: json['status'],
    );
  }
}

class BannerModel {
  final int id;
  final String? title;
  final String? imageUrl;
  final String? description;
  final String? actionType;
  final String? actionValue;

  BannerModel({required this.id, this.title, this.imageUrl, this.description, this.actionType, this.actionValue});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'],
      imageUrl: json['image_url'],
      description: json['description'],
      actionType: json['action_type'],
      actionValue: json['action_value'],
    );
  }
}

class Order {
  final int id;
  final String uuid;
  final String status;
  final dynamic amount;
  final dynamic fee;
  final String? currency;
  final dynamic product;
  final String? providerReference;
  final String? errorMessage;
  final String? createdAt;
  final String? completedAt;

  Order({required this.id, required this.uuid, required this.status, this.amount, this.fee, this.currency, this.product, this.providerReference, this.errorMessage, this.createdAt, this.completedAt});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      status: json['status'] ?? 'pending',
      amount: json['amount'],
      fee: json['fee'],
      currency: json['currency'],
      product: json['product'],
      providerReference: json['provider_reference'],
      errorMessage: json['error_message'],
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
    );
  }

  double get amountValue => double.tryParse(amount?.toString() ?? '0') ?? 0;
  double get feeValue => double.tryParse(fee?.toString() ?? '0') ?? 0;

  String get statusLabel => switch (status) {
    'success' => 'ناجح',
    'failed' => 'فشل',
    'pending' => 'قيد التنفيذ',
    'cancelled' => 'ملغي',
    _ => status,
  };

  String get productName {
    if (product is Map) return product['name_ar'] ?? '';
    return '';
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String? body;
  final bool read;
  final String? imageUrl;
  final String? createdAt;

  NotificationModel({required this.id, required this.title, this.body, this.read = false, this.imageUrl, this.createdAt});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'],
      read: json['read'] ?? false,
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }
}

class SupportTicket {
  final int id;
  final String subject;
  final String status;
  final String priority;
  final String? createdAt;

  SupportTicket({required this.id, required this.subject, required this.status, this.priority = 'normal', this.createdAt});

  String get priorityLabel => switch (priority) {
    'high' => 'عالية',
    'low' => 'منخفضة',
    _ => 'عادية',
  };

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? 0,
      subject: json['subject'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'normal',
      createdAt: json['created_at'],
    );
  }

  String get priorityLabel => switch (priority) {
    'high' => 'أولوية عالية',
    'low' => 'أولوية منخفضة',
    _ => 'أولوية عادية',
  };
}

class SupportMessage {
  final int id;
  final String senderType;
  final String message;
  final String? createdAt;

  SupportMessage({required this.id, required this.senderType, required this.message, this.createdAt});

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] ?? 0,
      senderType: json['sender_type'] ?? '',
      message: json['body'] ?? '',
      createdAt: json['created_at'],
    );
  }

  bool get isMine => senderType == 'user';
}

class TransactionModel {
  final int id;
  final String type;
  final dynamic amount;
  final dynamic balanceAfter;
  final String? description;
  final String createdAt;

  TransactionModel({required this.id, required this.type, this.amount, this.balanceAfter, this.description, required this.createdAt});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      amount: json['amount'],
      balanceAfter: json['balance_after'],
      description: json['description'],
      createdAt: json['created_at'] ?? '',
    );
  }

  double get amountValue => double.tryParse(amount.toString()) ?? 0;
  bool get isCredit => type == 'credit' || type == 'deposit' || type == 'topup';
}