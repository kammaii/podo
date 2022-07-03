class Premium {
  final String id;
  final double dateStart;
  final double dateEnd;
  final String tag; // purchase, reward
  final String? item;
  final double? price;

  Premium({
    required this.id,
    required this.dateStart,
    required this.dateEnd,
    required this.tag,
    this.item,
    this.price,
  });
}