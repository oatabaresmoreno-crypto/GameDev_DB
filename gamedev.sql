-- ============================================================
--  BASE DE DATOS: ESTUDIO DE DESARROLLO DE VIDEOJUEGOS
--  Motor: MySQL
--  Aplicación: Northwind Management (Tkinter)
-- ============================================================

-- Crear y seleccionar la base de datos
DROP DATABASE IF EXISTS gamedev;
CREATE DATABASE gamedev;
USE gamedev;

-- ============================================================
-- TABLA: videojuego
-- Pestaña 1 - "Video Juegos"
-- ============================================================
CREATE TABLE videojuego (
    codigo              VARCHAR(20)     NOT NULL,
    titulo              VARCHAR(150)    NOT NULL,
    genero              ENUM('accion', 'aventura', 'estrategia', 'rol') NOT NULL,
    plataformas         ENUM('PC', 'Consolas', 'Moviles')               NOT NULL,
    clasificacion_tipo  ENUM('ESRB', 'PEGI')                            NULL,       -- Radio button: ESRB o PEGI
    clasificacion_valor VARCHAR(10)                                      NULL,       -- Valor: E, T, M / 3, 7, 12, 16, 18
    fecha_inicio        DATE            NOT NULL,
    fecha_lanzamiento   DATE            NULL,
    presupuesto         DECIMAL(15,2)   NOT NULL DEFAULT 0.00,
    motor_grafico       VARCHAR(100)    NULL,
    equipo_desarrollo   VARCHAR(200)    NULL,
    estado              ENUM('pre-produccion', 'en desarrollo', 'beta', 'lanzado', 'cancelado')
                                        NOT NULL DEFAULT 'en desarrollo',
    creado_en           TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (codigo)
);

-- ============================================================
-- TABLA: miembro_equipo
-- Pestaña 2 - "Miembros"
-- ============================================================
CREATE TABLE miembro_equipo (
    codigo_empleado         VARCHAR(20)     NOT NULL,
    nombres                 VARCHAR(100)    NOT NULL,
    apellidos               VARCHAR(100)    NOT NULL,
    especialidad            ENUM('programacion', 'arte', 'diseno', 'musica', 'testing') NOT NULL,
    habilidades_especificas TEXT            NULL,
    experiencia_previa      TEXT            NULL,
    creado_en               TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (codigo_empleado)
);

-- ============================================================
-- TABLA: miembro_proyecto
-- Pestaña 2 - Campos: Proyectos Asignados / Dedicacion y Rol
-- ============================================================
CREATE TABLE miembro_proyecto (
    id                    INT             NOT NULL AUTO_INCREMENT,
    codigo_videojuego     VARCHAR(20)     NOT NULL,
    codigo_empleado       VARCHAR(20)     NOT NULL,
    rol_en_proyecto       VARCHAR(100)    NOT NULL,
    porcentaje_dedicacion INT             NOT NULL DEFAULT 100,
    fecha_inicio          DATE            NULL,
    fecha_fin             DATE            NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_miembro_proyecto (codigo_videojuego, codigo_empleado, rol_en_proyecto),
    CONSTRAINT chk_dedicacion CHECK (porcentaje_dedicacion BETWEEN 1 AND 100),
    FOREIGN KEY (codigo_videojuego) REFERENCES videojuego(codigo)           ON DELETE CASCADE,
    FOREIGN KEY (codigo_empleado)   REFERENCES miembro_equipo(codigo_empleado) ON DELETE CASCADE
);

-- ============================================================
-- TABLA: tarea
-- Pestaña 3 - "Tareas De Desarrollo"
-- ============================================================
CREATE TABLE tarea (
    codigo              VARCHAR(30)     NOT NULL,
    codigo_videojuego   VARCHAR(20)     NOT NULL,
    modulo              ENUM('jugabilidad', 'graficos', 'sonido', 'ia') NOT NULL,
    descripcion         TEXT            NOT NULL,
    prioridad           ENUM('baja', 'media', 'alta', 'critica')        NOT NULL DEFAULT 'media',
    estado              ENUM('pendiente', 'en proceso', 'revision', 'completada') NOT NULL DEFAULT 'pendiente',
    responsable         VARCHAR(20)     NULL,
    fecha_asignacion    DATE            NULL,
    fecha_limite        DATE            NULL,
    porcentaje_avance   INT             NOT NULL DEFAULT 0,
    dependencias        TEXT            NULL,    -- Codigos de tareas previas separados por coma
    creado_en           TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (codigo),
    CONSTRAINT chk_avance CHECK (porcentaje_avance BETWEEN 0 AND 100),
    FOREIGN KEY (codigo_videojuego) REFERENCES videojuego(codigo)           ON DELETE CASCADE,
    FOREIGN KEY (responsable)       REFERENCES miembro_equipo(codigo_empleado) ON DELETE SET NULL
);

-- ============================================================
-- TABLA: asset_grafico
-- Pestaña 4 - "Assets Graficos"
-- ============================================================
CREATE TABLE asset_grafico (
    codigo                  VARCHAR(30)     NOT NULL,
    nombre                  VARCHAR(150)    NOT NULL,
    tipo                    ENUM('personaje', 'escenario', 'objeto', 'interfaz') NOT NULL,
    descripcion             TEXT            NULL,
    formato                 VARCHAR(20)     NULL,    -- PNG, PSD, FBX, SVG, etc.
    resolucion              VARCHAR(30)     NULL,    -- Ej: "1920x1080", "4096x4096"
    artista_responsable     VARCHAR(20)     NULL,
    version_actual          VARCHAR(10)     NOT NULL DEFAULT '1.0',
    fecha_modificacion      DATE            NULL,
    requisitos_tecnicos     TEXT            NULL,
    estado_aprobacion       ENUM('pendiente', 'en revision', 'aprobado', 'rechazado') NOT NULL DEFAULT 'pendiente',
    codigo_videojuego       VARCHAR(20)     NULL,
    creado_en               TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (codigo),
    FOREIGN KEY (artista_responsable) REFERENCES miembro_equipo(codigo_empleado) ON DELETE SET NULL,
    FOREIGN KEY (codigo_videojuego)   REFERENCES videojuego(codigo)               ON DELETE SET NULL
);

-- ============================================================
-- ÍNDICES para mejorar rendimiento
-- ============================================================
CREATE INDEX idx_vj_genero          ON videojuego(genero);
CREATE INDEX idx_vj_estado          ON videojuego(estado);
CREATE INDEX idx_me_especialidad    ON miembro_equipo(especialidad);
CREATE INDEX idx_mp_videojuego      ON miembro_proyecto(codigo_videojuego);
CREATE INDEX idx_mp_empleado        ON miembro_proyecto(codigo_empleado);
CREATE INDEX idx_tarea_vj           ON tarea(codigo_videojuego);
CREATE INDEX idx_tarea_estado       ON tarea(estado);
CREATE INDEX idx_tarea_responsable  ON tarea(responsable);
CREATE INDEX idx_asset_tipo         ON asset_grafico(tipo);
CREATE INDEX idx_asset_aprobacion   ON asset_grafico(estado_aprobacion);
CREATE INDEX idx_asset_vj           ON asset_grafico(codigo_videojuego);

-- ============================================================
-- DATOS DE EJEMPLO
-- ============================================================

-- Videojuegos
INSERT INTO videojuego (codigo, titulo, genero, plataformas, clasificacion_tipo, clasificacion_valor, fecha_inicio, fecha_lanzamiento, presupuesto, motor_grafico, equipo_desarrollo, estado) VALUES
('VJ-001', 'Shadow Realm', 'rol',       'PC',      'PEGI', '16', '2024-01-10', '2026-06-01', 850000.00,  'Unreal Engine 5', 'Equipo Alpha',  'en desarrollo'),
('VJ-002', 'Pixel Blitz',  'accion',    'Moviles', 'ESRB', 'E',  '2023-09-01', '2025-12-15', 200000.00,  'Unity',           'Equipo Beta',   'beta'),
('VJ-003', 'Conquest Era', 'estrategia','PC',      'PEGI', '12', '2024-03-20', '2027-03-01', 1200000.00, 'Godot 4',         'Equipo Gamma',  'pre-produccion');

-- Miembros del equipo
INSERT INTO miembro_equipo (codigo_empleado, nombres, apellidos, especialidad, habilidades_especificas, experiencia_previa) VALUES
('EMP-001', 'Carlos',    'Mendoza',  'programacion', 'C++, Python, Unreal Blueprint',     'The Last Portal, CyberRun'),
('EMP-002', 'Laura',     'Quintero', 'arte',         'Maya, Photoshop, Substance Painter', 'Shadow Path, NeonCity'),
('EMP-003', 'Diego',     'Ríos',     'diseno',       'Prototipado, UX, Nivel Design',      'Pixel Farm, Ruins of Ardor'),
('EMP-004', 'Valentina', 'Castillo', 'musica',       'Composición, FMOD, Wwise',           'Harmony Quest'),
('EMP-005', 'Andrés',    'Herrera',  'testing',      'QA, automatización, Unity Testing',  'BugBusters Studio');

-- Asignación de miembros a proyectos
INSERT INTO miembro_proyecto (codigo_videojuego, codigo_empleado, rol_en_proyecto, porcentaje_dedicacion, fecha_inicio) VALUES
('VJ-001', 'EMP-001', 'Lead Programmer', 80,  '2024-01-10'),
('VJ-001', 'EMP-002', 'Art Director',    100, '2024-01-10'),
('VJ-001', 'EMP-004', 'Compositor',      50,  '2024-02-01'),
('VJ-002', 'EMP-003', 'Game Designer',   100, '2023-09-01'),
('VJ-002', 'EMP-005', 'QA Lead',         100, '2023-09-01'),
('VJ-003', 'EMP-001', 'Programador',     20,  '2024-03-20');

-- Tareas de desarrollo
INSERT INTO tarea (codigo, codigo_videojuego, modulo, descripcion, prioridad, estado, responsable, fecha_asignacion, fecha_limite, porcentaje_avance, dependencias) VALUES
('TRK-001', 'VJ-001', 'jugabilidad', 'Sistema de combate cuerpo a cuerpo',  'alta',   'en proceso',  'EMP-001', '2024-02-01', '2024-05-01',  65, NULL),
('TRK-002', 'VJ-001', 'graficos',    'Modelado personaje principal',         'alta',   'revision',    'EMP-002', '2024-02-10', '2024-04-15',  90, NULL),
('TRK-003', 'VJ-001', 'sonido',      'Banda sonora intro cinemática',        'media',  'pendiente',   'EMP-004', '2024-03-01', '2024-07-01',   0, 'TRK-002'),
('TRK-004', 'VJ-002', 'ia',          'IA de enemigos adaptativos',           'critica','en proceso',  'EMP-003', '2023-10-01', '2024-01-31',  75, NULL),
('TRK-005', 'VJ-002', 'jugabilidad', 'Controles táctiles y hápticos',        'alta',   'completada',  'EMP-005', '2023-09-15', '2023-12-01', 100, NULL);

-- Assets gráficos
INSERT INTO asset_grafico (codigo, nombre, tipo, descripcion, formato, resolucion, artista_responsable, version_actual, fecha_modificacion, requisitos_tecnicos, estado_aprobacion, codigo_videojuego) VALUES
('AST-001', 'Héroe Principal',   'personaje', 'Modelo 3D del protagonista de Shadow Realm', 'FBX', '4096x4096', 'EMP-002', '2.1', '2024-03-10', 'LOD 0-3, PBR textures', 'aprobado',    'VJ-001'),
('AST-002', 'Bosque Oscuro',     'escenario', 'Escenario nivel 1 - Shadow Realm',           'FBX', '8192x8192', 'EMP-002', '1.3', '2024-03-18', 'Lightmaps prebaked',    'en revision', 'VJ-001'),
('AST-003', 'Menú Principal',    'interfaz',  'UI del menú principal de Pixel Blitz',       'PNG', '1080x1920', 'EMP-003', '1.0', '2024-01-05', 'Formato móvil 9:16',    'aprobado',    'VJ-002'),
('AST-004', 'Espada Legendaria', 'objeto',    'Arma especial desbloqueada en nivel 5',      'PNG', '512x512',   'EMP-002', '1.0', '2024-02-20', 'Atlas de sprites',      'pendiente',   'VJ-001');

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
SELECT 'videojuego'     AS tabla, COUNT(*) AS registros FROM videojuego
UNION ALL
SELECT 'miembro_equipo',          COUNT(*) FROM miembro_equipo
UNION ALL
SELECT 'miembro_proyecto',        COUNT(*) FROM miembro_proyecto
UNION ALL
SELECT 'tarea',                   COUNT(*) FROM tarea
UNION ALL
SELECT 'asset_grafico',           COUNT(*) FROM asset_grafico;

-- ============================================================
--  STORED PROCEDURES: ESTUDIO DE DESARROLLO DE VIDEOJUEGOS
--  Motor: MySQL | Base de datos: gamedev
-- ============================================================

USE gamedev;

DELIMITER //

-- =====================================================
-- PROCEDIMIENTOS PARA VIDEOJUEGO
-- =====================================================

-- 1. INSERTAR VIDEOJUEGO
CREATE PROCEDURE sp_InsertVideojuego(
    IN p_codigo               VARCHAR(20),
    IN p_titulo               VARCHAR(150),
    IN p_genero               VARCHAR(20),
    IN p_plataformas          VARCHAR(100),
    IN p_clasificacion_tipo   VARCHAR(10),
    IN p_clasificacion_valor  VARCHAR(10),
    IN p_fecha_inicio         DATE,
    IN p_fecha_lanzamiento    DATE,
    IN p_presupuesto          DECIMAL(15,2),
    IN p_motor_grafico        VARCHAR(100),
    IN p_equipo_desarrollo    VARCHAR(200),
    IN p_estado               VARCHAR(30)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO videojuego (
        codigo, titulo, genero, plataformas,
        clasificacion_tipo, clasificacion_valor,
        fecha_inicio, fecha_lanzamiento,
        presupuesto, motor_grafico,
        equipo_desarrollo, estado
    )
    VALUES (
        p_codigo, p_titulo, p_genero, p_plataformas,
        p_clasificacion_tipo, p_clasificacion_valor,
        p_fecha_inicio, p_fecha_lanzamiento,
        p_presupuesto, p_motor_grafico,
        p_equipo_desarrollo, p_estado
    );

    COMMIT;

    SELECT p_codigo AS codigo, 'Videojuego insertado correctamente' AS Message;
END//

-- 2. ACTUALIZAR VIDEOJUEGO
CREATE PROCEDURE sp_UpdateVideojuego(
    IN p_codigo               VARCHAR(20),
    IN p_titulo               VARCHAR(150),
    IN p_genero               VARCHAR(20),
    IN p_plataformas          VARCHAR(100),
    IN p_clasificacion_tipo   VARCHAR(10),
    IN p_clasificacion_valor  VARCHAR(10),
    IN p_fecha_inicio         DATE,
    IN p_fecha_lanzamiento    DATE,
    IN p_presupuesto          DECIMAL(15,2),
    IN p_motor_grafico        VARCHAR(100),
    IN p_equipo_desarrollo    VARCHAR(200),
    IN p_estado               VARCHAR(30)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM videojuego WHERE codigo = p_codigo;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El videojuego no existe';
    END IF;

    UPDATE videojuego
    SET titulo              = p_titulo,
        genero              = p_genero,
        plataformas         = p_plataformas,
        clasificacion_tipo  = p_clasificacion_tipo,
        clasificacion_valor = p_clasificacion_valor,
        fecha_inicio        = p_fecha_inicio,
        fecha_lanzamiento   = p_fecha_lanzamiento,
        presupuesto         = p_presupuesto,
        motor_grafico       = p_motor_grafico,
        equipo_desarrollo   = p_equipo_desarrollo,
        estado              = p_estado
    WHERE codigo = p_codigo;

    COMMIT;

    SELECT 'Videojuego actualizado correctamente' AS Message;
END//

-- 3. ELIMINAR VIDEOJUEGO
CREATE PROCEDURE sp_DeleteVideojuego(
    IN p_codigo VARCHAR(20)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM videojuego WHERE codigo = p_codigo;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El videojuego no existe';
    END IF;

    -- Verificar tareas asociadas
    SELECT COUNT(*) INTO v_count FROM tarea WHERE codigo_videojuego = p_codigo;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: el videojuego tiene tareas asociadas';
    END IF;

    -- Verificar assets gráficos asociados
    SELECT COUNT(*) INTO v_count FROM asset_grafico WHERE codigo_videojuego = p_codigo;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: el videojuego tiene assets gráficos asociados';
    END IF;

    DELETE FROM videojuego WHERE codigo = p_codigo;

    COMMIT;

    SELECT 'Videojuego eliminado correctamente' AS Message;
END//

-- 4. OBTENER VIDEOJUEGO POR CÓDIGO
CREATE PROCEDURE sp_GetVideojuego(
    IN p_codigo VARCHAR(20)
)
BEGIN
    SELECT codigo, titulo, genero, plataformas,
           clasificacion_tipo, clasificacion_valor,
           fecha_inicio, fecha_lanzamiento,
           presupuesto, motor_grafico,
           equipo_desarrollo, estado, creado_en
    FROM videojuego
    WHERE codigo = p_codigo;
END//

-- 5. OBTENER TODOS LOS VIDEOJUEGOS
CREATE PROCEDURE sp_GetAllVideojuegos()
BEGIN
    SELECT codigo, titulo, genero, plataformas,
           clasificacion_tipo, clasificacion_valor,
           fecha_inicio, fecha_lanzamiento,
           presupuesto, motor_grafico,
           equipo_desarrollo, estado, creado_en
    FROM videojuego
    ORDER BY titulo;
END//

-- 6. BUSCAR VIDEOJUEGOS POR TÍTULO O GÉNERO
CREATE PROCEDURE sp_SearchVideojuegos(
    IN p_SearchTerm VARCHAR(100)
)
BEGIN
    SELECT codigo, titulo, genero, plataformas,
           clasificacion_tipo, clasificacion_valor,
           fecha_inicio, fecha_lanzamiento,
           presupuesto, motor_grafico, estado
    FROM videojuego
    WHERE titulo  LIKE CONCAT('%', p_SearchTerm, '%')
       OR genero  LIKE CONCAT('%', p_SearchTerm, '%')
       OR estado  LIKE CONCAT('%', p_SearchTerm, '%')
    ORDER BY titulo;
END//


-- =====================================================
-- PROCEDIMIENTOS PARA MIEMBRO_EQUIPO
-- =====================================================

-- 1. INSERTAR MIEMBRO DE EQUIPO
CREATE PROCEDURE sp_InsertMiembroEquipo(
    IN p_codigo_empleado        VARCHAR(20),
    IN p_nombres                VARCHAR(100),
    IN p_apellidos              VARCHAR(100),
    IN p_especialidad           VARCHAR(20),
    IN p_habilidades_especificas TEXT,
    IN p_experiencia_previa     TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO miembro_equipo (
        codigo_empleado, nombres, apellidos,
        especialidad, habilidades_especificas,
        experiencia_previa
    )
    VALUES (
        p_codigo_empleado, p_nombres, p_apellidos,
        p_especialidad, p_habilidades_especificas,
        p_experiencia_previa
    );

    COMMIT;

    SELECT p_codigo_empleado AS codigo_empleado, 'Miembro de equipo insertado correctamente' AS Message;
END//

-- 2. ACTUALIZAR MIEMBRO DE EQUIPO
CREATE PROCEDURE sp_UpdateMiembroEquipo(
    IN p_codigo_empleado        VARCHAR(20),
    IN p_nombres                VARCHAR(100),
    IN p_apellidos              VARCHAR(100),
    IN p_especialidad           VARCHAR(20),
    IN p_habilidades_especificas TEXT,
    IN p_experiencia_previa     TEXT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM miembro_equipo WHERE codigo_empleado = p_codigo_empleado;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro de equipo no existe';
    END IF;

    UPDATE miembro_equipo
    SET nombres                 = p_nombres,
        apellidos               = p_apellidos,
        especialidad            = p_especialidad,
        habilidades_especificas = p_habilidades_especificas,
        experiencia_previa      = p_experiencia_previa
    WHERE codigo_empleado = p_codigo_empleado;

    COMMIT;

    SELECT 'Miembro de equipo actualizado correctamente' AS Message;
END//

-- 3. ELIMINAR MIEMBRO DE EQUIPO
CREATE PROCEDURE sp_DeleteMiembroEquipo(
    IN p_codigo_empleado VARCHAR(20)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM miembro_equipo WHERE codigo_empleado = p_codigo_empleado;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro de equipo no existe';
    END IF;

    -- Verificar si tiene proyectos asignados
    SELECT COUNT(*) INTO v_count FROM miembro_proyecto WHERE codigo_empleado = p_codigo_empleado;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: el miembro tiene proyectos asignados';
    END IF;

    DELETE FROM miembro_equipo WHERE codigo_empleado = p_codigo_empleado;

    COMMIT;

    SELECT 'Miembro de equipo eliminado correctamente' AS Message;
END//

-- 4. OBTENER MIEMBRO DE EQUIPO POR CÓDIGO
CREATE PROCEDURE sp_GetMiembroEquipo(
    IN p_codigo_empleado VARCHAR(20)
)
BEGIN
    SELECT me.codigo_empleado, me.nombres, me.apellidos,
           me.especialidad, me.habilidades_especificas,
           me.experiencia_previa, me.creado_en,
           GROUP_CONCAT(CONCAT(mp.rol_en_proyecto, ' (', vj.titulo, ') - ', mp.porcentaje_dedicacion, '%')
               ORDER BY vj.titulo SEPARATOR ' | ') AS proyectos_asignados
    FROM miembro_equipo me
    LEFT JOIN miembro_proyecto mp ON me.codigo_empleado = mp.codigo_empleado
    LEFT JOIN videojuego       vj ON mp.codigo_videojuego = vj.codigo
    WHERE me.codigo_empleado = p_codigo_empleado
    GROUP BY me.codigo_empleado;
END//

-- 5. OBTENER TODOS LOS MIEMBROS DE EQUIPO
CREATE PROCEDURE sp_GetAllMiembrosEquipo()
BEGIN
    SELECT me.codigo_empleado,
           me.nombres, me.apellidos,
           me.especialidad,
           me.habilidades_especificas,
           me.experiencia_previa,
           COUNT(mp.id) AS total_proyectos,
           me.creado_en
    FROM miembro_equipo me
    LEFT JOIN miembro_proyecto mp ON me.codigo_empleado = mp.codigo_empleado
    GROUP BY me.codigo_empleado
    ORDER BY me.apellidos, me.nombres;
END//

-- 6. BUSCAR MIEMBROS POR NOMBRE O ESPECIALIDAD
CREATE PROCEDURE sp_SearchMiembrosEquipo(
    IN p_SearchTerm VARCHAR(100)
)
BEGIN
    SELECT codigo_empleado, nombres, apellidos,
           especialidad, habilidades_especificas
    FROM miembro_equipo
    WHERE nombres      LIKE CONCAT('%', p_SearchTerm, '%')
       OR apellidos    LIKE CONCAT('%', p_SearchTerm, '%')
       OR especialidad LIKE CONCAT('%', p_SearchTerm, '%')
    ORDER BY apellidos, nombres;
END//


-- =====================================================
-- PROCEDIMIENTOS PARA MIEMBRO_PROYECTO
-- =====================================================

-- 1. INSERTAR MIEMBRO EN PROYECTO
CREATE PROCEDURE sp_InsertMiembroProyecto(
    IN p_codigo_videojuego     VARCHAR(20),
    IN p_codigo_empleado       VARCHAR(20),
    IN p_rol_en_proyecto       VARCHAR(100),
    IN p_porcentaje_dedicacion INT,
    IN p_fecha_inicio          DATE,
    IN p_fecha_fin             DATE
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM videojuego WHERE codigo = p_codigo_videojuego;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El videojuego no existe';
    END IF;

    SELECT COUNT(*) INTO v_count FROM miembro_equipo WHERE codigo_empleado = p_codigo_empleado;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro de equipo no existe';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM miembro_proyecto
    WHERE codigo_videojuego = p_codigo_videojuego
      AND codigo_empleado   = p_codigo_empleado
      AND rol_en_proyecto   = p_rol_en_proyecto;

    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro ya tiene ese rol asignado en este proyecto';
    END IF;

    INSERT INTO miembro_proyecto (
        codigo_videojuego, codigo_empleado,
        rol_en_proyecto, porcentaje_dedicacion,
        fecha_inicio, fecha_fin
    )
    VALUES (
        p_codigo_videojuego, p_codigo_empleado,
        p_rol_en_proyecto, p_porcentaje_dedicacion,
        p_fecha_inicio, p_fecha_fin
    );

    COMMIT;

    SELECT LAST_INSERT_ID() AS id, 'Miembro agregado al proyecto correctamente' AS Message;
END//

-- 2. ACTUALIZAR MIEMBRO EN PROYECTO
CREATE PROCEDURE sp_UpdateMiembroProyecto(
    IN p_id                    INT,
    IN p_rol_en_proyecto       VARCHAR(100),
    IN p_porcentaje_dedicacion INT,
    IN p_fecha_inicio          DATE,
    IN p_fecha_fin             DATE
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM miembro_proyecto WHERE id = p_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La asignación no existe';
    END IF;

    UPDATE miembro_proyecto
    SET rol_en_proyecto       = p_rol_en_proyecto,
        porcentaje_dedicacion = p_porcentaje_dedicacion,
        fecha_inicio          = p_fecha_inicio,
        fecha_fin             = p_fecha_fin
    WHERE id = p_id;

    COMMIT;

    SELECT 'Asignación de proyecto actualizada correctamente' AS Message;
END//

-- 3. ELIMINAR MIEMBRO DE PROYECTO
CREATE PROCEDURE sp_DeleteMiembroProyecto(
    IN p_id INT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM miembro_proyecto WHERE id = p_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La asignación no existe';
    END IF;

    DELETE FROM miembro_proyecto WHERE id = p_id;

    COMMIT;

    SELECT 'Miembro removido del proyecto correctamente' AS Message;
END//

-- 4. OBTENER MIEMBROS POR VIDEOJUEGO
CREATE PROCEDURE sp_GetMiembrosByVideojuego(
    IN p_codigo_videojuego VARCHAR(20)
)
BEGIN
    SELECT mp.id,
           mp.codigo_videojuego,
           vj.titulo AS titulo_videojuego,
           mp.codigo_empleado,
           me.nombres, me.apellidos, me.especialidad,
           mp.rol_en_proyecto,
           mp.porcentaje_dedicacion,
           mp.fecha_inicio, mp.fecha_fin
    FROM miembro_proyecto mp
    INNER JOIN miembro_equipo me ON mp.codigo_empleado   = me.codigo_empleado
    INNER JOIN videojuego     vj ON mp.codigo_videojuego = vj.codigo
    WHERE mp.codigo_videojuego = p_codigo_videojuego
    ORDER BY me.apellidos, me.nombres;
END//

-- 5. OBTENER PROYECTOS POR MIEMBRO
CREATE PROCEDURE sp_GetProyectosByMiembro(
    IN p_codigo_empleado VARCHAR(20)
)
BEGIN
    SELECT mp.id,
           vj.codigo, vj.titulo, vj.estado,
           mp.rol_en_proyecto,
           mp.porcentaje_dedicacion,
           mp.fecha_inicio, mp.fecha_fin
    FROM miembro_proyecto mp
    INNER JOIN videojuego vj ON mp.codigo_videojuego = vj.codigo
    WHERE mp.codigo_empleado = p_codigo_empleado
    ORDER BY vj.titulo;
END//


-- =====================================================
-- PROCEDIMIENTOS PARA TAREA
-- =====================================================

-- 1. INSERTAR TAREA
CREATE PROCEDURE sp_InsertTarea(
    IN p_codigo            VARCHAR(30),
    IN p_codigo_videojuego VARCHAR(20),
    IN p_modulo            VARCHAR(20),
    IN p_descripcion       TEXT,
    IN p_prioridad         VARCHAR(10),
    IN p_estado            VARCHAR(15),
    IN p_responsable       VARCHAR(20),
    IN p_fecha_asignacion  DATE,
    IN p_fecha_limite      DATE,
    IN p_porcentaje_avance INT,
    IN p_dependencias      TEXT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM videojuego WHERE codigo = p_codigo_videojuego;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El videojuego no existe';
    END IF;

    IF p_responsable IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM miembro_equipo WHERE codigo_empleado = p_responsable;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El responsable no existe como miembro de equipo';
        END IF;
    END IF;

    INSERT INTO tarea (
        codigo, codigo_videojuego, modulo,
        descripcion, prioridad, estado,
        responsable, fecha_asignacion, fecha_limite,
        porcentaje_avance, dependencias
    )
    VALUES (
        p_codigo, p_codigo_videojuego, p_modulo,
        p_descripcion, p_prioridad, p_estado,
        p_responsable, p_fecha_asignacion, p_fecha_limite,
        p_porcentaje_avance, p_dependencias
    );

    COMMIT;

    SELECT p_codigo AS codigo, 'Tarea insertada correctamente' AS Message;
END//

-- 2. ACTUALIZAR TAREA
CREATE PROCEDURE sp_UpdateTarea(
    IN p_codigo            VARCHAR(30),
    IN p_modulo            VARCHAR(20),
    IN p_descripcion       TEXT,
    IN p_prioridad         VARCHAR(10),
    IN p_estado            VARCHAR(15),
    IN p_responsable       VARCHAR(20),
    IN p_fecha_asignacion  DATE,
    IN p_fecha_limite      DATE,
    IN p_porcentaje_avance INT,
    IN p_dependencias      TEXT
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM tarea WHERE codigo = p_codigo;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La tarea no existe';
    END IF;

    IF p_responsable IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM miembro_equipo WHERE codigo_empleado = p_responsable;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El responsable no existe como miembro de equipo';
        END IF;
    END IF;

    UPDATE tarea
    SET modulo            = p_modulo,
        descripcion       = p_descripcion,
        prioridad         = p_prioridad,
        estado            = p_estado,
        responsable       = p_responsable,
        fecha_asignacion  = p_fecha_asignacion,
        fecha_limite      = p_fecha_limite,
        porcentaje_avance = p_porcentaje_avance,
        dependencias      = p_dependencias
    WHERE codigo = p_codigo;

    COMMIT;

    SELECT 'Tarea actualizada correctamente' AS Message;
END//

-- 3. ELIMINAR TAREA
CREATE PROCEDURE sp_DeleteTarea(
    IN p_codigo VARCHAR(30)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM tarea WHERE codigo = p_codigo;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La tarea no existe';
    END IF;

    DELETE FROM tarea WHERE codigo = p_codigo;

    COMMIT;

    SELECT 'Tarea eliminada correctamente' AS Message;
END//

-- 4. OBTENER TAREA POR CÓDIGO
CREATE PROCEDURE sp_GetTarea(
    IN p_codigo VARCHAR(30)
)
BEGIN
    SELECT t.codigo,
           t.codigo_videojuego, vj.titulo AS titulo_videojuego,
           t.modulo, t.descripcion, t.prioridad, t.estado,
           t.responsable,
           me.nombres, me.apellidos,
           t.fecha_asignacion, t.fecha_limite,
           t.porcentaje_avance, t.dependencias, t.creado_en
    FROM tarea t
    LEFT JOIN videojuego    vj ON t.codigo_videojuego = vj.codigo
    LEFT JOIN miembro_equipo me ON t.responsable       = me.codigo_empleado
    WHERE t.codigo = p_codigo;
END//

-- 5. OBTENER TODAS LAS TAREAS DE UN VIDEOJUEGO
CREATE PROCEDURE sp_GetTareasByVideojuego(
    IN p_codigo_videojuego VARCHAR(20)
)
BEGIN
    SELECT t.codigo, t.modulo, t.descripcion,
           t.prioridad, t.estado,
           t.responsable,
           me.nombres, me.apellidos,
           t.fecha_asignacion, t.fecha_limite,
           t.porcentaje_avance, t.dependencias
    FROM tarea t
    LEFT JOIN miembro_equipo me ON t.responsable = me.codigo_empleado
    WHERE t.codigo_videojuego = p_codigo_videojuego
    ORDER BY FIELD(t.prioridad, 'critica', 'alta', 'media', 'baja'), t.fecha_limite;
END//

-- 6. BUSCAR TAREAS POR DESCRIPCIÓN O MÓDULO
CREATE PROCEDURE sp_SearchTareas(
    IN p_SearchTerm VARCHAR(100)
)
BEGIN
    SELECT t.codigo,
           t.codigo_videojuego, vj.titulo AS titulo_videojuego,
           t.modulo, t.descripcion,
           t.prioridad, t.estado,
           t.porcentaje_avance
    FROM tarea t
    LEFT JOIN videojuego vj ON t.codigo_videojuego = vj.codigo
    WHERE t.descripcion LIKE CONCAT('%', p_SearchTerm, '%')
       OR t.modulo      LIKE CONCAT('%', p_SearchTerm, '%')
       OR t.estado      LIKE CONCAT('%', p_SearchTerm, '%')
    ORDER BY t.codigo_videojuego, t.modulo;
END//


-- =====================================================
-- PROCEDIMIENTOS PARA ASSET_GRAFICO
-- =====================================================

-- 1. INSERTAR ASSET GRÁFICO
CREATE PROCEDURE sp_InsertAssetGrafico(
    IN p_codigo                 VARCHAR(30),
    IN p_nombre                 VARCHAR(150),
    IN p_tipo                   VARCHAR(20),
    IN p_descripcion            TEXT,
    IN p_formato                VARCHAR(20),
    IN p_resolucion             VARCHAR(30),
    IN p_artista_responsable    VARCHAR(20),
    IN p_version_actual         VARCHAR(10),
    IN p_fecha_modificacion     DATE,
    IN p_requisitos_tecnicos    TEXT,
    IN p_estado_aprobacion      VARCHAR(20),
    IN p_codigo_videojuego      VARCHAR(20)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_artista_responsable IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM miembro_equipo WHERE codigo_empleado = p_artista_responsable;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El artista responsable no existe como miembro de equipo';
        END IF;
    END IF;

    IF p_codigo_videojuego IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM videojuego WHERE codigo = p_codigo_videojuego;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El videojuego no existe';
        END IF;
    END IF;

    INSERT INTO asset_grafico (
        codigo, nombre, tipo, descripcion,
        formato, resolucion,
        artista_responsable, version_actual,
        fecha_modificacion, requisitos_tecnicos,
        estado_aprobacion, codigo_videojuego
    )
    VALUES (
        p_codigo, p_nombre, p_tipo, p_descripcion,
        p_formato, p_resolucion,
        p_artista_responsable, p_version_actual,
        p_fecha_modificacion, p_requisitos_tecnicos,
        p_estado_aprobacion, p_codigo_videojuego
    );

    COMMIT;

    SELECT p_codigo AS codigo, 'Asset gráfico insertado correctamente' AS Message;
END//

-- 2. ACTUALIZAR ASSET GRÁFICO
CREATE PROCEDURE sp_UpdateAssetGrafico(
    IN p_codigo                 VARCHAR(30),
    IN p_nombre                 VARCHAR(150),
    IN p_tipo                   VARCHAR(20),
    IN p_descripcion            TEXT,
    IN p_formato                VARCHAR(20),
    IN p_resolucion             VARCHAR(30),
    IN p_artista_responsable    VARCHAR(20),
    IN p_version_actual         VARCHAR(10),
    IN p_fecha_modificacion     DATE,
    IN p_requisitos_tecnicos    TEXT,
    IN p_estado_aprobacion      VARCHAR(20),
    IN p_codigo_videojuego      VARCHAR(20)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM asset_grafico WHERE codigo = p_codigo;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El asset gráfico no existe';
    END IF;

    IF p_artista_responsable IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM miembro_equipo WHERE codigo_empleado = p_artista_responsable;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El artista responsable no existe como miembro de equipo';
        END IF;
    END IF;

    IF p_codigo_videojuego IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM videojuego WHERE codigo = p_codigo_videojuego;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El videojuego no existe';
        END IF;
    END IF;

    UPDATE asset_grafico
    SET nombre              = p_nombre,
        tipo                = p_tipo,
        descripcion         = p_descripcion,
        formato             = p_formato,
        resolucion          = p_resolucion,
        artista_responsable = p_artista_responsable,
        version_actual      = p_version_actual,
        fecha_modificacion  = p_fecha_modificacion,
        requisitos_tecnicos = p_requisitos_tecnicos,
        estado_aprobacion   = p_estado_aprobacion,
        codigo_videojuego   = p_codigo_videojuego
    WHERE codigo = p_codigo;

    COMMIT;

    SELECT 'Asset gráfico actualizado correctamente' AS Message;
END//

-- 3. ELIMINAR ASSET GRÁFICO
CREATE PROCEDURE sp_DeleteAssetGrafico(
    IN p_codigo VARCHAR(30)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count FROM asset_grafico WHERE codigo = p_codigo;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El asset gráfico no existe';
    END IF;

    DELETE FROM asset_grafico WHERE codigo = p_codigo;

    COMMIT;

    SELECT 'Asset gráfico eliminado correctamente' AS Message;
END//

-- 4. OBTENER ASSET GRÁFICO POR CÓDIGO
CREATE PROCEDURE sp_GetAssetGrafico(
    IN p_codigo VARCHAR(30)
)
BEGIN
    SELECT ag.codigo, ag.nombre, ag.tipo, ag.descripcion,
           ag.formato, ag.resolucion,
           ag.artista_responsable,
           me.nombres, me.apellidos,
           ag.version_actual, ag.fecha_modificacion,
           ag.requisitos_tecnicos, ag.estado_aprobacion,
           ag.codigo_videojuego,
           vj.titulo AS titulo_videojuego,
           ag.creado_en
    FROM asset_grafico ag
    LEFT JOIN miembro_equipo me ON ag.artista_responsable = me.codigo_empleado
    LEFT JOIN videojuego     vj ON ag.codigo_videojuego   = vj.codigo
    WHERE ag.codigo = p_codigo;
END//

-- 5. OBTENER TODOS LOS ASSETS GRÁFICOS
CREATE PROCEDURE sp_GetAllAssetsGraficos()
BEGIN
    SELECT ag.codigo, ag.nombre, ag.tipo,
           ag.formato, ag.resolucion,
           ag.artista_responsable,
           me.nombres, me.apellidos,
           ag.version_actual, ag.estado_aprobacion,
           ag.codigo_videojuego,
           vj.titulo AS titulo_videojuego
    FROM asset_grafico ag
    LEFT JOIN miembro_equipo me ON ag.artista_responsable = me.codigo_empleado
    LEFT JOIN videojuego     vj ON ag.codigo_videojuego   = vj.codigo
    ORDER BY ag.nombre;
END//

-- 6. OBTENER ASSETS POR VIDEOJUEGO
CREATE PROCEDURE sp_GetAssetsByVideojuego(
    IN p_codigo_videojuego VARCHAR(20)
)
BEGIN
    SELECT ag.codigo, ag.nombre, ag.tipo,
           ag.formato, ag.resolucion,
           ag.artista_responsable,
           me.nombres, me.apellidos,
           ag.version_actual, ag.estado_aprobacion,
           ag.fecha_modificacion
    FROM asset_grafico ag
    LEFT JOIN miembro_equipo me ON ag.artista_responsable = me.codigo_empleado
    WHERE ag.codigo_videojuego = p_codigo_videojuego
    ORDER BY ag.tipo, ag.nombre;
END//

-- 7. BUSCAR ASSETS POR NOMBRE, TIPO O ESTADO
CREATE PROCEDURE sp_SearchAssetsGraficos(
    IN p_SearchTerm VARCHAR(100)
)
BEGIN
    SELECT ag.codigo, ag.nombre, ag.tipo,
           ag.formato, ag.resolucion,
           ag.version_actual, ag.estado_aprobacion,
           ag.codigo_videojuego,
           vj.titulo AS titulo_videojuego
    FROM asset_grafico ag
    LEFT JOIN videojuego vj ON ag.codigo_videojuego = vj.codigo
    WHERE ag.nombre           LIKE CONCAT('%', p_SearchTerm, '%')
       OR ag.tipo             LIKE CONCAT('%', p_SearchTerm, '%')
       OR ag.estado_aprobacion LIKE CONCAT('%', p_SearchTerm, '%')
    ORDER BY ag.nombre;
END//


-- =====================================================
-- PROCEDIMIENTOS AUXILIARES (para Comboboxes del UI)
-- =====================================================

-- OBTENER VIDEOJUEGOS PARA COMBOBOX
CREATE PROCEDURE sp_GetVideojuegosCombo()
BEGIN
    SELECT codigo, CONCAT(titulo, ' [', estado, ']') AS display_text
    FROM videojuego
    ORDER BY titulo;
END//

-- OBTENER MIEMBROS PARA COMBOBOX
CREATE PROCEDURE sp_GetMiembrosCombo()
BEGIN
    SELECT codigo_empleado,
           CONCAT(nombres, ' ', apellidos, ' - ', especialidad) AS display_text
    FROM miembro_equipo
    ORDER BY apellidos, nombres;
END//

-- OBTENER TAREAS PARA COMBOBOX (dependencias)
CREATE PROCEDURE sp_GetTareasCombo(
    IN p_codigo_videojuego VARCHAR(20)
)
BEGIN
    SELECT codigo,
           CONCAT(codigo, ' | ', descripcion) AS display_text
    FROM tarea
    WHERE codigo_videojuego = p_codigo_videojuego
    ORDER BY codigo;
END//

DELIMITER ;