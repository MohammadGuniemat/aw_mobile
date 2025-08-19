import 'package:aw_app/core/constants/img_urls.dart';
import 'package:aw_app/core/constants/translate.dart';
import 'package:aw_app/core/theme/colors.dart';
import 'package:aw_app/provider/lang_prvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerInfo extends StatelessWidget {
  const CustomerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LangPrvider>(context);

    return ListTile(
      leading: CircleAvatar(
        radius: 27, // outer radius (border)
        backgroundColor: AppColors.primary, // border color
        child: CircleAvatar(
          radius: 22, // inner circle (actual image size)
          backgroundImage: NetworkImage(ImagesURLS.personImg),
          backgroundColor: Colors.grey[200], // fallback if image fails
        ),
      ),
      title: Text(Translate.get('customerName', lang: langProvider.lang)),
      subtitle: Text(Translate.get('customerNumber', lang: langProvider.lang)),
      trailing: Icon(Icons.info_outline),
    );
  }
}
