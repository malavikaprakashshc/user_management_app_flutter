class User {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String image;
  final int age;
  final Address address;
  final Company company;

  const User({
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

  String get fullName => '$firstName $lastName';
}

class Address {
  final String address;
  final String city;
  final String state;
  final String postalCode;

  const Address({
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  String get fullAddress => '$address, $city, $state $postalCode';
}

class Company {
  final String name;
  final String title;
  final String department;

  const Company({
    required this.name,
    required this.title,
    required this.department,
  });
}
