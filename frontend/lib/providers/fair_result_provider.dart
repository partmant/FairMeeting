import 'package:flutter/cupertino.dart';
import '../models/fair_location_response.dart';

class FairResultProvider extends ChangeNotifier {
  FairLocationResponse? _fairLocationResponse;

  FairLocationResponse? get response => _fairLocationResponse;

  void updateResponse(FairLocationResponse newResponse) {
    _fairLocationResponse = newResponse;
    notifyListeners();
  }

  void clear() {
    _fairLocationResponse = null;
    notifyListeners();
  }
}