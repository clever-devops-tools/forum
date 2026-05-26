-- =============================================================
-- Forum Workshop - Base de Datos de Personas
-- Script de inicialización: esquema + datos de prueba
-- =============================================================

CREATE TABLE IF NOT EXISTS personas (
  id               BIGSERIAL PRIMARY KEY,
  id_tipo          VARCHAR(10)  NOT NULL,
  id_valor         VARCHAR(20)  NOT NULL,
  nombres          VARCHAR(100) NOT NULL,
  apellidos        VARCHAR(100) NOT NULL,
  fecha_nacimiento DATE,
  email            VARCHAR(120),
  telefono         VARCHAR(30),
  CONSTRAINT uk_personas_id_tipo_id_valor UNIQUE (id_tipo, id_valor)
);

-- Migracion idempotente para entornos donde la tabla ya existe con PK compuesta
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'personas'
  ) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = 'personas' AND column_name = 'id'
    ) THEN
      ALTER TABLE personas ADD COLUMN id BIGINT;
      CREATE SEQUENCE IF NOT EXISTS personas_id_seq;
      ALTER TABLE personas ALTER COLUMN id SET DEFAULT nextval('personas_id_seq');
      UPDATE personas SET id = nextval('personas_id_seq') WHERE id IS NULL;
      ALTER TABLE personas ALTER COLUMN id SET NOT NULL;
      ALTER SEQUENCE personas_id_seq OWNED BY personas.id;
    END IF;

    IF EXISTS (
      SELECT 1
      FROM information_schema.table_constraints
      WHERE table_schema = 'public'
        AND table_name = 'personas'
        AND constraint_name = 'personas_pkey'
        AND constraint_type = 'PRIMARY KEY'
    ) THEN
      ALTER TABLE personas DROP CONSTRAINT personas_pkey;
    END IF;

    IF NOT EXISTS (
      SELECT 1
      FROM information_schema.table_constraints
      WHERE table_schema = 'public'
        AND table_name = 'personas'
        AND constraint_name = 'personas_pkey'
        AND constraint_type = 'PRIMARY KEY'
    ) THEN
      ALTER TABLE personas ADD CONSTRAINT personas_pkey PRIMARY KEY (id);
    END IF;

    IF NOT EXISTS (
      SELECT 1
      FROM information_schema.table_constraints
      WHERE table_schema = 'public'
        AND table_name = 'personas'
        AND constraint_name = 'uk_personas_id_tipo_id_valor'
        AND constraint_type = 'UNIQUE'
    ) THEN
      ALTER TABLE personas ADD CONSTRAINT uk_personas_id_tipo_id_valor UNIQUE (id_tipo, id_valor);
    END IF;
  END IF;
END
$$;

-- Datos de prueba para el workshop
INSERT INTO personas (id_tipo, id_valor, nombres, apellidos, fecha_nacimiento, email, telefono) VALUES
  ('DNI', '12345678',      'Juan',   'Perez',    '1990-05-10', 'juan.perez@mail.com',    '+56 9 1111 1111'),
  ('RUT', '12.345.678-5',  'Maria',  'Gonzalez', '1988-11-23', 'maria.gonzalez@mail.com','+56 9 2222 2222'),
  ('DNI', '87654321',      'Carlos', 'Lopez',    '1995-01-15', 'carlos.lopez@mail.com',  '+56 9 3333 3333')
ON CONFLICT DO NOTHING;
