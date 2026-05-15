import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { finalize } from 'rxjs';
import { Persona } from './persona.model';
import { PersonaService } from './persona.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <main class="shell">
      <section class="hero">
        <p class="eyebrow">Forum Workshop</p>
        <h1>Búsqueda de personas</h1>
        <p class="subtitle">
          Frontend Angular mínimo para probar el flujo con el BFF local.
        </p>
      </section>

      <section class="card form-card">
        <div class="grid">
          <label>
            Tipo de identificación
            <select [(ngModel)]="idTipo">
              <option value="DNI">DNI</option>
              <option value="RUT">RUT</option>
              <option value="Pasaporte">Pasaporte</option>
            </select>
          </label>

          <label>
            Número de identificación
            <input [(ngModel)]="idValor" type="text" placeholder="12345678" />
          </label>
        </div>

        <div class="actions">
          <button type="button" class="primary" (click)="buscar()" [disabled]="loading">Buscar</button>
          <button type="button" class="secondary" (click)="limpiar()" [disabled]="loading">Limpiar</button>
        </div>
      </section>

      <section class="card result-card">
        <div *ngIf="loading" class="state">Consultando middle...</div>
        <div *ngIf="!loading && error" class="state error">{{ error }}</div>

        <article *ngIf="!loading && persona" class="persona">
          <h2>{{ persona.fullName }}</h2>
          <dl>
            <div><dt>Tipo</dt><dd>{{ persona.idType }}</dd></div>
            <div><dt>Número</dt><dd>{{ persona.idValue }}</dd></div>
            <div><dt>Email</dt><dd>{{ persona.email }}</dd></div>
            <div><dt>Teléfono</dt><dd>{{ persona.phone }}</dd></div>
            <div><dt>Fecha de nacimiento</dt><dd>{{ persona.birthDate }}</dd></div>
          </dl>
        </article>

        <div *ngIf="!loading && !error && !persona" class="state muted">
          Ejecuta una búsqueda para ver el resultado.
        </div>
      </section>
    </main>
  `,
  styles: [`
    :host {
      display: block;
      min-height: 100vh;
      padding: 32px;
    }

    .shell {
      max-width: 920px;
      margin: 0 auto;
      display: grid;
      gap: 20px;
    }

    .hero {
      padding: 16px 4px 6px;
    }

    .eyebrow {
      margin: 0 0 8px;
      text-transform: uppercase;
      letter-spacing: 0.16em;
      font-size: 0.72rem;
      font-weight: 700;
      color: #2f5bd1;
    }

    h1 {
      margin: 0;
      font-size: clamp(2rem, 4vw, 3.4rem);
      line-height: 1.04;
    }

    .subtitle {
      margin: 10px 0 0;
      max-width: 60ch;
      color: #4b5c72;
      font-size: 1.02rem;
    }

    .card {
      background: rgba(255, 255, 255, 0.88);
      border: 1px solid rgba(16, 32, 51, 0.08);
      border-radius: 24px;
      box-shadow: 0 18px 50px rgba(16, 32, 51, 0.08);
      backdrop-filter: blur(14px);
      padding: 24px;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 16px;
    }

    label {
      display: grid;
      gap: 8px;
      color: #213246;
      font-weight: 600;
    }

    input,
    select {
      width: 100%;
      border: 1px solid rgba(16, 32, 51, 0.14);
      border-radius: 14px;
      padding: 14px 16px;
      font: inherit;
      background: #fff;
      color: #102033;
    }

    .actions {
      display: flex;
      gap: 12px;
      margin-top: 18px;
    }

    button {
      border: 0;
      border-radius: 999px;
      padding: 12px 20px;
      font: inherit;
      font-weight: 700;
      cursor: pointer;
    }

    .primary {
      background: #123c8c;
      color: #fff;
    }

    .secondary {
      background: #dfe8f7;
      color: #102033;
    }

    .result-card {
      min-height: 170px;
    }

    .state {
      padding: 12px 4px;
      font-weight: 600;
    }

    .state.error {
      color: #b42318;
    }

    .state.muted {
      color: #5d6f86;
    }

    .persona h2 {
      margin: 0 0 14px;
      font-size: 1.4rem;
    }

    dl {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 14px 24px;
      margin: 0;
    }

    dl div {
      padding: 14px 16px;
      border-radius: 16px;
      background: #f5f8fd;
    }

    dt {
      color: #5d6f86;
      font-size: 0.78rem;
      text-transform: uppercase;
      letter-spacing: 0.08em;
    }

    dd {
      margin: 6px 0 0;
      font-weight: 700;
      color: #102033;
      word-break: break-word;
    }

    @media (max-width: 720px) {
      :host {
        padding: 18px;
      }

      .grid,
      dl {
        grid-template-columns: 1fr;
      }

      .actions {
        flex-direction: column;
      }
    }
  `]
})
export class AppComponent {
  idTipo = 'DNI';
  idValor = '12345678';
  loading = false;
  error = '';
  persona: Persona | null = null;

  constructor(private readonly personaService: PersonaService) {}

  buscar(): void {
    this.loading = true;
    this.error = '';
    this.persona = null;

    this.personaService
      .buscarPersona(this.idTipo, this.idValor)
      .pipe(finalize(() => (this.loading = false)))
      .subscribe({
        next: (persona) => {
          this.persona = persona;
        },
        error: () => {
          this.error = 'No se encontró la persona en el BFF local.';
        }
      });
  }

  limpiar(): void {
    this.idTipo = 'DNI';
    this.idValor = '';
    this.loading = false;
    this.error = '';
    this.persona = null;
  }
}
