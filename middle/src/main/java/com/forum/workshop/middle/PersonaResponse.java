package com.forum.workshop.middle;

public record PersonaResponse(
        String id,
        String fullName,
        String idType,
        String idValue,
        String email,
        String phone,
        String birthDate) {
}
