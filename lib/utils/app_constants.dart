class AppConstants {
  static List<Option> optionList = [
    Option(name: "Rented"),
    Option(name: "Condo"),
    Option(name: "Building"),
    Option(name: "HDB"),
    Option(name: "Land"),
    Option(name: "Office"),
    Option(name: "Shophouse"),
    Option(name: "Retail"),
    Option(name: "Other"),
  ];

  static List<Option> listingTypes = [
    Option(name: "For Sale"),
    Option(name: "For Rent"),
  ];
}

class Option {
  final String name;
  Option({required this.name});
}
