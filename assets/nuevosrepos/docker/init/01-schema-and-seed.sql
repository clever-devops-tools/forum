-- =============================================================
-- Forum Workshop - Base de Datos de Personas
-- Script de inicialización: esquema + datos de prueba
-- =============================================================

CREATE TABLE IF NOT EXISTS personas (
  id_tipo          VARCHAR(10)  NOT NULL,
  id_valor         VARCHAR(20)  NOT NULL,
  nombres          VARCHAR(100) NOT NULL,
  apellidos        VARCHAR(100) NOT NULL,
  fecha_nacimiento DATE,
  email            VARCHAR(120),
  telefono         VARCHAR(30),
  PRIMARY KEY (id_tipo, id_valor)
);

-- Datos de prueba para el workshop
INSERT INTO personas (id_tipo, id_valor, nombres, apellidos, fecha_nacimiento, email, telefono) VALUES
  ('DNI', '12345678',      'Juan',   'Perez',    '1990-05-10', 'juan.perez@mail.com',    '+56 9 1111 1111'),
  ('RUT', '12.345.678-5',  'Maria',  'Gonzalez', '1988-11-23', 'maria.gonzalez@mail.com','+56 9 2222 2222'),
  ('DNI', '87654321',      'Carlos', 'Lopez',    '1995-01-15', 'carlos.lopez@mail.com',  '+56 9 3333 3333')
ON CONFLICT DO NOTHING;
