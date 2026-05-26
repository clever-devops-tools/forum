import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { Persona } from '../models/persona.model';

@Component({
  selector: 'app-persona-detail',
  standalone: true,
  imports: [CommonModule],
  template: `
    <section class="detail-card" *ngIf="persona as current; else emptyState">
      <div class="detail-card__header">
        <div>
          <p class="eyebrow">Resultado</p>
          <h2>{{ current.fullName }}</h2>
          <p class="summary">{{ current.idType }} {{ current.idValue }}</p>
        </div>
        <span class="badge">ID {{ current.id }}</span>
      </div>

      <dl class="detail-grid">
        <div>
          <dt>Nombre completo</dt>
          <dd>{{ current.fullName }}</dd>
        </div>
        <div>
          <dt>Identificacion</dt>
          <dd>{{ current.idType }} {{ current.idValue }}</dd>
        </div>
        <div>
          <dt>Email</dt>
          <dd>{{ current.email || 'Sin dato' }}</dd>
        </div>
        <div>
          <dt>Telefono</dt>
          <dd>{{ current.phone || 'Sin dato' }}</dd>
        </div>
        <div>
          <dt>Fecha de nacimiento</dt>
          <dd>{{ formatBirthDate(current.birthDate) }}</dd>
        </div>
        <div>
          <dt>Edad</dt>
          <dd>{{ calculateAge(current.birthDate) }}</dd>
        </div>
      </dl>
    </section>

    <ng-template #emptyState>
      <section class="detail-card detail-card--empty">
        <p class="eyebrow">Sin resultados</p>
        <h2>No hay una persona para mostrar</h2>
        <p class="summary">Realiza una busqueda para ver la informacion detallada de la persona encontrada.</p>
      </section>
    </ng-template>
  `,
  styles: [`
    .detail-card {
      padding: 24px;
      border-radius: 24px;
      border: 1px solid var(--line);
      background: linear-gradient(180deg, rgba(255, 250, 242, 0.98), rgba(239, 227, 210, 0.68));
    }

    .detail-card__header {
      display: flex;
      justify-content: space-between;
      gap: 16px;
      align-items: start;
      margin-bottom: 24px;
      flex-wrap: wrap;
    }

    .eyebrow {
      margin: 0 0 8px;
      color: var(--brand);
      text-transform: uppercase;
      letter-spacing: 0.12em;
      font-size: 0.78rem;
      font-family: 'Space Grotesk', sans-serif;
    }

    h2 {
      margin: 0;
      font-size: clamp(1.9rem, 4vw, 3rem);
      font-family: 'Space Grotesk', sans-serif;
      line-height: 1;
    }

    .summary {
      margin: 10px 0 0;
      color: var(--muted);
      font-size: 1rem;
    }

    .badge {
      padding: 10px 14px;
      border-radius: 999px;
      background: rgba(15, 118, 110, 0.12);
      color: var(--brand-strong);
      font-weight: 700;
    }

    .detail-grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 14px;
      margin: 0;
    }

    .detail-grid div {
      padding: 16px;
      border-radius: 18px;
      background: rgba(255, 255, 255, 0.76);
      border: 1px solid rgba(92, 61, 46, 0.08);
    }

    dt {
      margin-bottom: 8px;
      color: var(--muted);
      font-size: 0.92rem;
    }

    dd {
      margin: 0;
      font-size: 1.1rem;
      font-weight: 700;
      color: var(--text);
    }

    .detail-card--empty {
      display: grid;
      gap: 8px;
      text-align: left;
      background: linear-gradient(180deg, rgba(255, 250, 242, 0.9), rgba(244, 239, 230, 0.92));
    }

    @media (max-width: 720px) {
      .detail-card__header,
      .detail-grid {
        grid-template-columns: 1fr;
        display: grid;
      }
    }
  `]
})
export class PersonaDetailComponent {
  @Input() persona?: Persona;

  formatBirthDate(birthDate?: string): string {
    if (!birthDate) {
      return 'Sin dato';
    }

    const date = new Date(`${birthDate}T00:00:00`);
    if (Number.isNaN(date.getTime())) {
      return birthDate;
    }

    return new Intl.DateTimeFormat('es-AR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    }).format(date);
  }

  calculateAge(birthDate?: string): string {
    if (!birthDate) {
      return 'Sin dato';
    }

    const date = new Date(`${birthDate}T00:00:00`);
    if (Number.isNaN(date.getTime())) {
      return 'Sin dato';
    }

    const today = new Date();
    let age = today.getFullYear() - date.getFullYear();
    const monthDiff = today.getMonth() - date.getMonth();
    const dayDiff = today.getDate() - date.getDate();

    if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
      age -= 1;
    }

    return `${age} anios`;
  }
}
