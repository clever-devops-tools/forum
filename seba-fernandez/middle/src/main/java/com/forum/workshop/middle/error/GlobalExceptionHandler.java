package com.forum.workshop.middle.error;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ApiError> handleBadRequest(BadRequestException ex, HttpServletRequest request) {
        return build(HttpStatus.BAD_REQUEST, ex.getMessage(), request.getRequestURI());
    }

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ApiError> handleNotFound(NotFoundException ex, HttpServletRequest request) {
        return build(HttpStatus.NOT_FOUND, ex.getMessage(), request.getRequestURI());
    }

    @ExceptionHandler(ServiceUnavailableException.class)
    public ResponseEntity<ApiError> handleServiceUnavailable(ServiceUnavailableException ex, HttpServletRequest request) {
        return build(HttpStatus.SERVICE_UNAVAILABLE, ex.getMessage(), request.getRequestURI());
    }

    @ExceptionHandler({MethodArgumentNotValidException.class, ConstraintViolationException.class, MethodArgumentTypeMismatchException.class})
    public ResponseEntity<ApiError> handleValidation(Exception ex, HttpServletRequest request) {
        if (ex instanceof MethodArgumentNotValidException validationEx) {
            FieldError firstError = validationEx.getBindingResult().getFieldErrors().stream().findFirst().orElse(null);
            String message = firstError == null ? "Invalid request" : firstError.getField() + ": " + firstError.getDefaultMessage();
            return build(HttpStatus.BAD_REQUEST, message, request.getRequestURI());
        }
        return build(HttpStatus.BAD_REQUEST, "Invalid request", request.getRequestURI());
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleUnexpected(Exception ex, HttpServletRequest request) {
        return build(HttpStatus.SERVICE_UNAVAILABLE, "Middle service is temporarily unavailable", request.getRequestURI());
    }

    private ResponseEntity<ApiError> build(HttpStatus status, String message, String path) {
        ApiError error = new ApiError(status.value(), status.getReasonPhrase(), message, path);
        return ResponseEntity.status(status).body(error);
    }
}
