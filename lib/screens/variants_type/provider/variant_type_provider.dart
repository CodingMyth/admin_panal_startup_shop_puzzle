import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/api_response.dart';
import '../../../models/variant_type.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class VariantsTypeProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addVariantsTypeFormKey = GlobalKey<FormState>();
  TextEditingController variantNameCtrl = TextEditingController();
  TextEditingController variantTypeCtrl = TextEditingController();

  VariantType? variantTypeForUpdate;



  VariantsTypeProvider(this._dataProvider);


  //addVariantType
  addVariantType() async {
    try {
      // 1. Prepare the Body
      Map<String, dynamic> VariantType = {
        "name": variantNameCtrl.text,
        "type": variantTypeCtrl.text,
      };

      // 2. Call Service to Add Item
      final response = await service.addItem(endpointUrl: 'variantTypes', itemData: VariantType);

      // 3. Handle Response
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');

          // 4. Refresh List
          _dataProvider.getAllVariantType();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to add variant type: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('Error occurred: $e');
      rethrow;
    }
  }

  // updateVariantType
  updateVariantType() async {
    try {
      //validation
      if (variantTypeForUpdate == null) {
        SnackBarHelper.showErrorSnackBar('No sub-category selected for update');
        return;
      }
      // 1. Prepare the Body
      Map<String, dynamic> updateVariant = {
        "name": variantNameCtrl.text ,
        "type": variantTypeCtrl.text,
      };

      // 2. Call Service to Update Item
      final response = await service.addItem(endpointUrl: 'variantTypes', itemData: updateVariant);

      // 3. Handle Response
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');

          // 4. Refresh List
          _dataProvider.getAllVariantType();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to add variant type: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('Error occurred: $e');
      rethrow;
    }
  }


  // submitVariantType
   submitVariantType(){
    if(variantTypeForUpdate!=null){
      updateVariantType();
    }else{
      addVariantType();
    }
   }

  // deleteVariantType
  deleteVariantType(VariantType variantType) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'VariantTypes',
          itemId: variantType.sId ?? ''
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar("SubCategory deleted successfully");
          // Refresh the VariantType list
          _dataProvider.getAllVariantType();
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error : ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  setDataForUpdateVariantTYpe(VariantType? variantType) {
    if (variantType != null) {
      variantTypeForUpdate = variantType;
      variantNameCtrl.text = variantType.name ?? '';
      variantTypeCtrl.text = variantType.type ?? '';
    } else {
      clearFields();
    }
  }

  clearFields() {
    variantNameCtrl.clear();
    variantTypeCtrl.clear();
    variantTypeForUpdate = null;
  }
}
