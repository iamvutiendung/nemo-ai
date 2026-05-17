import '../models/resource_item.dart';

class ResourceService {
  static final List<ResourceItem> _items = [];

  static List<ResourceItem> getItems() {
    return List.unmodifiable(_items);
  }

  static void addItem(ResourceItem item) {
    _items.insert(0, item);
  }

  static List<ResourceItem> getByType(ResourceType type) {
    return _items.where((item) => item.type == type).toList();
  }

  static List<ResourceItem> getFavorites() {
    return _items.where((item) => item.isFavorite).toList();
  }

  static void clear() {
    _items.clear();
  }
}