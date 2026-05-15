import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Persona } from './persona.model';

@Injectable({ providedIn: 'root' })
export class PersonaService {
  private readonly baseUrl = 'http://localhost:3000/middle/personas';

  constructor(private readonly http: HttpClient) {}

  buscarPersona(idTipo: string, idValor: string): Observable<Persona> {
    const params = new HttpParams().set('idTipo', idTipo).set('idValor', idValor);
    return this.http.get<Persona>(this.baseUrl, { params });
  }
}
