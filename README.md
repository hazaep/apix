# 🚀 API Core (Working name: Relay)

> Minimalista, scriptable y poderoso — un runtime CLI para interactuar con APIs.

---

## 🧠 ¿Qué es esto?

**API Core** es una herramienta CLI que te permite:

* Definir endpoints como código
* Ejecutarlos con variables dinámicas
* Manejar múltiples entornos
* Registrar historial automáticamente
* Integrarse con pipelines y scripts

Es una mezcla entre:

```text
curl + jq + Postman + bash
```

Pero orientado a **automatización real**, no UI.

---

## ⚡ Características

* 🧩 DSL simple para endpoints (`header:`, `body:`)
* 🌍 Soporte multi-entorno (`dev`, `prod`, etc.)
* 🧠 Templates dinámicos (`{{variable}}`)
* 📜 Historial persistente con SQLite
* 🔁 Replay de requests
* 🧪 Flags avanzadas de salida (`--json`, `--silent`, etc.)
* 🧰 Modo interactivo

---

## 📁 Estructura del proyecto

```txt
.
├── bin/            # CLI entrypoint
├── data/           # Datos persistentes
├── src/            # Lógica principal
│   ├── add.sh
│   ├── envs.sh
│   ├── executor.sh
│   └── lib/
│       ├── config.sh
│       ├── db.sh
│       ├── interactive.sh
│       ├── parser.sh
│       └── renderer.sh
└── zsh/            # Integración con Zsh
```

---

## 🚀 Instalación

```bash
git clone https://github.com/hazaep/api-core.git
cd api-core

chmod +x bin/api-core
```

Agregar al PATH:

```bash
export PATH="$PWD/bin:$PATH"
```

---

## 🧪 Uso básico

### 📌 Listar endpoints

```bash
api-core list
```

---

### ▶️ Ejecutar endpoint

```bash
api-core run get_users
```

Con variables:

```bash
api-core run create_post title="Hola" body="Mundo"
```

Con entorno:

```bash
api-core run get_users --env=dev
```

---

## 🌍 Manejo de entornos

### Crear entorno

```bash
api-core env add dev https://api.dev.com \
  header:Authorization="Bearer token-dev"
```

### Listar entornos

```bash
api-core env list
```

---

## 🧩 Crear endpoints

```bash
api-core add create_post POST /posts \
  header:Content-Type=application/json \
  body:title="{{title}}" \
  body:body="{{body}}"
```

---

## 🧪 Modo interactivo

```bash
api-core add --interactive
```

---

## 🧾 Historial

```bash
api-core history
```

---

## 🔁 Replay

```bash
api-core replay 10
```

---

## 🎛️ Flags de salida

| Flag        | Descripción      |
| ----------- | ---------------- |
| `--verbose` | Debug completo   |
| `--silent`  | Solo body        |
| `--json`    | Body formateado  |
| `--status`  | Solo código HTTP |
| `--headers` | Solo headers     |
| `--raw`     | Respuesta cruda  |
| `--path`    | Extraer con jq   |

---

### Ejemplos

```bash
api-core run vila --json
api-core run vila --status
api-core run vila --path '.output'
```

---

## 🧠 Filosofía

API Core está diseñado para:

* Automatización
* Scripting
* Integración con shell
* Reproducibilidad

No intenta reemplazar Postman, sino complementarlo.

---

## 🔐 (Próximamente) Secrets

Soporte planeado para:

* `.env` por entorno
* Variables dinámicas (`{{TOKEN}}`)
* Integración con gestores de secretos
* Cifrado opcional

---

## ⚠️ Limitaciones actuales

* Sin sistema de secrets (aún)
* Validación limitada de inputs
* Basado en Bash (escalabilidad futura a otro lenguaje)

---

## 🧬 Roadmap

* [ ] Secrets management
* [ ] Autocompletado Zsh avanzado
* [ ] Import/export de colecciones
* [ ] Validación de schema
* [ ] Plugins / extensiones
* [ ] Migración a lenguaje compilado (Go/Rust)

---

## 💡 Ideas de uso

* Automatización de APIs internas
* Integración con n8n / webhooks
* Testing rápido de endpoints
* OSINT / pentesting
* Data pipelines

---

## 🏷️ Naming

Nombre actual: `api-core`
Candidato futuro: **relay**

---

## 📜 Licencia

MIT

---

## ✨ Autor

[@hazaep](https://github.com/hazaep)

---

## 🔥 Contribuciones

Las contribuciones son bienvenidas.
Este proyecto está en evolución activa.
