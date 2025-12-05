import '../../../models/variant_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/api_response.dart';
import '../../../models/variant.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class VariantsProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addVariantsFormKey = GlobalKey<FormState>();
  TextEditingController variantCtrl = TextEditingController();
  VariantType? selectedVariantType;
  Variant? variantForUpdate;




  VariantsProvider(this._dataProvider);


  // addVariant method
  addVariant() async {
    try{
      Map<String,dynamic> Variant = {
        'name' : variantCtrl.text,
        'VariantTypeId' : selectedVariantType?.sId
      };
      final response = await service.addItem(endpointUrl: 'variants', itemData: Variant);
      if(response.isOk){
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if(apiResponse.success == true){
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllVariant();
        }else{
          SnackBarHelper.showErrorSnackBar('Failed to add Sub Category : ${apiResponse.message}');
        }
      }else{
        SnackBarHelper.showErrorSnackBar('Error:${response.body?['message'] ?? response.statusText}');
      }
    }catch(e){
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  // updateVariant
  updateVariant() async {
    try {
      // 1. Validation
      if (variantForUpdate == null) {
        SnackBarHelper.showErrorSnackBar('No variant selected for update');
        return;
      }

      // 2. Prepare Data
      Map<String, dynamic> variant = {
        "name": variantCtrl.text,
        // Use the selected dropdown ID, or fallback to existing ID if the user didn't change it
        "categoryId": selectedVariantType?.sId ?? variantForUpdate?.variantTypeId,
      };

      // 3. Send Request
      // We pass the 'body' Map directly.
      final response = await service.updateItem(
        endpointUrl: 'subCategories',
        itemId: variantForUpdate?.sId ?? '',
        itemData: variant,
      );

      // 4. Handle Response
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');

          // Refresh list
          _dataProvider.getAllVariant();

          // Reset variables
          variantForUpdate = null;
          selectedVariantType = null;
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to update: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('Error occurred: $e');
    }
  }

  //complete submitVariant
  submitVariant(){
    if(variantForUpdate != null){
      updateVariant();
    }else{
      addVariant();
    }
  }

  // complete deleteVariant
  deleteVariant(Variant variant) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'subCategories',
          itemId: variant.sId ?? ''
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar("SubCategory deleted successfully");
          // Refresh the sub-category list
          _dataProvider.getAllVariant();
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error : ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }



  setDataForUpdateVariant(Variant? variant) {
    if (variant != null) {
      variantForUpdate = variant;
      variantCtrl.text = variant.name ?? '';
      selectedVariantType =
          _dataProvider.variantTypes.firstWhereOrNull((element) => element.sId == variant.variantTypeId?.sId);
    } else {
      clearFields();
    }
  }

  clearFields() {
    variantCtrl.clear();
    selectedVariantType = null;
    variantForUpdate = null;
  }

  void updateUI() {
    notifyListeners();
  }
}
