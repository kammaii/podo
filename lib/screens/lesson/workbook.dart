class Workbook {

  late String id;
  late int orderId;
  late String title;
  late String image;
  late List<dynamic> sampleImages;
  late String storeLink;
  late String productId;
  late List<dynamic> lessons;
  late bool hasFreeOption;
  late String pdfFile;

  static const String ID = 'id';
  static const String ORDER_ID = 'orderId';
  static const String TITLE = 'title';
  static const String IMAGE = 'image';
  static const String SAMPLE_IMAGES = 'sampleImages';
  static const String STORE_LINK = 'storeLink';
  static const String PRODUCT_ID = 'productId';
  static const String LESSONS = 'lessons';
  static const String HAS_FREE_OPTION = 'hasFreeOption';
  static const String PDF_FILE = 'pdfFile';

  Workbook.fromJson(Map<String, dynamic> json) {
    id = json[ID];
    orderId = json[ORDER_ID];
    title = json[TITLE];
    image = json[IMAGE];
    sampleImages = json[SAMPLE_IMAGES];
    storeLink = json[STORE_LINK];
    productId = json[PRODUCT_ID];
    lessons = json[LESSONS];
    hasFreeOption = json[HAS_FREE_OPTION];
    pdfFile = json[PDF_FILE];
  }
}