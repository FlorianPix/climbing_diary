class MyValidators{
  static notEmpty(String? value, String name){
    return value!.isNotEmpty ? null : "Please add a $name";
  }

  static isInt(String? value){
    if (value != null && value != ""){
      var i = int.tryParse(value);
      if (i == null) return "must be a number";
    }
    return null;
  }
}