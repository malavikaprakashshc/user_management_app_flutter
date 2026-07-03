import '../../domain/entities/user.dart';

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String image;
  final int age;
  final AddressModel address;
  final CompanyModel company;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.image,
    required this.age,
    required this.address,
    required this.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      image: json['image'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      address: AddressModel.fromJson(json['address'] as Map<String, dynamic>?),
      company: CompanyModel.fromJson(json['company'] as Map<String, dynamic>?),
    );
  }

  User toEntity() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      phone: phone,
      image: image,
      age: age,
      address: address.toEntity(),
      company: company.toEntity(),
    );
  }
}

class AddressModel {
  final String address;
  final String city;
  final String state;
  final String postalCode;

  AddressModel({
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AddressModel(address: '', city: '', state: '', postalCode: '');
    }
    return AddressModel(
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
    );
  }

  Address toEntity() {
    return Address(
      address: address,
      city: city,
      state: state,
      postalCode: postalCode,
    );
  }
}

class CompanyModel {
  final String name;
  final String title;
  final String department;

  CompanyModel({
    required this.name,
    required this.title,
    required this.department,
  });

  factory CompanyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CompanyModel(name: '', title: '', department: '');
    }
    return CompanyModel(
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      department: json['department'] as String? ?? '',
    );
  }

  Company toEntity() {
    return Company(
      name: name,
      title: title,
      department: department,
    );
  }
}
