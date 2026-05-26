import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { map, Observable } from 'rxjs';
import { Persona } from '../../features/personas/models/persona.model';

interface PersonaApiResponse {
  id: number;
  idType: string;
  idValue: string;
  nombres: string;
  apellidos: string;
  email?: string;
  phone?: string;
  birthDate?: string;
}

@Injectable({ providedIn: 'root' })
export class PersonaService {
  private readonly baseUrl = 'http://localhost:3000/middle/personas';

  constructor(private readonly http: HttpClient) {}

  buscarPersona(idTipo: string, idValor: string): Observable<Persona> {
    const params = new HttpParams()
      .set('idTipo', idTipo)
      .set('idValor', idValor);

    return this.http.get<PersonaApiResponse>(this.baseUrl, { params }).pipe(
      map((response) => ({
        id: response.id,
        fullName: [response.nombres, response.apellidos].filter(Boolean).join(' '),
        idType: response.idType,
        idValue: response.idValue,
        email: response.email,
        phone: response.phone,
        birthDate: response.birthDate
      }))
    );
  }
}
