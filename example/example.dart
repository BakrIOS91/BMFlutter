import 'package:bmflutter/src/macros/macro_copy_with.dart';

@AutoCopyWith()
class Person {
  final String name;
  final int age;
  final String? email;

  Person({required this.name, required this.age, this.email});

  // Generated copyWith method using CopyWithCodeGenerator
  Person copyWith({
    String? name,
    int? age,
    String? email,
  }) {
    return Person(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
    );
  }
}

@AutoCopyWith()
class Product {
  final String id;
  final String title;
  final double price;
  final bool isAvailable;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.isAvailable,
  });

  // Generated copyWith method using CopyWithCodeGenerator
  Product copyWith({
    String? id,
    String? title,
    double? price,
    bool? isAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

void main() {
  final person = Person(name: 'John', age: 30, email: 'john@example.com');
  final updatedPerson = person.copyWith(age: 31);
  
  print('Original: ${person.name}, ${person.age}, ${person.email}');
  print('Updated: ${updatedPerson.name}, ${updatedPerson.age}, ${updatedPerson.email}');
  
  final product = Product(
    id: '1',
    title: 'Widget',
    price: 19.99,
    isAvailable: true,
  );
  
  final updatedProduct = product.copyWith(price: 24.99, isAvailable: false);
  
  print('Original Product: ${product.title}, \$${product.price}, Available: ${product.isAvailable}');
  print('Updated Product: ${updatedProduct.title}, \$${updatedProduct.price}, Available: ${updatedProduct.isAvailable}');
}
