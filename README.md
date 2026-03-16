# 🎮 GameDev Management

Sistema de gestión para estudios de desarrollo de videojuegos. Aplicación de escritorio construida con **Python + Tkinter** conectada a una base de datos **MySQL**, que permite administrar videojuegos, miembros del equipo, tareas de desarrollo y assets gráficos.

---

## 📸 Vista General

La aplicación cuenta con 4 pestañas principales:

| Pestaña | Descripción |
|---|---|
| 🎮 Video Juegos | Gestión de proyectos de videojuegos |
| 👤 Miembros | Administración del equipo de desarrollo |
| 📋 Tareas de Desarrollo | Seguimiento de tareas por módulo |
| 🖼️ Assets Gráficos | Control de assets visuales del proyecto |

---

## 🛠️ Tecnologías Utilizadas

- **Python 3.x**
- **Tkinter** — Interfaz gráfica de usuario
- **MySQL** — Base de datos relacional
- **mysql-connector-python** — Conexión Python ↔ MySQL
- **tkcalendar** — Selector de fechas en la UI
- **openpyxl** — Exportación a Excel

---

## 📋 Requisitos Previos

- Python 3.8 o superior
- MySQL Server corriendo localmente
- La base de datos `gamedev` creada con sus tablas y stored procedures

---

## ⚙️ Instalación

**1. Clona el repositorio:**
```bash
git clone https://github.com/oatabaresmoreno-crypto/GameDev_DB.git
cd gamedev-management
```

**2. Instala las dependencias:**
```bash
pip install mysql-connector-python tkcalendar openpyxl
```

> Si tienes problemas con pip, prueba:
> ```bash
> pip3 install mysql-connector-python tkcalendar openpyxl
> ```
> o
> ```bash
> python -m pip install mysql-connector-python tkcalendar openpyxl
> ```

**3. Configura la base de datos:**

Ejecuta el archivo SQL en tu servidor MySQL:
```bash
mysql -u root -p < gamedev.sql
```

Esto creará la base de datos `gamedev` con todas las tablas, stored procedures y datos de ejemplo.

**4. Configura la conexión:**

Abre `gamedev_crud.py` y edita las credenciales al final del archivo:
```python
db = DatabaseConnector(
    host="localhost",
    user="root",
    password="tu_contraseña",   # ← cambia esto
    database="gamedev"
)
```

**5. Ejecuta la aplicación:**
```bash
python gamedev_crud.py
```

---

## 🗄️ Estructura de la Base de Datos

```
gamedev
├── videojuego          → Proyectos de videojuegos
├── miembro_equipo      → Miembros del equipo
├── miembro_proyecto    → Asignación de miembros a proyectos
├── tarea               → Tareas de desarrollo
└── asset_grafico       → Assets gráficos
```

---

## ✨ Funcionalidades

### CRUD Completo
Cada pestaña permite:
- ✅ **Guardar** — Insertar nuevos registros
- ✅ **Actualizar** — Modificar registros existentes
- ✅ **Eliminar** — Borrar registros (con confirmación)
- ✅ **Buscar** — Filtrar registros por término de búsqueda
- ✅ **Mostrar Todos** — Ver todos los registros en la tabla

### Exportación a Excel
- Botón **📊 Exportar Excel** en cada pestaña
- Exporta exactamente lo que se ve en pantalla (respeta filtros de búsqueda)
- Genera archivo `.xlsx` con:
  - Encabezados con formato (fondo azul, letra blanca)
  - Filas alternadas para mejor lectura
  - Columnas ajustadas automáticamente
  - Primera fila fija (freeze panes)
  - Nombre de archivo con fecha y hora automática

### Selección inteligente
Al hacer clic en cualquier fila de la tabla, los datos se cargan automáticamente en el formulario listos para editar o eliminar.

---

## 📁 Estructura del Proyecto

```
gamedev-management/
├── gamedev_crud.py     # Aplicación principal
├── gamedev.sql         # Script de base de datos (tablas + SPs + datos de ejemplo)
└── README.md
```

---

## 🧩 Arquitectura del Código

```
GameDevApp (tk.Tk)
│
├── DatabaseConnector       # Manejo de conexión y stored procedures
│
└── ttk.Notebook
    ├── VideoJuegoTab       # Pestaña Video Juegos
    ├── MiembroEquipoTab    # Pestaña Miembros
    ├── TareaTab            # Pestaña Tareas
    └── AssetGraficoTab     # Pestaña Assets
         │
         └── BaseTab (clase padre)
               ├── Treeview con scrollbars
               ├── Formulario dinámico
               ├── Barra de búsqueda
               ├── Botones CRUD
               └── Exportación a Excel
```

Todas las operaciones de base de datos se realizan a través de **Stored Procedures** en MySQL, lo que mantiene la lógica de negocio en la base de datos y el código Python limpio.

---

## 📦 Dependencias

| Librería | Versión mínima | Uso |
|---|---|---|
| mysql-connector-python | 8.0+ | Conexión a MySQL |
| tkcalendar | 1.6+ | Selector de fechas |
| openpyxl | 3.0+ | Exportar a Excel |

---

## 📄 Licencia

Este proyecto es de uso académico/educativo.
