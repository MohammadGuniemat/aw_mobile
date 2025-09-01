class Translate {
  static const Map<String, Map<String, String>> words = {
    'LandTitle': {"eng": "Aw Compan8y", "ar": "شركة مياه العقبة"},
    'Settings': {"eng": "Settings", "ar": "إعدادات"},
    'Home': {"eng": "Home", "ar": "الرئيسية"},
    'Login': {"eng": "Login", "ar": "تسجيل الدخول"},
    'GoTo': {"eng": "Go To : ", "ar": "انتقل إلى : "},
    'customer': {"eng": "Customer", "ar": "المشترك"},
    'customerNumber': {"eng": "Customer Number", "ar": "رقم المشترك"},
    'customerName': {"eng": "Customer Name", "ar": "اسم المشترك"},
    'customerAddress': {"eng": "Customer Address", "ar": "عنوان المشترك"},
    'customerPhone': {"eng": "Customer Phone", "ar": "هاتف المشترك"},
    'customerEmail': {
      "eng": "Customer Email",
      "ar": "البريد الإلكتروني للمشترك",
    },
    'customerType': {"eng": "Customer Type", "ar": "نوع المشترك"},
    'customerTypeResidential': {"eng": "Residential", "ar": "سكني"},
    'customerTypeCommercial': {"eng": "Commercial", "ar": "تجاري  "},
    'customerTypeIndustrial': {"eng": "Industrial", "ar": "صناعي  "},
    'customerTypeGovernmental': {"eng": "Governmental", "ar": "حكومي"},
    'customerTypeOther': {"eng": "Other", "ar": "أخرى"},
    'customerStatus': {"eng": "Customer Status", "ar": "حالة المشترك"},
    'customerStatusActive': {"eng": "Active", "ar": "نشط"},
    'customerStatusInactive': {"eng": "Inactive", "ar": "غير نشط"},

    "EnterCredentials": {
      "eng": "Enter your credentials here:",
      "ar": "أدخل بيانات الحساب الخاصة بك هنا:",
    },
    "Email": {"eng": "Email", "ar": "البريد الإلكتروني"},
    "Password": {"eng": "Password", "ar": "كلمة المرور"},
    "Submit": {"eng": "Submit", "ar": "إرسال"},
    "NoAccount": {"eng": "Don't have an account?", "ar": "ليس لديك حساب؟"},
    "Register": {"eng": "Register", "ar": "تسجيل"},
  };

  static String get(String key, {String lang = "eng"}) {
    return words[key]?[lang] ?? key;
  }
}
