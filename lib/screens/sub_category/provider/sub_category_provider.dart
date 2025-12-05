import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../services/http_services.dart';


class SubCategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;


  final addSubCategoryFormKey = GlobalKey<FormState>();
  TextEditingController subCategoryNameCtrl = TextEditingController();
  Category? selectedCategory;
  SubCategory? subCategoryForUpdate;




  SubCategoryProvider(this._dataProvider);


  //complete addSubCategory
  addSubCategory() async {
    try{
      Map<String,dynamic> subCategory = {
        'name' : subCategoryNameCtrl.text,
        'categoryId' : selectedCategory?.sId
      };
      final response = await service.addItem(endpointUrl: 'subCategories', itemData: subCategory);
      if(response.isOk){
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if(apiResponse.success == true){
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');
          _dataProvider.getAllSubCategory();
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


  //updateSubCategory
  updateSubCategory() async {
    try {
      // 1. Validation
      if (subCategoryForUpdate == null) {
        SnackBarHelper.showErrorSnackBar('No sub-category selected for update');
        return;
      }

      // 2. Prepare Data
      Map<String, dynamic> body = {
        "name": subCategoryNameCtrl.text,
        // Use the selected dropdown ID, or fallback to existing ID if the user didn't change it
        "categoryId": selectedCategory?.sId ?? subCategoryForUpdate?.categoryId,
      };

      // 3. Send Request
      // We pass the 'body' Map directly.
      final response = await service.updateItem(
        endpointUrl: 'subCategories',
        itemId: subCategoryForUpdate?.sId ?? '',
        itemData: body,
      );

      // 4. Handle Response
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('${apiResponse.message}');

          // Refresh list
          _dataProvider.getAllSubCategory();

          // Reset variables
          subCategoryForUpdate = null;
          selectedCategory = null;
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


  //submitSubCategory
  submitSubCategory(){
    if(subCategoryForUpdate != null){
      updateSubCategory();
    }else{
      addSubCategory();
    }
  }


  //complete deleteSubCategory
  deleteSubCategory(SubCategory subCategory) async {
    try {
      Response response = await service.deleteItem(
          endpointUrl: 'subCategories',
          itemId: subCategory.sId ?? ''
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar("SubCategory deleted successfully");
          // Refresh the sub-category list
          _dataProvider.getAllSubCategory();
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error : ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }


  setDataForUpdateSubCategory(SubCategory? subCategory) {
    if (subCategory != null) {
      subCategoryForUpdate = subCategory;
      subCategoryNameCtrl.text = subCategory.name ?? '';
      selectedCategory = _dataProvider.categories.firstWhereOrNull((element) => element.sId == subCategory.categoryId?.sId);
    } else {
      clearFields();
    }
  }

  clearFields() {
    subCategoryNameCtrl.clear();
    selectedCategory = null;
    subCategoryForUpdate = null;
  }

  updateUi(){
    notifyListeners();
  }
}
