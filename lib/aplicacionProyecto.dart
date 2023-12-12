import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dam_galeria/serviciosRemotos.dart';
import 'package:dam_galeria/gestorImagenes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart.';

class AppPro extends StatefulWidget {
  const AppPro({super.key});

  @override
  State<AppPro> createState() => _AppProState();
}

class _AppProState extends State<AppPro> {
  var nombreEve  = TextEditingController();
  var fInicioEve = TextEditingController();
  var fFinEve   = TextEditingController();

  String titulo = "Event Manager";
  int _index = 0;
  int _sesion = 0;

  String _nombre = "";
  String _usuario = "";
  String _contra = "";
  String _usuarioId = "";
  File? _perfil;
  String? _perfilF;

  String _evento = "";
  File? _eventoImg;
  String _fIni = "";
  String _fFin = "";
  bool _visible = true;
  String _eventoImgNet="";
  String _eventoNom = "";
  String _eventoId = "";
  List<File>? x=[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(titulo),
        centerTitle: true,
        actions: [
          if (_index == 9 || _index == 11)
          IconButton(
              onPressed: (){
                if (_index==9){
                setState(() {
                  _index=8;
                });
                }else{
                  setState(() {
                    _index=7;
                  });
                }
              },
              icon: Icon(Icons.backspace))
        ],
      ),
      body: dinamico(),
      drawer: _sesion == 1 ? _buildDrawer() : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _perfilF != null
                ? CircleAvatar(
                  backgroundImage: NetworkImage(_perfilF!),
                  radius: 40,
                )
                :CircleAvatar(
                  child: Icon(Icons.person),
                  radius: 40,
                ),
                SizedBox(height: 20,),
                Text(
                  _nombre,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              ],
            ),
            decoration: BoxDecoration(color: Colors.purple),
          ),
          _item(Icons.celebration, "Mis eventos", 3),
          _item(Icons.card_giftcard, "Invitaciones", 4),
          _item(Icons.new_label, "Crear evento", 5),
          _item(Icons.handyman, "Configuración", 6),
          _item(Icons.exit_to_app, "Salir", 2),
        ],
      ),
    );
  }

  Widget _item(IconData icono, String texto, int indice) {
    return ListTile(
      onTap: (){
        setState(() {
          _index = indice;
        });
        Navigator.pop(context);
      },
      title: Row(
        children: [Expanded(child: Icon(icono)), Expanded(child: Text(texto, style: TextStyle(color: Colors.black45),),flex: 2,)],
      ),
    );
  }

  Widget dinamico(){
    /*
    Nombre: dinamico()

    Variable: _index int

    Función: Cambiar el aspecto de la pantalla según los distintos estados

    _index = 0: Inicio de sesión
    _index = 1: Registrar usuario
    _index = 2: Cerrar sesión
    _index = 3: Eventos del usuario
    _index = 4: Invitaciones del usuario
    _index = 5: Crear evento
    _index = 6: Configuración del perfil
    _index = 7: Ajustes de evento
    */
    if(_index==0){
      return login();
    }
    if(_index==1){
      return signup();
    }
    if(_index==2){
      setState(() {
        _sesion=0;
        _limpiarVariables();
      });
      return login();
    }
    if(_index==3){
      _eventoImg = null;
      return events();
    }
    if(_index==4){
      return invs();
    }
    if(_index==5){
      return createEvent();
    }
    if(_index==6){
      return confs();
    }
    if(_index==7){
      return event();
    }
    if(_index==8){
      return galeryInv();
    }
    if(_index==9){
      return galery();
    }
    if(_index==10){
      return eventsInv();
    }
    if(_index==11){
      return galeryOwn();
    }
    return Center();
  }

  Widget login(){
    if (_sesion != 0){
      setState(() {
        _index = 3;
      });
    }
    final TextEditingController _user = TextEditingController();
    final TextEditingController _pass = TextEditingController();

    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Inicio de Sesión',
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _user,
          decoration: InputDecoration(
            labelText: 'Usuario',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 12.0),
        TextField(
          controller: _pass,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.password),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async{
                if(await DB.autenticar(_user.text, _pass.text))
                {
                  DB.consultarUsuario(_user.text).then((value){
                    if (value.isNotEmpty){
                      _nombre = value[0]['nombre'];
                      _usuario = value[0]['usuario'];
                      _usuarioId = value[0]['id'];
                      _contra = value[0]['contra'];
                      _perfilF = value[0]['url'];
                      setState(() {
                        _index=3;
                        _sesion=1;
                      });
                    }else{
                      _showErrorDialog("Error al recuperar información del usuario");
                    }
                  });
                }
                else{
                  _showErrorDialog("Error de autenticación");
                }
              },
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
        SizedBox(height: 12.0),
        TextButton(
          onPressed: () {
            setState(() {
              _index = 1;
            });
          },
          child: Text('¿Eres nuevo? Regístrate'),
        ),
      ],
    );
  }

  Widget signup(){
    if (_sesion != 0){
      setState(() {
        _index = 2;
      });
    }

    final TextEditingController _name = TextEditingController();
    final TextEditingController _user = TextEditingController();
    final TextEditingController _pass = TextEditingController();
    final TextEditingController _pass2 = TextEditingController();

    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Registro de Usuario',
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _perfil!=null ?
            CircleAvatar(
              radius: 60,
              backgroundImage: FileImage(_perfil!),
            )
            :CircleAvatar(
              radius: 60,
              child: Icon(Icons.person, size: 55,),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
                onPressed: () async{
                  final imagen = await obtenerImagen();
                  setState(() {
                    _perfil = File(imagen!.path);
                  });
                },
                child: Text("Seleccionar imagen")
            ),
          ],
        ),
        TextField(
          controller: _name,
          decoration: InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.text_increase),
          ),
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: _user,
          decoration: InputDecoration(
            labelText: 'Usuario',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 12.0),
        TextField(
          controller: _pass,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.password),
          ),
          obscureText: true,
        ),
        SizedBox(height: 12.0),
        TextField(
          controller: _pass2,
          decoration: InputDecoration(
            labelText: 'Confirmar contraseña',
            prefixIcon: Icon(Icons.password),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async{
                if (_name.text=="" || _user.text=="" || _pass.text=="" || _pass2.text==""){
                  _showErrorDialog("Rellena todos los campos");
                }else{
                  if (_pass.text == _pass2.text) {
                    if (_perfil == null){
                      _showErrorDialog("Agregue una imagen de perfil");
                    }
                    else{
                      var JsonTemporal = {
                        'nombre': _name.text,
                        'usuario': _user.text,
                        'contra': _pass.text,
                      };
                      DB.registrarUsuario(JsonTemporal, _perfil!)
                          .then((value) {
                        if (value) {
                          _showSuccesDialog("Usuario registrado. \nInicie sesión con sus credenciales");
                          Future.delayed(Duration(seconds: 2), () {
                            setState(() {
                              _index = 0;
                              _limpiarVariables();
                            });
                          });
                        } else {
                          _showErrorDialog("Usuario no disponible");
                        }
                      });
                    }
                  } else {
                    _showErrorDialog("Las contraseñas no coinciden");
                  }
                }
              },
              child: Text('Registrar'),
            ),
            SizedBox(width: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _index = 0;
                  _limpiarVariables();
                });
              },
              child: Text('Cancelar'),
            ),
          ],
        )
      ],
    );
  }

  Widget confs(){
    final TextEditingController _name = TextEditingController();
    final TextEditingController _pass = TextEditingController();
    final TextEditingController _pass2 = TextEditingController();

    _name.text = _nombre;
    _pass.text = _contra;
    _pass2.text = _contra;
    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Configuración de usuario',
              style: TextStyle(
                fontSize: 24.0,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _perfil!=null ?
            CircleAvatar(
              backgroundImage: FileImage(_perfil!),
              radius: 80,
            )
            :CircleAvatar(
              backgroundImage: NetworkImage(_perfilF!),
              radius: 80,
            ),
            SizedBox(height: 10,),
            ElevatedButton(
                onPressed: () async{
                  final imagen = await obtenerImagen();
                  setState(() {
                    _perfil = File(imagen!.path);
                  });
                },
                child: Text("Seleccionar imagen")
            ),
          ],
        ),
        TextField(
          controller: _name,
          decoration: InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.text_increase),
          ),
        ),
        SizedBox(height: 12.0),
        TextField(
          controller: _pass,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.password),
          ),
          obscureText: true,
        ),
        SizedBox(height: 12.0),
        TextField(
          controller: _pass2,
          decoration: InputDecoration(
            labelText: 'Confirmar contraseña',
            prefixIcon: Icon(Icons.password),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async{
                if (_name.text=="" || _pass.text=="" || _pass2.text==""){
                  _showErrorDialog("Rellena todos los campos");
                }else{
                  if (_pass.text == _pass2.text) {
                      var JsonTemporal = {
                        'nombre': _name.text,
                        'contra': _pass.text,
                        'url': _perfilF,
                        'id': _usuarioId
                      };

                      DB.actualizarUsuario(JsonTemporal, _perfil).then((value){
                          _showSuccesDialog("Usuario actualizado exitosamente!");
                          DB.consultarUsuario(_usuario).then((value) {
                            _nombre = value[0]['nombre'];
                            _usuario = value[0]['usuario'];
                            _usuarioId = value[0]['id'];
                            _contra = value[0]['contra'];
                            _perfilF = value[0]['url'];
                            _perfil=null;
                            setState(() {});
                          });
                      });
                  } else {
                    _showErrorDialog("Las contraseñas no coinciden");
                  }
                }
              },
              child: Text('Actualizar'),
            ),
            SizedBox(width: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _index = 3;
                  //_limpiarVariables();
                });
              },
              child: Text('Cancelar'),
            ),
          ],
        )
      ],
    );
  }

  Widget events(){
    _limpiarVariables2();
    x = [];
    return FutureBuilder(
        future: DB.mostrarEventos(_usuario),
        builder: (cxt, listaJSON){
          if (listaJSON.hasData){
            return ListView.builder(
                itemCount: listaJSON.data?.length,
                itemBuilder: (ct, id){
                  return SingleChildScrollView(
                    child: Container(
                      width: 300.0,
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () {
                          // Acción a realizar al tocar el contenedor
                          _evento = listaJSON.data?[id]['inv'];
                          _eventoId = listaJSON.data?[id]['id'];
                          _fIni = listaJSON.data?[id]['fecIni'];
                          _fFin = listaJSON.data?[id]['fecFin'];
                          _visible = listaJSON.data?[id]['visible'];
                          setState(() {
                            _index=7;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 30,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.celebration, color: Colors.purpleAccent,),
                                SizedBox(width: 10,),
                                Text(
                                  "${listaJSON.data?[id]['nombre']}",
                                  style: TextStyle(
                                    fontSize: 25.0,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Icon(Icons.celebration, color: Colors.purpleAccent,)
                              ],
                            ),
                            SizedBox(height: 10,),
                            Image.network(
                              listaJSON.data![id]['url'][0].toString(),
                              height: 150.0,
                              width: 250.0,
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 10,),
                                Text("Fecha Inicio: ${listaJSON.data?[id]['fecIni']}")
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 10,),
                                Text("Fecha Final:  ${listaJSON.data?[id]['fecFin']}"),
                              ],
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }
            );
          }
          return Center(child: CircularProgressIndicator(),);
        }
    );
  }

  Widget event() {
    return FutureBuilder(
        future: DB.mostrarEvento(_evento),
        builder: (cxt, listaJSON) {
          if (listaJSON.hasData) {
            return ListView.builder(
                padding: EdgeInsets.all(40),
                itemCount: listaJSON.data?.length,
                itemBuilder: (ct, id) {
                var nombre = TextEditingController();
                var fInicio = TextEditingController();
                var fFin = TextEditingController();
                var Inv = TextEditingController();
                nombre.text = listaJSON.data?[id]['nombre'];
                fInicio.text = _fIni;
                fFin.text = _fFin;
                Inv.text = _evento;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _eventoImg!=null ?
                    Image.file(_eventoImg!,width: 300,)
                        :Image.network(listaJSON.data![id]['url'][0].toString(),width: 300,),
                    SizedBox(height: 10,),
                    ElevatedButton(
                        onPressed: () async{
                          final imagen = await obtenerImagen();
                          setState(() {
                            _eventoImg = File(imagen!.path);
                          });
                        },
                        child: Text("Seleccionar imagen")
                    ),
                    SizedBox(height: 20,),
                    TextField(
                      controller: nombre,
                      decoration: InputDecoration(
                        labelText: 'Nombre del evento',
                        icon: Icon(Icons.celebration),
                      ),
                    ),
                    TextField(
                        controller: fInicio,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            labelText: "Fecha de inicio:"),
                        readOnly: true,
                        onTap: () async {
                          DateTime? fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime.parse(fInicio.text),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (fecha != null) {
                            setState(() {
                              _fIni = DateFormat('yyyy-MM-dd').format(fecha);
                              fInicio.text = _fIni;
                            });
                          }
                        }),
                    TextField(
                        controller: fFin,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            labelText: "Fecha de termino:"),
                        readOnly: true,
                        onTap: () async {
                          DateTime? fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime.parse(fFin.text),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (fecha != null) {
                            setState(() {
                              _fFin = DateFormat('yyyy-MM-dd').format(fecha);
                              fFin.text = _fFin;
                            });
                          }
                        }),
                    TextField(
                      controller: Inv,
                      decoration: InputDecoration(
                        labelText: 'Código de invitación',
                        icon: Icon(Icons.numbers),
                      ),
                      readOnly: true,
                      onTap: (){
                        Clipboard.setData(ClipboardData(text: Inv.text));
                      }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text("Visible",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                        ),),
                        Checkbox(
                          value: _visible, // Asegúrate de manejar el caso en que el valor es nulo
                          onChanged: (bool? X) {
                            setState(() {
                              _visible = X!;
                            });
                          },),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: (){
                              DateTime Inicio = DateTime.parse(fInicio.text);
                              DateTime Fin = DateTime.parse(fFin.text);
                              if(Inicio.isAfter(Fin)){
                                _showErrorDialog("La fecha de termino debe ser posterior a la de inicio");
                              }else if(nombre.text=="" || fInicio.text=="" || fFin.text==""){
                                _showErrorDialog("Rellene todos los campos");
                              }else{
                                var JsonTemporal = {
                                  'id': listaJSON.data?[id]['id'],
                                  'nombre': nombre.text,
                                  'usuario': _usuario,
                                  'fecIni': fInicio.text,
                                  'fecFin': fFin.text,
                                  'url': listaJSON.data?[id]['url'] != null ? List<String>.from(listaJSON.data?[id]['url']) : [],
                                  'inv': _evento,
                                  'visible': _visible
                                };
                                DB.actualizarEvento(JsonTemporal, _eventoImg).then((value){
                                  _showSuccesDialog("Actualización exitosa!");
                                  Future.delayed(Duration(seconds: 2), () {
                                    setState(() {
                                      _index = 3;
                                    });
                                  });
                                });
                              }
                            },
                            child: Text("Actualizar")),
                        SizedBox(width: 10,),
                        ElevatedButton(
                            onPressed: (){
                              setState(() {
                                _index = 11;
                                _eventoId = listaJSON.data?[id]['id'];
                              });
                            },
                            child: Text("Ver galería")),
                        SizedBox(width: 10,),
                        ElevatedButton(
                            onPressed: (){
                              setState(() {
                                _index = 3;
                              });
                            },
                            child: Text("Cancelar"))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: ()async{
                              List<XFile>? xFiles = (await obtenerImagenes()).cast<XFile>();

                              if (xFiles != null) {
                              // Convertir la lista de XFiles a Files
                              List<File> files = xFiles.map((xFile) => File(xFile.path)).toList();

                              // Asignar la lista convertida a la variable x
                              setState(() {
                              x = files;
                              });
                              }
                            },
                            child: Text("Agregar fotos")),
                        SizedBox(width: 10,),
                        ElevatedButton(
                            onPressed: () {
                              if (x!.isNotEmpty) {
                                DB.subirFotos(x!, _evento, _eventoId).then((value) {
                                  if (value) {
                                    _showSuccesDialog("Imágenes subidas exitosamente");
                                    x=[];
                                  }
                                  else
                                    _showErrorDialog("Error al subir las imágenes");
                                });
                              }else
                                null;
                            },

                            child: Text("  Subir fotos  ")),
                      ],
                    )
                  ],
                );
                }
            );
          }
          return Center(child: CircularProgressIndicator(),);
        }
    );
  }

  Widget createEvent(){

    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        _eventoImg!=null ?
        Image.file(_eventoImg!,width: 300,)
        :Container(
          color: Colors.white24,
          child: SizedBox(height: 150, width: 40, child: Icon(Icons.image, color: Colors.grey, size: 100,),),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () async{
                  final imagen = await obtenerImagen();
                  setState(() {
                    _eventoImg = File(imagen!.path);
                  });
                },
                child: Text("Seleccionar Imagen")
            ),
          ],
        ),
        SizedBox(height: 15,),
        TextField(
          controller: nombreEve,
          decoration: InputDecoration(
            labelText: 'Nombre del evento',
            icon: Icon(Icons.celebration),
          ),
        ),
        TextField(
            controller: fInicioEve,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today),
                labelText: "Fecha de inicio:"),
            readOnly: true,
            onTap: () async {
              DateTime? fecha;
              if (fInicioEve.text==""){
                fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
              }else{
                fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(fInicioEve.text),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
              }
              if (fecha != null) {
                setState(() {
                  fInicioEve.text = DateFormat('yyyy-MM-dd').format(fecha!);
                });
              }
            }),
        TextField(
            controller: fFinEve,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today),
                labelText: "Fecha de termino:"),
            readOnly: true,
            onTap: () async {
              DateTime? fecha;
              if (fFinEve.text==""){
                fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
              }else{
                fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(fFinEve.text),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
              }
                
              if (fecha != null) {
                setState(() {
                  fFinEve.text = DateFormat('yyyy-MM-dd').format(fecha!);
                });
              }
            }),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: (){
                  DateTime Inicio = DateTime.parse(fInicioEve.text);
                  DateTime Fin = DateTime.parse(fFinEve.text);
                  if(Inicio.isAfter(Fin)){
                    _showErrorDialog("La fecha de termino debe ser posterior a la de inicio");
                  }else if(_eventoImg == null){
                    _showErrorDialog("Seleccione una imagen como portada del evento");
                  }else if(nombreEve.text=="" || fInicioEve.text=="" || fFinEve.text==""){
                    _showErrorDialog("Rellene todos los campos");
                  }else {
                    var JsonTemporal = {
                      'nombre': nombreEve.text,
                      'usuario': _usuario,
                      'fecIni': fInicioEve.text,
                      'fecFin': fFinEve.text,
                      'visible': true,
                      'participantes': [],
                      'url': []
                    };
                    DB.registrarEvento(JsonTemporal, _eventoImg!).then((value){
                      _showSuccesDialog("Registro exitoso!");
                      Future.delayed(Duration(seconds: 2), () {
                        setState(() {
                          _index = 3;
                          nombreEve.clear();
                          fInicioEve.clear();
                          fFinEve.clear();
                        });
                      });
                    });
                  }
                  /*
              DB.actualizarEvento(JsonTemporal, _eventoImg).then((value){
                _showSuccesDialog("Actualización exitosa!");
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    titulo = "Mis eventos";
                    _index = 3;
                  });
                });
              });*/
                },
                child: Text("Registrar")),
            SizedBox(width: 20,),
            ElevatedButton(
                onPressed: (){},
                child: Text("Cancelar"))
          ],
        )
      ],
    );
  }

  Widget invs(){
    var inv = TextEditingController();
    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        TextField(
          controller: inv,
          decoration: InputDecoration(
            labelText: 'Código de invitación',
            prefixIcon: Icon(Icons.card_giftcard, color: Colors.purpleAccent,),
          ),
        ),
        SizedBox(height: 20,),
        ElevatedButton(
            onPressed: (){
              if (inv.text==""){
                _showErrorDialog("Asigna un código de invitación");
              }else if(inv.text.length!=7){
                _showErrorDialog("Los códigos de invitación válidos deben tener 7 caracteres");
              }else{
                DB.registrarInvitacion(inv.text, _usuario).then((value){
                  switch(value){
                    case 0:
                      _showErrorDialog("Evento no encontrado");
                    break;
                    case 1:
                      _showErrorDialog("No puedes unirte a uno de tus propios eventos");
                    break;
                    case 2:
                      _showSuccesDialog("Te haz unido con exito al evento");
                      inv.clear();
                    break;
                    case 3:
                      _showErrorDialog("Ya perteneces a este evento");
                    break;
                  }
                });
              }
            },
            child: Text("Participar")),
        ElevatedButton(
            onPressed: (){
              setState(() {
                _index = 10;
              });
            },
            child: Text("Ver eventos"),
        ),
        SizedBox(height: 20,),
      ],
    );
  }

  Widget eventsInv() {
    _limpiarVariables2();
    return FutureBuilder(
      future: DB.mostrarEventosInv(_usuario),
      builder: (cxt, listaJSON) {
        if (listaJSON.hasData) {
          return ListView.builder(
            itemCount: listaJSON.data?.length,
            itemBuilder: (ct, id) {
              // Verificar si el evento es visible
              bool isVisible = listaJSON.data?[id]['visible'] ?? false;

              // Mostrar el evento solo si es visible
              if (isVisible) {
                return SingleChildScrollView(
                  child: Container(
                    width: 300.0,
                    padding: EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        // Acción a realizar al tocar el contenedor
                        _evento = listaJSON.data?[id]['inv'];
                        _fIni = listaJSON.data?[id]['fecIni'];
                        _fFin = listaJSON.data?[id]['fecFin'];
                        _eventoImgNet = listaJSON.data?[id]['url'][0];
                        _eventoNom = listaJSON.data?[id]['nombre'];
                        _eventoId = listaJSON.data?[id]['id'];
                        setState(() {
                          _index = 8;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 30,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.celebration, color: Colors.purpleAccent,),
                              SizedBox(width: 10,),
                              Text(
                                "${listaJSON.data?[id]['nombre']}",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Icon(Icons.celebration, color: Colors.purpleAccent,),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Image.network(
                            listaJSON.data![id]['url'][0].toString(),
                            height: 150.0,
                            width: 250.0,
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 10,),
                              Text("Fecha Inicio: ${listaJSON.data?[id]['fecIni']}")
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 10,),
                              Text("Fecha Final:  ${listaJSON.data?[id]['fecFin']}"),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // Si el evento no es visible, devuelve un contenedor vacío
                return Container();
              }
            },
          );
        }
        return Center(child: CircularProgressIndicator(),);
      },
    );
  }

  Widget galeryInv(){
    return Center(
      child: Column(
        children: [
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, color: Colors.purpleAccent,),
              SizedBox(width: 10,),
              Text(_eventoNom,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10,),
              Icon(Icons.celebration, color: Colors.purpleAccent,),
            ],
          ),
          SizedBox(height: 20,),
          Image.network(_eventoImgNet, height: 150, width: 250,),
          SizedBox(height: 20,),
          ElevatedButton(
              onPressed: ()async{
                List<XFile>? xFiles = (await obtenerImagenes()).cast<XFile>();

                if (xFiles != null) {
                  // Convertir la lista de XFiles a Files
                  List<File> files = xFiles.map((xFile) => File(xFile.path)).toList();

                  // Asignar la lista convertida a la variable x
                  setState(() {
                    x = files;
                  });
                }
              },
              child: Text("Agregar fotos")),
          SizedBox(height: 10,),
          ElevatedButton(
              onPressed: () {
                if (x!.isNotEmpty) {
                  DB.subirFotos(x!, _evento, _eventoId).then((value) {
                    if (value) {
                      _showSuccesDialog("Imágenes subidas exitosamente");
                      x=[];
                    }
                    else
                      _showErrorDialog("Error al subir las imágenes");
                  });
                }else
                  null;
              },

              child: Text("  Subir fotos  ")),
          SizedBox(height: 10,),
          ElevatedButton(
              onPressed: (){
                setState(() {
                  _index = 9;
                });
              },
              child: Text("   Ver galería  ")),
          SizedBox(height: 10,),
          ElevatedButton(
              onPressed: (){
                setState(() {
                  _index=10;
                });
              },
              child: Text("     Cancelar    ")),
        ],
      ),
    );
  }

  Widget galery() {
    return FutureBuilder(
      future: DB.mostrarFotos(_evento),
      builder: (context, listaJSON) {
        if (listaJSON.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (listaJSON.hasError) {
          return Center(child: Text('Error al cargar las fotos.'));
        } else if (!listaJSON.hasData || listaJSON.data!.isEmpty || listaJSON.data?.length == 1) {
          return Center(child: Text('No hay fotos disponibles.'));
        } else {
          List<String> photoUrls = listaJSON.data as List<String>;

          return GridView.builder(
            itemCount: photoUrls.length > 1 ? photoUrls.length - 1 : 0, // Excluir el elemento 0
            itemBuilder: (context, id) {
              final adjustedIndex = id + 1; // Ajustar el índice para excluir el elemento 0
              return GestureDetector(
                onTap: () {
                  // Tu lógica para manejar el evento onTap
                },
                child: Container(
                  width: 300,
                  height: 300,
                  padding: EdgeInsets.all(10),
                  child: AspectRatio(
                    aspectRatio: 1.0, // 1.0 significa una proporción cuadrada; puedes ajustar según tus necesidades
                    child: Image.network(
                      photoUrls[adjustedIndex],
                      fit: BoxFit.cover, // Ajusta la forma en que la imagen se ajusta al contenedor
                    ),
                  ),
                ),
              );
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Puedes ajustar el número de columnas según tus necesidades
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
          );
        }
      },
    );
  }

  Widget galeryOwn() {
    return FutureBuilder(
      future: DB.mostrarFotos(_evento),
      builder: (context, listaJSON) {
        if (listaJSON.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (listaJSON.hasError) {
          return Center(child: Text('Error al cargar las fotos.'));
        } else if (!listaJSON.hasData || listaJSON.data!.isEmpty || listaJSON.data?.length == 1) {
          return Center(child: Text('No hay fotos disponibles.'));
        } else {
          List<String> photoUrls = listaJSON.data as List<String>;

          return GridView.builder(
            itemCount: photoUrls.length > 1 ? photoUrls.length - 1 : 0, // Excluir el elemento 0
            itemBuilder: (context, id) {
              final adjustedIndex = id + 1; // Ajustar el índice para excluir el elemento 0
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Eliminar foto'),
                        content: Text('¿Estás seguro de que quieres eliminar esta foto?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Cerrar el diálogo
                            },
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              DB.eliminarFoto(photoUrls[adjustedIndex], _eventoId).then((value){
                                if (value){
                                  _showSuccesDialog("Foto eliminada correctamente!");
                                  setState(() {});
                                }else{
                                  _showErrorDialog("Error al eliminar la foto");
                                }
                              });
                              Navigator.of(context).pop(); // Cerrar el diálogo después de la eliminación
                            },
                            child: Text('Eliminar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  width: 300,
                  height: 300,
                  padding: EdgeInsets.all(10),
                  child: AspectRatio(
                    aspectRatio: 1.0, // 1.0 significa una proporción cuadrada; puedes ajustar según tus necesidades
                    child: Image.network(
                      photoUrls[adjustedIndex],
                      fit: BoxFit.cover, // Ajusta la forma en que la imagen se ajusta al contenedor
                    ),
                  ),
                ),
              );
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Puedes ajustar el número de columnas según tus necesidades
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
          );

        }
      },
    );
  }

  void _showErrorDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccesDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Éxito'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _limpiarVariables(){
    _nombre = "";
    _usuario = "";
    _contra = "";
    _perfil = null;
    _perfilF = "";
  }

  void _limpiarVariables2(){
    _evento = "";
    _eventoImg = null;
    _fIni = "";
    _fFin = "";
    _visible = true;
  }
}
