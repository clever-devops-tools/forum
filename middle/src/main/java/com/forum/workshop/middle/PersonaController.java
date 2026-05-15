package com.forum.workshop.middle;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;

@RestController
@RequestMapping("/middle/personas")
@CrossOrigin(origins = "*")
public class PersonaController {

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP");
    }

    @GetMapping
    public ResponseEntity<PersonaResponse> search(
            @RequestParam(required = false) String idTipo,
            @RequestParam(required = false) String idValor) {
        if ("DNI".equalsIgnoreCase(idTipo) && "12345678".equals(idValor)) {
            return ResponseEntity.ok(samplePersona());
        }

        if (idTipo == null && idValor == null) {
            return ResponseEntity.ok(samplePersona());
        }

        return ResponseEntity.notFound().build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<PersonaResponse> byId(@PathVariable String id) {
        if ("1".equals(id)) {
            return ResponseEntity.ok(samplePersona());
        }

        return ResponseEntity.notFound().build();
    }

    private PersonaResponse samplePersona() {
        return new PersonaResponse(
                "1",
                "Juan Perez",
                "DNI",
                "12345678",
                "juan.perez@forum.local",
                "+51 999 888 777",
                "1990-04-18");
    }
}
