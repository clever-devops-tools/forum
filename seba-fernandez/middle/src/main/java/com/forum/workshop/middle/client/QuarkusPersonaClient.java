package com.forum.workshop.middle.client;

import com.forum.workshop.middle.dto.QuarkusPersonaDto;
import com.forum.workshop.middle.error.BadRequestException;
import com.forum.workshop.middle.error.NotFoundException;
import com.forum.workshop.middle.error.ServiceUnavailableException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

import java.util.Arrays;
import java.util.List;

@Component
public class QuarkusPersonaClient {

    private final RestClient restClient;

    public QuarkusPersonaClient(RestClient quarkusRestClient) {
        this.restClient = quarkusRestClient;
    }

    public List<QuarkusPersonaDto> listAll() {
        try {
            QuarkusPersonaDto[] result = restClient.get()
                .uri("/api/personas")
                .retrieve()
                .body(QuarkusPersonaDto[].class);
            if (result == null) {
                return List.of();
            }
            return Arrays.asList(result);
        } catch (RestClientException ex) {
            throw translate(ex);
        }
    }

    public QuarkusPersonaDto search(String idTipo, String idValor) {
        try {
            return restClient.get()
                .uri(uriBuilder -> uriBuilder.path("/api/personas/search")
                    .queryParam("idTipo", idTipo)
                    .queryParam("idValor", idValor)
                    .build())
                .retrieve()
                .body(QuarkusPersonaDto.class);
        } catch (RestClientException ex) {
            throw translate(ex);
        }
    }

    public QuarkusPersonaDto getById(Long id) {
        try {
            return restClient.get()
                .uri("/api/personas/{id}", id)
                .retrieve()
                .body(QuarkusPersonaDto.class);
        } catch (RestClientException ex) {
            throw translate(ex);
        }
    }

    public QuarkusPersonaDto create(QuarkusPersonaDto payload) {
        try {
            return restClient.post()
                .uri("/api/personas")
                .body(payload)
                .retrieve()
                .body(QuarkusPersonaDto.class);
        } catch (RestClientException ex) {
            throw translate(ex);
        }
    }

    public QuarkusPersonaDto update(Long id, QuarkusPersonaDto payload) {
        try {
            return restClient.put()
                .uri("/api/personas/{id}", id)
                .body(payload)
                .retrieve()
                .body(QuarkusPersonaDto.class);
        } catch (RestClientException ex) {
            throw translate(ex);
        }
    }

    public void delete(Long id) {
        try {
            restClient.delete()
                .uri("/api/personas/{id}", id)
                .retrieve()
                .onStatus(code -> code.value() == 404, (request, response) -> {
                    throw new NotFoundException("Persona not found");
                })
                .onStatus(HttpStatusCode -> HttpStatusCode.is4xxClientError(), (request, response) -> {
                    throw new BadRequestException("Invalid request to upstream Quarkus API");
                })
                .onStatus(HttpStatusCode -> HttpStatusCode.is5xxServerError(), (request, response) -> {
                    throw new ServiceUnavailableException("Quarkus service unavailable");
                })
                .toBodilessEntity();
        } catch (RestClientException ex) {
            throw translate(ex);
        }
    }

    private RuntimeException translate(RestClientException ex) {
        if (ex instanceof ResourceAccessException) {
            return new ServiceUnavailableException("Quarkus service timeout or unreachable");
        }

        if (ex instanceof RestClientResponseException responseException) {
            HttpStatus status = HttpStatus.resolve(responseException.getStatusCode().value());
            if (status == HttpStatus.BAD_REQUEST) {
                return new BadRequestException("Invalid request to upstream Quarkus API");
            }
            if (status == HttpStatus.NOT_FOUND) {
                return new NotFoundException("Persona not found");
            }
            return new ServiceUnavailableException("Quarkus service unavailable");
        }

        return new ServiceUnavailableException("Unexpected error calling Quarkus API");
    }
}
