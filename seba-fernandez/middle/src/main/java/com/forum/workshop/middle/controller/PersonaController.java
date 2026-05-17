package com.forum.workshop.middle.controller;

import com.forum.workshop.middle.dto.PersonaRequest;
import com.forum.workshop.middle.dto.PersonaResponse;
import com.forum.workshop.middle.service.PersonaService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/middle/personas")
public class PersonaController {

    private final PersonaService personaService;

    public PersonaController(PersonaService personaService) {
        this.personaService = personaService;
    }

    @GetMapping
    public Object listOrSearch(
        @RequestParam(name = "idTipo", required = false) String idTipo,
        @RequestParam(name = "idValor", required = false) String idValor
    ) {
        if (idTipo != null || idValor != null) {
            return personaService.search(idTipo, idValor);
        }
        List<PersonaResponse> personas = personaService.listAll();
        return personas;
    }

    @GetMapping("/{id}")
    public PersonaResponse getById(@PathVariable Long id) {
        return personaService.getById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public PersonaResponse create(@Valid @RequestBody PersonaRequest request) {
        return personaService.create(request);
    }

    @PutMapping("/{id}")
    public PersonaResponse update(@PathVariable Long id, @Valid @RequestBody PersonaRequest request) {
        return personaService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        personaService.delete(id);
    }
}
