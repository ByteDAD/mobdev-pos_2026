class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.bankAccount,
    required this.address,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String mobile;
  final String bankAccount;
  final String address;
  final String imageUrl;

  Supplier copyWith({
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    String? mobile,
    String? bankAccount,
    String? address,
    String? imageUrl,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      bankAccount: bankAccount ?? this.bankAccount,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
