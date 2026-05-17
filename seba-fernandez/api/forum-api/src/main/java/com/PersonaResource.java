package com;

import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.net.URI;
import java.util.List;
import java.util.Map;

@Path("/api/personas")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PersonaResource {

    @GET
    @Path("/search")
    public Response searchByIdentity(@QueryParam("idTipo") String idTipo, @QueryParam("idValor") String idValor) {
        if (idTipo == null || idTipo.isBlank() || idValor == null || idValor.isBlank()) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity(Map.of("error", "idTipo and idValor are required"))
                .build();
        }

        Persona persona = Persona.find("idTipo = ?1 and idValor = ?2", idTipo, idValor).firstResult();
        if (persona == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.ok(persona).build();
    }

    @GET
    public List<Persona> listAll() {
        return Persona.listAll();
    }

    @GET
    @Path("/{id:\\d+}")
    public Persona getById(@PathParam("id") Long id) {
        Persona persona = Persona.findById(id);
        if (persona == null) {
            throw new NotFoundException("Persona not found");
        }
        return persona;
    }

    @POST
    @Transactional
    public Response create(Persona payload) {
        if (payload == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity(Map.of("error", "Request body is required"))
                .build();
        }

        payload.id = null;
        payload.persist();
        return Response.created(URI.create("/api/personas/" + payload.id)).entity(payload).build();
    }

    @PUT
    @Path("/{id:\\d+}")
    @Transactional
    public Persona update(@PathParam("id") Long id, Persona payload) {
        Persona existing = Persona.findById(id);
        if (existing == null) {
            throw new NotFoundException("Persona not found");
        }
        if (payload == null) {
            throw new jakarta.ws.rs.BadRequestException("Request body is required");
        }

        existing.idTipo = payload.idTipo;
        existing.idValor = payload.idValor;
        existing.nombres = payload.nombres;
        existing.apellidos = payload.apellidos;
        existing.fechaNacimiento = payload.fechaNacimiento;
        existing.email = payload.email;
        existing.telefono = payload.telefono;
        return existing;
    }

    @DELETE
    @Path("/{id:\\d+}")
    @Transactional
    public Response delete(@PathParam("id") Long id) {
        boolean deleted = Persona.deleteById(id);
        if (!deleted) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.noContent().build();
    }

    @GET
    @Path("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP", "service", "personas-api");
    }
}