import '../../../models/api_response.dart';
import '../../../models/brand.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';


class BrandProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addBrandFormKey = GlobalKey<FormState>();
  TextEditingController brandNameCtrl = TextEditingController();
  SubCategory? selectedSubCategory;
  Brand? brandForUpdate;




  BrandProvider(this._dataProvider);




  //complete addBrand
  addBrand() async {
    try{
      Map<String,dynamic> brand = {
        'name' : brandNameCtrl.text,
        'categoryId' : selectedSubCategory?.sId
      };
      final response = await service.addItem(endpointUrl: 'brand', itemData: brand);
      if(response.isOk){
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if(apiResponse.success == true){
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllBrand();
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


  // complete updateBrand
  updateBrand () async {
    try {
      // 1. Validation
      if (brandForUpdate == null) {
        SnackBarHelper.showErrorSnackBar('No sub-category selected for update');
        return;
      }

      // 2. Prepare Data
      Map<String, dynamic> body = {
        "name": brandNameCtrl.text,
        // Use the selected dropdown ID, or fallback to existing ID if the user didn't change it
        "SubCategoryId": selectedSubCategory ?.sId ?? brandForUpdate?.subcategoryId,
      };

      // 3. Send Request
      // We pass the 'body' Map directly.
      final response = await service.updateItem(
        endpointUrl: 'subCategories',
        itemId: brandForUpdate?.sId ?? '',
        itemData: body,
      );

      // 4. Handle Response
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');

          // Refresh list
          _dataProvider.getAllBrand();

          // Reset variables
          brandForUpdate = null;
          selectedSubCategory = null;
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


  //complete submitBrand
  submitBrand(){
    if(brandForUpdate != null){
      updateBrand();
    }else{
      addBrand();
    }
  }


  //complete deleteBrand
  deleteBrand(Brand brand) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'brands',
          itemId: brand.sId ?? ''
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar("SubCategory deleted successfully");
          // Refresh the sub-category list
          _dataProvider.getAllBrand();
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error : ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }




  //? set data for update on editing
  setDataForUpdateBrand(Brand? brand) {
    if (brand != null) {
      brandForUpdate = brand;
      brandNameCtrl.text = brand.name ?? '';
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull((element) => element.sId == brand.subcategoryId?.sId);
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update brand
  clearFields() {
    brandNameCtrl.clear();
    selectedSubCategory = null;
    brandForUpdate = null;
  }

  updateUI(){
    notifyListeners();
  }

}
