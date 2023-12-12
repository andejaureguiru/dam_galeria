import 'dart:ffi';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

var baseRemota = FirebaseFirestore.instance;
var storage = FirebaseStorage.instance;

class DB{
  static Future<bool> autenticar(String user,String pass) async {
    try {
      // Consulta la colección "usuarios" en Firestore
      QuerySnapshot<Map<String, dynamic>> query = await baseRemota
          .collection('usuarios')
          .where('usuario', isEqualTo: user)
          .where('contra', isEqualTo: pass)
          .get();

      // Comprueba si hay un documento coincidente
      if (query.docs.isNotEmpty) {
        // Si existe un documento, la autenticación es exitosa
        return true;
      } else {
        // No hay coincidencias, la autenticación falla
        return false;
      }
    } catch (e) {
      // Maneja errores aquí
      print("Error de autenticación: $e");
      return false;
    }
  }

  static Future<bool> verificarUsuarioDisponible(String user) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query = await baseRemota
          .collection('usuarios')
          .where('usuario', isEqualTo: user)
          .get();

      // Si la consulta devuelve algún documento, el nombre de usuario no está disponible
      return query.docs.isEmpty;
    } catch (e) {
      // Maneja errores aquí
      print("Error al verificar disponibilidad de nombre de usuario: $e");
      return false;
    }
  }

  static Future<bool> registrarUsuario(Map<String, dynamic> user, File image) async {
    try {
      // Verifica si el nombre de usuario está disponible antes de registrar
      bool nombreUsuarioDisponible = await verificarUsuarioDisponible(user['usuario']);

      String nombreImagen = image.path.split("/").last;

      Reference reference = storage.ref().child("usuarios").child(nombreImagen);
      UploadTask upload = reference.putFile(image);
      TaskSnapshot snapshot = await upload.whenComplete(() => true);
      String url = await snapshot.ref.getDownloadURL();

      user['url']=url;

      if (nombreUsuarioDisponible) {
        // Si el nombre de usuario está disponible, registra el usuario
        await baseRemota.collection("usuarios").add(user);
        return true;
      } else {
        // Si el nombre de usuario no está disponible, maneja el caso adecuadamente
        print("Nombre de usuario no disponible");
        return false;
      }
    } catch (e) {
      // Maneja errores aquí
      print("Error al registrar usuario: $e");
    }
    return false;
  }

  static Future actualizarUsuario(Map<String, dynamic> user, File? image) async {
    String id = user['id'];
    user.remove('id');

    if (image!=null){
      Reference referenceDel = FirebaseStorage.instance.refFromURL(user['url']);
      await referenceDel.delete();

      String nombreImagen = image.path.split("/").last;

      Reference reference = storage.ref().child("usuarios").child(nombreImagen);
      UploadTask upload = reference.putFile(image);
      TaskSnapshot snapshot = await upload.whenComplete(() => true);
      String url = await snapshot.ref.getDownloadURL();

      user['url'] = url;
    }

    return await baseRemota.collection("usuarios").doc(id).update(user);
  }

  static Future<List> consultarUsuario(String user) async {
      List temporal = [];

      var query = await baseRemota.collection('usuarios').where('usuario', isEqualTo: user).get();

      query.docs.forEach((element) {
        Map<String, dynamic> data = element.data();
        data.addAll({
          'id': element.id
        });
        temporal.add(data);
      });

      return temporal;
  }

  static Future<List> mostrarEventos(String user) async {
    List temporal = [];
    var query = await baseRemota.collection("eventos").where('usuario', isEqualTo: user).get();

    query.docs.forEach((element) {
      Map<String, dynamic> data = element.data();
      data.addAll({
        'id': element.id
      });
      temporal.add(data);
    });

    return temporal;
  }

  static Future<List> mostrarEventosInv(String user) async {
    List temporal = [];
    var query = await baseRemota.collection("eventos").where('participantes', arrayContains: user).get();

    query.docs.forEach((element) {
      Map<String, dynamic> data = element.data();
      data.addAll({
        'id': element.id
      });
      temporal.add(data);
    });

    return temporal;
  }

  static Future<List> mostrarEvento(String inv) async {
    List temporal = [];
    var query = await baseRemota.collection("eventos").where('inv', isEqualTo: inv).get();

    query.docs.forEach((element) {
      Map<String, dynamic> data = element.data();
      data.addAll({
        'id': element.id
      });
      temporal.add(data);
    });

    return temporal;
  }

  static Future<String> generarCodigoUnico() async {
    const caracteres = "abcdefghijklmnopqrstuvwxyz0123456789";
    final random = Random();
    String codigo = "";

    for (int i = 0; i < 7; i++) {
      codigo += caracteres[random.nextInt(caracteres.length)];
    }

    return codigo;
  }

  static Future<bool> verificarCodigoDisponible(String codigo) async {
    QuerySnapshot<Map<String, dynamic>> eventos = await baseRemota.collection("eventos").where('inv', isEqualTo: codigo).get();
    return eventos.docs.isEmpty;
  }

  static Future<String> generarCodigoUnicoDisponible() async {
    String codigo;
    do {
      codigo = await generarCodigoUnico();
    } while (!(await verificarCodigoDisponible(codigo)));

    return codigo;
  }

  static Future registrarEvento(Map<String, dynamic> evento, File image) async {
    String codigoUnico = await generarCodigoUnicoDisponible();
    evento['inv'] = codigoUnico;

    String nombreImagen = image.path.split("/").last;

    Reference reference = storage.ref().child("eventos").child(evento['inv']).child("portada").child(nombreImagen);
    UploadTask upload = reference.putFile(image);
    TaskSnapshot snapshot = await upload.whenComplete(() => true);
    String url = await snapshot.ref.getDownloadURL();

    evento['url'] = [url];

    return await baseRemota.collection("eventos").add(evento);
  }

  static Future actualizarEvento(Map<String, dynamic> evento, File? image) async{
    String id = evento['id'];
    evento.remove('id');
    
    if (image!=null){
      Reference referenceDel = FirebaseStorage.instance.refFromURL(evento['url'][0]);
      await referenceDel.delete();

      String nombreImagen = image.path.split("/").last;

      Reference reference = storage.ref().child("eventos").child(evento['inv']).child("portada").child(nombreImagen);
      UploadTask upload = reference.putFile(image);
      TaskSnapshot snapshot = await upload.whenComplete(() => true);
      String url = await snapshot.ref.getDownloadURL();

      evento['url'][0] = url;
    }
    
    return await baseRemota.collection("eventos").doc(id).update(evento);
  }

  static Future<int> registrarInvitacion(String inv, String user) async {
    try {
      // Referencia a la colección de eventos
      CollectionReference eventosRef = FirebaseFirestore.instance.collection('eventos');

      // Realizar una consulta para verificar si existe un evento con el código de invitación dado
      QuerySnapshot eventosQuery = await eventosRef
          .where('inv', isEqualTo: inv)
          .get();

      // Si no hay eventos que coincidan, el evento no existe
      if (eventosQuery.docs.isEmpty) {
        return 0;
      }

      // Si hay eventos que coinciden, verificar si pertenece al usuario
      bool eventoPerteneceAlUsuario = eventosQuery.docs.any((evento) => evento['usuario'] == user);

      // Si el evento pertenece al usuario, devolver 1
      if (eventoPerteneceAlUsuario) {
        return 1;
      }

      // Obtener el ID del primer documento que coincide con el código de invitación
      String eventoId = eventosQuery.docs.first.id;

      // Verificar si el usuario ya está registrado en el campo "participantes" (que es un array)
      List<dynamic> participantes = eventosQuery.docs.first['participantes'];

      // Si el usuario ya está registrado, devolver 3
      if (participantes.contains(user)) {
        return 3;
      }

      // Actualizar el campo "participantes" para agregar el nuevo participante
      await eventosRef.doc(eventoId).update({
        'participantes': FieldValue.arrayUnion([user]),
        // Otros campos de participante...
      });

      // Devolver 2 para indicar que se ha registrado la invitación con éxito
      return 2;

    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la operación
      print('Error al verificar/registrar la invitación: $e');
      return -1; // Código de error
    }
  }

  static Future<bool> subirFotos(List<File> images, String evento, String idEvento) async {
    try {
      List<String> urls = [];

      for (File image in images) {
        String nombreImagen = image.path.split("/").last;

        Reference reference = storage.ref().child("eventos").child(evento).child(nombreImagen);
        UploadTask upload = reference.putFile(image);
        TaskSnapshot snapshot = await upload.whenComplete(() => true);
        String url = await snapshot.ref.getDownloadURL();

        urls.add(url);
      }

      // Actualizar el documento en la colección de "eventos" con las URL de las imágenes
      await baseRemota.collection("eventos").doc(idEvento).update({
        'url': FieldValue.arrayUnion(urls),
      });

      return true;
    } catch (e) {
      print('Error al subir fotos: $e');
      return false;
    }
  }

  static Future<List> mostrarFotos(String inv) async {
    var query = await baseRemota.collection("eventos").where('inv', isEqualTo: inv).get();

    List<String> urls = [];

    query.docs.forEach((document) {
      // Acceder al campo "url" y agregar sus valores a la lista
      List<String>? urlList = document['url']?.cast<String>();
      if (urlList != null) {
        urls.addAll(urlList);
      }
    });

    return urls;
  }

  static Future<bool> eliminarFoto(String url, String id) async {
    try {
      // Paso 1: Eliminar la imagen de Firebase Storage
      Reference referenceDel = FirebaseStorage.instance.refFromURL(url);
      await referenceDel.delete();

      // Paso 2: Obtener el ID del documento en la colección de eventos
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('eventos')
          .where('url', arrayContains: url)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No se encontró el documento con la URL proporcionada.');
        return false;
      }

      String documentoId = querySnapshot.docs.first.id;

      // Paso 3: Actualizar el documento en Firestore, eliminando la URL del array "url"
      await FirebaseFirestore.instance.collection('eventos').doc(documentoId).update({
        'url': FieldValue.arrayRemove([url]),
      });

      print('Imagen eliminada con éxito.');
      return true;
    } catch (e) {
      print('Error al eliminar la imagen: $e');
      return false;
    }
  }


/*static Future insertar(Map<String, dynamic> consola) async {
    return await baseRemota.collection("consolas").add(consola);
  }

  static Future<List> mostrarTodos() async {
    List temporal = [];
    var query = await baseRemota.collection("consolas").get();

    query.docs.forEach((element) {
      Map<String, dynamic> data = element.data();
      data.addAll({
        'id': element.id
      });
      temporal.add(data);
    });

    // Ordenar la lista por el campo "año"
    temporal.sort((a, b) => a['año'].compareTo(b['año']));

    return temporal;
  }

  static Future eliminar(String id) async{
    return await baseRemota.collection("consolas").doc(id).delete();
  }

  static Future actualizar(Map<String, dynamic> consola) async{
    String id = consola['id'];
    consola.remove('id');
    return await baseRemota.collection("consolas").doc(id).update(consola);
  }*/
}