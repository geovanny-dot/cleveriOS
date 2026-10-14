# CleverTap iOS Testing App

Aplicación de prueba para validar diferentes comportamientos del **CleverTap iOS SDK**, incluyendo identificación de usuarios, cambio entre perfiles, logout, eventos, Native Display y propiedades de mensajería.

## Objetivo

Esta aplicación permite realizar pruebas rápidas sobre una integración de CleverTap en iOS sin necesidad de implementar una aplicación de negocio completa.

Las pruebas principales incluyen:

* Identificación de usuarios mediante `onUserLogin`.
* Creación/cambio a un nuevo perfil anónimo.
* Logout y cambio de perfil.
* Activación/desactivación de `MSG-push`.
* Envío de eventos con propiedades simples y estructuras anidadas.
* Validación de Native Display.
* Inspección de valores almacenados por el SDK en `UserDefaults`.
* Limpieza de información relacionada con perfiles anónimos/cache.

---

## Requisitos

* Xcode
* iOS Simulator o dispositivo físico
* CleverTap iOS SDK
* Un proyecto de CleverTap configurado para pruebas
* Las credenciales/configuración de CleverTap correspondientes al ambiente de testing

> No incluir credenciales, Account ID, Token, certificados ni otros secretos directamente en este repositorio.

---

## Funcionalidades de la aplicación

### 1. Login

Botón:

```text
Login
```

Ejecuta `onUserLogin` con el siguiente perfil de prueba:

```text
Name: TestLogOutUser_A01
Identity: 10000A01
Email: fakeA01@TestLogOutUser_b.com
```

Código utilizado:

```swift
CleverTap.sharedInstance()?.onUserLogin(profile)
```

También imprime en consola las claves relacionadas con `WizRocket` antes y después del login para facilitar la inspección del estado local del SDK.

---

### 2. Send Event

Botón:

```text
Send Event
```

Envía el evento:

```text
Order Completed
```

con propiedades anidadas.

Ejemplo simplificado:

```json
{
  "orderId": "ORD-10001",
  "total": 249.99,
  "currency": "USD",
  "customer": {
    "id": "USER_12345",
    "membership": "Gold"
  },
  "shipping": {
    "method": "Express",
    "address": {
      "city": "Miami",
      "country": "USA"
    }
  }
}
```

Esto permite validar el procesamiento de eventos con:

* Strings
* Numbers
* Objects
* Arrays
* Nested objects
* Arrays of objects

---

### 3. Login new user

Botón:

```text
Login new user
```

Esta prueba permite validar el comportamiento al cambiar desde el perfil actual hacia un nuevo perfil anónimo.

El flujo es:

1. Limpiar información relacionada con GUIDs cacheados.
2. Ejecutar:

```swift
CleverTapReset.switchToNewAnonymousUser()
```

3. Esperar a que se complete el cambio.
4. Registrar eventos de onboarding:

   * `Onboarding Started`
   * `Onboarding Step 1`
5. Ejecutar `onUserLogin` para:

```text
Name: TestLogOutUser_A03
Identity: 10000A03
Email: fakeA03@TestLogOutUser_b.com
```

6. Imprimir nuevamente las claves de `WizRocket` para inspeccionar el estado local.

Esta prueba es especialmente útil para validar escenarios relacionados con:

* Anonymous profiles
* Profile switching
* `onUserLogin`
* Profile identity
* Persistencia local del SDK

---

### 4. Clear cache

Botón:

```text
Clear cache
```

Elimina de `UserDefaults` las claves que cumplen con:

```text
WizRocket* :CachedGUIDS
```

Esto se utiliza únicamente como herramienta de testing para limpiar información local relacionada con GUIDs cacheados.

> Esta acción no debe considerarse equivalente a un logout normal de una aplicación de producción.

---

### 5. Cerrar sesión

Botón:

```text
Cerrar sesión
```

Ejecuta el siguiente flujo:

#### Paso 1 — Deshabilitar push

```swift
CleverTap.sharedInstance()?.profilePush([
    "MSG-push": false
])
```

Esto deshabilita `MSG-push` para el perfil actual.

#### Paso 2 — Crear un nuevo perfil anónimo

```swift
CleverTapReset.switchToNewAnonymousUser()
```

#### Paso 3 — Habilitar push para el nuevo perfil

```swift
CleverTap.sharedInstance()?.profilePush([
    "MSG-push": true
])
```

El objetivo es validar un escenario de logout en el que:

1. El perfil anterior deja de ser elegible para push.
2. El dispositivo cambia a un perfil anónimo.
3. El nuevo perfil puede volver a ser elegible para push.

---

## Native Display

La aplicación inicializa:

```swift
@StateObject private var manager = NativeDisplayManager()
```

Cuando aparece la vista, se disparan los siguientes eventos:

```text
NativeEvent
NativeEvent2
NativeEvent3
NativeEvent4
NativeEvent5
```

Cada evento se utiliza para probar una campaña de **Native Display**.

### Display

Los contenidos recibidos desde CleverTap se muestran dinámicamente:

```swift
manager.units
```

y se muestran:

* Title
* Message

### Impression

Cuando el contenido aparece en pantalla:

```swift
manager.markViewed(unit)
```

se utiliza para registrar la visualización del Native Display.

### Click

Cuando el usuario toca el contenido:

```swift
manager.markClicked(unit)
```

se registra el click.

---

## Console Debugging

La aplicación incluye una función:

```swift
printKeys()
```

que imprime las claves de `UserDefaults` relacionadas con:

```text
WizRocket
```

Esto permite inspeccionar cambios en el estado local durante pruebas de:

* Login
* Profile switching
* Anonymous users
* Logout
* GUID/cache behavior

Ejemplo:

```text
===== ANTES =====
KEYS__ WizRocket...
```

y posteriormente:

```text
===== DESPUES =====
KEYS__ WizRocket...
```

---

## Test Users

| Test           | Identity   | Email                          |
| -------------- | ---------- | ------------------------------ |
| Login          | `10000A01` | `fakeA01@TestLogOutUser_b.com` |
| Login New User | `10000A03` | `fakeA03@TestLogOutUser_b.com` |
| Logout profile | `0000`     | `fake@demo.com`                |

Estos usuarios son únicamente perfiles de prueba.

---

## Suggested Test Flow

Para probar el comportamiento completo de perfiles:

### Test 1 — Login

1. Abrir la aplicación.
2. Presionar **Login**.
3. Verificar en CleverTap que el perfil `10000A01` exista.
4. Revisar los logs de Xcode.

### Test 2 — Event

1. Presionar **Send Event**.
2. Buscar `Order Completed` en CleverTap.
3. Validar las propiedades del evento.
4. Confirmar que los objetos y arrays hayan sido procesados correctamente.

### Test 3 — Native Display

1. Crear las campañas correspondientes a:

   * `NativeEvent`
   * `NativeEvent2`
   * `NativeEvent3`
   * `NativeEvent4`
   * `NativeEvent5`
2. Abrir/reiniciar la aplicación.
3. Validar la recepción del contenido.
4. Verificar impressions.
5. Hacer click sobre el contenido.
6. Validar clicks en CleverTap.

### Test 4 — Logout

1. Tener un usuario identificado.
2. Presionar **Cerrar sesión**.
3. Verificar que `MSG-push` del perfil anterior sea `false`.
4. Confirmar el cambio a un nuevo perfil anónimo.
5. Confirmar que el nuevo perfil tenga `MSG-push = true`.
6. Validar el comportamiento de campañas posteriores.

### Test 5 — Switch de usuario

1. Presionar **Login new user**.
2. Verificar que se cree/cambie al perfil anónimo.
3. Verificar los eventos:

   * `Onboarding Started`
   * `Onboarding Step 1`
4. Verificar posteriormente el login de `10000A03`.
5. Revisar los logs para comparar el estado antes y después del cambio.

---

## Important Notes

Esta aplicación es exclusivamente para **testing y troubleshooting de CleverTap**.

No representa una implementación recomendada para una aplicación de producción.

En particular:

* Los usuarios y emails son valores de prueba.
* `UserDefaults` se inspecciona únicamente para debugging.
* La eliminación de `CachedGUIDS` se utiliza para escenarios controlados de testing.
* Los delays utilizados (`2s`, `3s`, etc.) son parte de las pruebas y no deben interpretarse como una garantía de sincronización del SDK.
* No almacenar credenciales o secretos de CleverTap en el repositorio.
* Las pruebas de profile switching deben realizarse cuidadosamente para evitar interpretar cambios locales del SDK como comportamiento general de producción.

---

## Project Structure

La implementación principal de las pruebas se encuentra en:

```text
ContentView.swift
```

Componentes principales utilizados:

```text
ContentView
├── Login
├── Send Event
├── Login new user
├── Clear cache
├── Cerrar sesión
└── Native Display
    ├── Trigger campaigns
    ├── Display
    ├── Impression
    └── Click
```

## Purpose

Este proyecto sirve como una aplicación mínima para reproducir y validar comportamientos específicos del **CleverTap iOS SDK** durante procesos de implementación, troubleshooting y soporte técnico.
