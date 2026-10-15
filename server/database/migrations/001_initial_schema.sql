BEGIN;

CREATE TABLE specialties (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

    CONSTRAINT uq_specialties_name
        UNIQUE (name),

    CONSTRAINT chk_specialties_name_not_blank
        CHECK (btrim(name) <> '')
);

CREATE TABLE areas (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,

    CONSTRAINT uq_areas_name
        UNIQUE (name),

    CONSTRAINT chk_areas_name_not_blank
        CHECK (btrim(name) <> '')
);

CREATE TABLE patients (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    amka VARCHAR(11) NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_patients_amka
        UNIQUE (amka),

    CONSTRAINT chk_patients_amka_format
        CHECK (amka ~ '^[0-9]{11}$'),

    CONSTRAINT chk_patients_password_hash_not_blank
        CHECK (btrim(password_hash) <> '')
);

CREATE TABLE doctors (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    amka VARCHAR(11) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    specialty_id BIGINT NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(254),
    area_id BIGINT NOT NULL,
    practice_address VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_doctors_amka
        UNIQUE (amka),

    CONSTRAINT chk_doctors_amka_format
        CHECK (amka ~ '^[0-9]{11}$'),

    CONSTRAINT chk_doctors_full_name_not_blank
        CHECK (btrim(full_name) <> ''),

    CONSTRAINT chk_doctors_phone_not_blank
        CHECK (btrim(phone) <> ''),

    CONSTRAINT chk_doctors_email_not_blank
        CHECK (email IS NULL OR btrim(email) <> ''),

    CONSTRAINT chk_doctors_practice_address_not_blank
        CHECK (
            practice_address IS NULL
            OR btrim(practice_address) <> ''
        ),

    CONSTRAINT fk_doctors_specialty
        FOREIGN KEY (specialty_id)
        REFERENCES specialties (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_doctors_area
        FOREIGN KEY (area_id)
        REFERENCES areas (id)
        ON DELETE RESTRICT
);

CREATE TABLE availability_slots (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    doctor_id BIGINT NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,

    CONSTRAINT uq_availability_slots_doctor_start
        UNIQUE (doctor_id, starts_at),

    CONSTRAINT chk_availability_slots_time_order
        CHECK (ends_at > starts_at),

    CONSTRAINT fk_availability_slots_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors (id)
        ON DELETE RESTRICT
);

CREATE TABLE appointments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    slot_id BIGINT NOT NULL,
    reason VARCHAR(500) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMPTZ,

    CONSTRAINT chk_appointments_reason_not_blank
        CHECK (btrim(reason) <> ''),

    CONSTRAINT chk_appointments_status
        CHECK (status IN ('scheduled', 'cancelled')),

    CONSTRAINT chk_appointments_cancellation
        CHECK (
            (
                status = 'scheduled'
                AND cancelled_at IS NULL
            )
            OR
            (
                status = 'cancelled'
                AND cancelled_at IS NOT NULL
                AND cancelled_at >= created_at
            )
        ),

    CONSTRAINT fk_appointments_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_appointments_slot
        FOREIGN KEY (slot_id)
        REFERENCES availability_slots (id)
        ON DELETE RESTRICT
);

CREATE INDEX idx_doctors_specialty_area
    ON doctors (specialty_id, area_id);

CREATE INDEX idx_appointments_patient
    ON appointments (patient_id);

CREATE UNIQUE INDEX uq_appointments_active_slot
    ON appointments (slot_id)
    WHERE status = 'scheduled';

COMMIT;