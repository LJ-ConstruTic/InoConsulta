-- create database 

DROP DATABASE IF EXISTS hnsp_consuta;
CREATE DATABASE hnsp_consuta;

-- create schema
CREATE SCHEMA app_consuta;

-- create role 
CREATE ROLE hnsp_consuta;
CREATE ROLE hnsp_consuta_cru;
-- grant permison in DB
GRANT CONNECT ON DATABASE hnsp_consuta TO hnsp_consuta;
GRANT CONNECT ON DATABASE hnsp_consuta_cru TO hnsp_consuta;

-- alter schemas public 
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT INSERT ON TABLES TO hnsp_consuta;

ALTER DEFAULT PRIVILEGES IN SCHEMA app_consuta GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO hnsp_consuta;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO hnsp_consuta_cru;

-- permiission to schemas 
GRANT USAGE ON SCHEMA app_consuta TO hnsp_consuta;
GRANT USAGE ON SCHEMA public TO hnsp_consuta;

-- grant shema previleges usage on sequences
GRANT USAGE ON ALL SEQUENCES IN SCHEMA app_consuta TO hnsp_consuta;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO hnsp_consuta_cru;


-- Crear as tablas 

CREATE TABLE "app_consuta".Person(
  id UUID  NOT NULL DEFAULT gen_random_uuid(),
  doc_id CHAR(14) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  name TEXT NOT NULL,
  surname TEXT NOT NULL,
  birthplace TEXT NOT NULL,
  gender TEXT NOT NULL,
  job TEXT NOT NULL,
  PRIMARY KEY (id,  doc_id)
);


CREATE TABLE "app_consuta".person_doc(
    id UUID NOT NULL  DEFAULT gen_random_uuid(),
    id_person UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    type VARCHAR(10) NOT NULL CHECK (type IN('BI', 'PASSAPORT', 'RES_CARD'))
    number TEXT NOT NULL,
    dt_start DATE NOT NULL,
    dt_end DATE NOT NULL,
    place_emision TEXT NOT NULL,
    nationality TEXT NOT NULL,

    PRIMARY KEY (id, id_person),
    FOREIGN KEY (id_person) REFERENCES "app_consuta".person(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "app_consuta".person_addres(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    id_person UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    country TEXT NOT NULL,
    province TEXT NOT NULL,
    municipal TEXT NOT NULL,
    zip_code CHAR(5),
    street TEXT,
    flat TEXT, 
    number_house CHAR (5),
    door CHAR(2),

    PRIMARY KEY ( id,id_person),
    FOREIGN KEY (id_person) REFERENCES "app_consuta".person(id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE "app_consuta".person_contact( /* 1:N*/
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    id_person CHAR(36) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    phone CHAR(9) UNIQUE NOT NULL,
    email TEXT UNIQUE,

    PRIMARY KEY (id, id_person),
    FOREIGN KEY (id_person) REFERENCES "app_consuta".person(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "app_consuta".user(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    id_person CHAR(36) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    PRIMARY KEY ( id,id_person),
    FOREIGN KEY (id_person) REFERENCES "app_consuta".person(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "app_consuta".user_data_login(
    id UUID  NOT NULL DEFAULT gen_random_uuid(),
    id_user UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    user TEXT NOT NULL,
    password TEXT NOT NULL,

    last_seen SMALLDATETIME DEFAULT NULL,

    PRIMARY KEY ( id,id_user),
    FOREIGN KEY (id_user) REFERENCES "app_consuta".user(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "app_consuta".session_up(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    id_user CHAR(36) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    token TEXT NOT NULL,

    PRIMARY KEY ( id,id_user),
    FOREIGN KEY (id_user) REFERENCES "app_consuta".user(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "app_consuta".admin(
    id UUID  NOT NULL DEFAULT gen_random_uuid(),
    id_user UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    last_seen SMALLDATETIME DEFAULT NULL,

    PRIMARY KEY ( id,id_user),
    FOREIGN KEY (id_user) REFERENCES "app_consuta".user(id) ON DELETE CASCADE ON UPDATE CASCADE

);

-- roles and permission

CREATE TABLE "app_consuta".role(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    name TEXT  UNIQUE NOT NULL
);

CREATE TABLE "app_consuta".permission(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    name TEXT  UNIQUE NOT NULL
);

CREATE TABLE "app_consuta".permission_role(  -- Relacion N a N / muchos a muchos
    -- se ve los permisos que tiene un role y un role puede terner 
    -- mas a de un permiso. Y un permiso solo puede estar una vez 
    -- en cada role.
    id UUID NOT NULL DEFAULT gen_random_uuid(), -- el id aasignado al usisario para controlar los persmisos de aceso.
    id_role UUID NOT NULL,  -- admin
    id_permission UUID NOT NULL, -- create, read, update, delete, 
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
 
    FOREIGN KEY (id_role) REFERENCES "app_consuta".role (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_permission) REFERENCES "app_consuta".permission (id) ON DELETE CASCADE ON UPDATE CASCADE

);

CREATE TABLE "app_consuta".user_permission(
    id_user UUID NOT NULL,
    id_permision_role UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    FOREIGN KEY (id_user) REFERENCES "app_consuta".user (id) ON DELETE CASCADE ON UPDATE CASCADE

);



-- tablas CONSULTAS

--- LOGICA FARMACIA (pacientes, medicina, medico)

CREATE TABLE "app_consuta".patients(
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    id_person UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    medical_record_number VARCHAR(50) UNIQUE,
    PRIMARY KEY ( id, id_person);
    FOREIGN KEY (id_person) REFERENCES "app_consuta".person (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "app_consuta".doctors (
    id UUID  NOT NULL DEFAULT gen_random_uuid(),
    id_person UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    license_number TEXT UNIQUE,

    PRIMARY KEY ( id, id_person);
    FOREIGN KEY (id_person) REFERENCES "app_consuta".person (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE "app_consuta".suppliers ( -- Provedores
    id UUID NOT NULL DEFAULT gen_random_uuid(), 
    id_person UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY ( id, id_person),
    FOREIGN KEY (id_person) REFERENCES "app_consuta".person (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE "app_consuta".medications (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    supplier_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    name TEXT NOT NULL,
    description TEXT,
    dosage TEXT,
    unit_price DECIMAL(10, 2),
    stock_quantity INT,
    PRIMARY KEY ( id, supplier_id),

    FOREIGN KEY (supplier_id) REFERENCES "app_consuta".suppliers (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_person) REFERENCES "app_consuta".person (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE "app_consuta".prescriptions (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL,  
    doctor_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    prescription_date DATE NOT NULL,
    notes TEXT,
    PRIMARY KEY ( id),
    FOREIGN KEY (patient_id) REFERENCES "app_consuta".patients (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES "app_consuta".doctors (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE "app_consuta".prescription_details (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    prescription_id UUID NOT NULL,
    medication_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    quantity INT NOT NULL,
    dosage_instructions TEXT

    PRIMARY KEY ( id),
    FOREIGN KEY (prescription_id) REFERENCES "app_consuta".prescriptions (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (medication_id) REFERENCES "app_consuta".medications (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "app_consuta".purchase_orders ( -- odenesde compra de medicamentos
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    supplier_id INT REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2)
    PRIMARY KEY ( id),
    FOREIGN KEY (supplier_id) REFERENCES "app_consuta".suppliers (id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE purchase_order_details ( -- Detalles de la Orden de Compra (purchase_order_details)
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    order_id INT REFERENCES purchase_orders(order_id) ON DELETE CASCADE,
    medication_id INT REFERENCES medications(medication_id) ON DELETE SET NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2)

    PRIMARY KEY ( id),
    FOREIGN KEY (order_id) REFERENCES "app_consuta".purchase_orders (id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (medication_id) REFERENCES "app_consuta".medications (id) ON DELETE SET NULL ON UPDATE CASCADE
);


CREATE TABLE "app_consuta".inventory (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    medication_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    stock_in INT,
    stock_out INT,
    balance INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ( id),
    FOREIGN KEY (medication_id) REFERENCES "app_consuta".medications (id) ON DELETE CASCADE
);

CREATE TABLE "app_consuta".consultas (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    id_patient UUID NOT NULL,
    id_doctor UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    date_consulta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT NOT NULL,
    diagnostico TEXT,
    tratamiento TEXT,

    PRIMARY KEY ( id),
    FOREIGN KEY (id_patient) REFERENCES "app_consuta".patients (id) ON DELETE CASCADE,
    FOREIGN KEY (id_doctor) REFERENCES "app_consuta".doctors (id) ON DELETE CASCADE
);
CREATE TABLE visita ( -- cita
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    id_patient UUID NOT NULL,
    id_doctor UUID NOT NULL,
    fecha_cita TIMESTAMP NOT NULL,
    motivo TEXT,

    PRIMARY KEY ( id),
    FOREIGN KEY (id_patient) REFERENCES "app_consuta".patients (id) ON DELETE CASCADE,
    FOREIGN KEY (id_doctor) REFERENCES "app_consuta".doctors (id) ON DELETE CASCADE
);


/*
CREATE TABLE "app_consuta".pharmacy(
    id UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    name TEXT NOT NULL,
    description TEXT,
    provider TEXT NOT NULL,
    record_date DATE DEFAULT CURRENT_DATE, -- fecha de registro
    price DECIMAL(10, 2) NOT NULL,
    dose TEXT NOT NULL,
    contraindications TEXT, 
    PRIMARY KEY ( id)
);

*/


