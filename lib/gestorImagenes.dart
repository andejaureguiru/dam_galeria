import 'package:image_picker/image_picker.dart';

final ImagePicker picker = ImagePicker();

Future<XFile?> obtenerImagen() async{
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  return image;
}

Future<List<XFile?>> obtenerImagenes() async{
  final List<XFile> images = await picker.pickMultiImage();
  return images;
}