# SafeHome Mobile

Aplicación móvil Flutter para el proyecto SafeHome.

## Alcance actual

- Login local básico.
- Registro de visitantes desde el celular.
- Selección de imagen desde cámara o galería.
- Carga de departamentos desde el backend Django.
- Envío del visitante como JSON con foto en base64, alineado con el backend actual.

## Backend esperado

La app consume la API existente en:

- `GET /api/departamentos/`
- `POST /api/visitantes/`

Por defecto usa `http://10.0.2.2:8000` para Android emulado. Ajusta la URL en `lib/src/screens/register_visitor_screen.dart` si apuntas a otro host.

## Nota importante

Este entorno no tiene instalado el SDK de Flutter, así que aquí solo se dejó la estructura y el código fuente. Para ejecutar la app necesitas abrir la carpeta en una máquina con Flutter instalado y correr:

```bash
flutter pub get
flutter run
```
