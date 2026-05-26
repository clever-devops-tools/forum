import { CommonModule } from '@angular/common';
import { Component, inject } from '@angular/core';
import { finalize } from 'rxjs';

import { PersonaService } from './core/services/persona.service';
import { SearchFormComponent } from './features/personas/components/search-form.component';
import { PersonaDetailComponent } from './features/personas/components/persona-detail.component';
import { Persona } from './features/personas/models/persona.model';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, SearchFormComponent, PersonaDetailComponent],
  template: `
    <main class="shell">
      <section class="hero">
        <div class="hero__copy">
          <p class="eyebrow">Forum Workshop</p>
          <h1>Busqueda de personas conectada al middle</h1>
          <p class="hero__text">
            Busca por tipo y numero de documento usando la API intermedia que ya expone el backend.
          </p>
        </div>
        <div class="hero__panel">
          <p class="hero__kicker">Servicios esperados</p>
          <ul>
            <li>Middle: http://localhost:3000</li>
            <li>Busqueda: /middle/personas?idTipo=&idValor=</li>
          </ul>
        </div>
      </section>

      <section class="workspace">
        <app-search-form
          (search)="onSearch($event)"
          (clear)="onClear()"
        />

        <div class="feedback feedback--loading" *ngIf="loading">
          <span class="spinner" aria-hidden="true"></span>
          <span>Buscando persona...</span>
        </div>
        <div class="feedback feedback--error" *ngIf="error">{{ error }}</div>

        <app-persona-detail
          *ngIf="searched && !loading && !error"
          [persona]="persona"
        />

        <section class="empty" *ngIf="!searched && !loading && !error">
          <h2>Listo para consultar</h2>
          <p>Ingresa un tipo de identificacion y su valor para ver la ficha completa de la persona.</p>
        </section>
      </section>
    </main>
  `,
  styles: [`
    :host {
      display: block;
      min-height: 100vh;
    }

    .shell {
      width: min(1120px, calc(100% - 32px));
      margin: 0 auto;
      padding: 48px 0 72px;
    }

    .hero {
      display: grid;
      grid-template-columns: minmax(0, 2fr) minmax(280px, 1fr);
      gap: 24px;
      align-items: stretch;
      margin-bottom: 28px;
    }

    .hero__copy,
    .hero__panel,
    .workspace,
    .empty,
    .feedback {
      border: 1px solid var(--line);
      border-radius: 28px;
      background: var(--surface);
      backdrop-filter: blur(18px);
      box-shadow: var(--shadow);
    }

    .hero__copy {
      padding: 32px;
    }

    .hero__panel {
      padding: 28px;
      background: linear-gradient(180deg, rgba(15, 118, 110, 0.12), rgba(255, 250, 242, 0.9));
    }

    .eyebrow,
    .hero__kicker {
      margin: 0 0 12px;
      font-family: 'Space Grotesk', sans-serif;
      font-size: 0.82rem;
      text-transform: uppercase;
      letter-spacing: 0.14em;
      color: var(--brand);
    }

    h1,
    h2 {
      margin: 0;
      font-family: 'Space Grotesk', sans-serif;
      line-height: 0.95;
    }

    h1 {
      max-width: 12ch;
      font-size: clamp(2.8rem, 6vw, 5rem);
    }

    h2 {
      font-size: 1.8rem;
      margin-bottom: 10px;
    }

    .hero__text,
    .empty p,
    .hero__panel li,
    .feedback {
      font-size: 1.05rem;
      color: var(--muted);
    }

    .hero__panel ul {
      margin: 0;
      padding-left: 18px;
    }

    .workspace {
      padding: 24px;
      display: grid;
      gap: 18px;
    }

    .empty {
      padding: 28px;
    }

    .feedback {
      padding: 16px 18px;
    }

    .feedback--loading {
      display: inline-flex;
      align-items: center;
      gap: 10px;
      width: fit-content;
    }

    .spinner {
      width: 18px;
      height: 18px;
      border-radius: 999px;
      border: 2px solid rgba(15, 118, 110, 0.2);
      border-top-color: var(--brand);
      animation: spin 750ms linear infinite;
    }

    .feedback--error {
      color: var(--danger);
      border-color: rgba(180, 35, 24, 0.18);
      background: rgba(255, 241, 238, 0.85);
    }

    @keyframes spin {
      to {
        transform: rotate(360deg);
      }
    }

    @media (max-width: 880px) {
      .hero {
        grid-template-columns: 1fr;
      }

      .shell {
        width: min(100% - 20px, 1120px);
        padding-top: 20px;
      }

      .hero__copy,
      .hero__panel,
      .workspace {
        border-radius: 22px;
      }
    }
  `]
})
export class AppComponent {
  private readonly personaService = inject(PersonaService);

  persona: Persona | undefined;
  loading = false;
  error: string | null = null;
  searched = false;

  onSearch(criteria: { idType: string; idValue: string }): void {
    this.loading = true;
    this.error = null;
    this.searched = true;
    this.persona = undefined;

    this.personaService.buscarPersona(criteria.idType, criteria.idValue)
      .pipe(finalize(() => {
        this.loading = false;
      }))
      .subscribe({
        next: (persona) => {
          this.persona = persona;
        },
        error: (error: { status?: number; error?: { message?: string } }) => {
          this.error = this.resolveError(error);
        }
      });
  }

  onClear(): void {
    this.persona = undefined;
    this.error = null;
    this.loading = false;
    this.searched = false;
  }

  private resolveError(error: { status?: number; error?: { message?: string } }): string {
    if (error.status === 404) {
      return 'No se encontro una persona con esos datos.';
    }

    if (error.status === 400) {
      return error.error?.message ?? 'La consulta enviada no es valida.';
    }

    if (error.status === 0 || error.status === 503) {
      return 'No fue posible conectar con el middle en http://localhost:3000.';
    }

    return 'Ocurrio un error inesperado al consultar personas.';
  }
}