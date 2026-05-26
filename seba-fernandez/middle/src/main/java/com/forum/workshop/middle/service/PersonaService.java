package com.forum.workshop.middle.service;

import com.forum.workshop.middle.client.QuarkusPersonaClient;
import com.forum.workshop.middle.dto.PersonaRequest;
import com.forum.workshop.middle.dto.PersonaResponse;
import com.forum.workshop.middle.dto.QuarkusPersonaDto;
import com.forum.workshop.middle.error.BadRequestException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PersonaService {

    private final QuarkusPersonaClient quarkusClient;

    public PersonaService(QuarkusPersonaClient quarkusClient) {
        this.quarkusClient = quarkusClient;
    }

    public List<PersonaResponse> listAll() {
        return quarkusClient.listAll().stream().map(this::toResponse).toList();
    }

    public PersonaResponse search(String idTipo, String idValor) {
        if (idTipo == null || idTipo.isBlank() || idValor == null || idValor.isBlank()) {
            throw new BadRequestException("idTipo and idValor are required");
        }
        return toResponse(quarkusClient.search(idTipo, idValor));
    }

    public PersonaResponse getById(Long id) {
        return toResponse(quarkusClient.getById(id));
    }

    public PersonaResponse create(PersonaRequest request) {
        return toResponse(quarkusClient.create(toQuarkusDto(request)));
    }

    public PersonaResponse update(Long id, PersonaRequest request) {
        return toResponse(quarkusClient.update(id, toQuarkusDto(request)));
    }

    public void delete(Long id) {
        quarkusClient.delete(id);
    }

    private PersonaResponse toResponse(QuarkusPersonaDto source) {
        PersonaResponse target = new PersonaResponse();
        target.setId(source.getId());
        target.setIdType(source.getIdTipo());
        target.setIdValue(source.getIdValor());
        target.setNombres(source.getNombres());
        target.setApellidos(source.getApellidos());
        target.setBirthDate(source.getFechaNacimiento());
        target.setEmail(source.getEmail());
        target.setPhone(source.getTelefono());
        return target;
    }

    private QuarkusPersonaDto toQuarkusDto(PersonaRequest source) {
        QuarkusPersonaDto target = new QuarkusPersonaDto();
        target.setIdTipo(source.getIdType());
        target.setIdValor(source.getIdValue());
        target.setNombres(source.getNombres());
        target.setApellidos(source.getApellidos());
        target.setFechaNacimiento(source.getBirthDate());
        target.setEmail(source.getEmail());
        target.setTelefono(source.getPhone());
        return target;
    }
}
