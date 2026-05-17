package com;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

import java.time.LocalDate;

@Entity
@Table(
    name = "personas",
    uniqueConstraints = @UniqueConstraint(name = "uk_personas_id_tipo_id_valor", columnNames = {"id_tipo", "id_valor"})
)
public class Persona extends PanacheEntity {

    @Column(name = "id_tipo", nullable = false, length = 10)
    public String idTipo;

    @Column(name = "id_valor", nullable = false, length = 20)
    public String idValor;

    @Column(name = "nombres", nullable = false, length = 100)
    public String nombres;

    @Column(name = "apellidos", nullable = false, length = 100)
    public String apellidos;

    @Column(name = "fecha_nacimiento")
    public LocalDate fechaNacimiento;

    @Column(name = "email", length = 120)
    public String email;

    @Column(name = "telefono", length = 30)
    public String telefono;

    public String getFullName() {
        String firstName = nombres == null ? "" : nombres.trim();
        String lastName = apellidos == null ? "" : apellidos.trim();
        return (firstName + " " + lastName).trim();
    }
}