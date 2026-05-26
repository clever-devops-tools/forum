import { Component, EventEmitter, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-search-form',
  standalone: true,
  imports: [FormsModule],
  template: `
    <section class="search-card">
      <div>
        <p class="label">Busqueda por identidad</p>
        <h2>Consulta una persona</h2>
      </div>

      <form class="search-grid" (ngSubmit)="onSearch()">
        <label>
          <span>Tipo de identificacion</span>
          <select name="idType" [(ngModel)]="idType">
            <option value="DNI">DNI</option>
            <option value="RUT">RUT</option>
            <option value="PASSPORT">Pasaporte</option>
          </select>
        </label>

        <label>
          <span>Numero de identificacion</span>
          <input
            type="text"
            name="idValue"
            [(ngModel)]="idValue"
            placeholder="Ingresa el identificador"
            autocomplete="off"
          />
        </label>

        <div class="actions">
          <button type="submit" [disabled]="!idValue.trim()">Buscar</button>
          <button type="button" class="ghost" (click)="onClear()">Limpiar</button>
        </div>
      </form>
    </section>
  `,
  styles: [`
    .search-card {
      display: grid;
      gap: 20px;
      padding: 24px;
      border-radius: 24px;
      border: 1px solid var(--line);
      background: var(--surface-strong);
    }

    .label {
      margin: 0 0 8px;
      color: var(--brand);
      text-transform: uppercase;
      letter-spacing: 0.12em;
      font-size: 0.78rem;
      font-family: 'Space Grotesk', sans-serif;
    }

    h2 {
      margin: 0;
      font-size: 1.7rem;
      font-family: 'Space Grotesk', sans-serif;
    }

    .search-grid {
      display: grid;
      grid-template-columns: 180px minmax(0, 1fr) auto;
      gap: 14px;
      align-items: end;
    }

    label {
      display: grid;
      gap: 8px;
      color: var(--muted);
      font-weight: 600;
    }

    select,
    input,
    button {
      min-height: 52px;
      border-radius: 16px;
      border: 1px solid var(--line);
    }

    select,
    input {
      width: 100%;
      padding: 0 14px;
      background: #fff;
      color: var(--text);
    }

    input::placeholder {
      color: #9f8f86;
    }

    .actions {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }

    button {
      padding: 0 18px;
      cursor: pointer;
      background: var(--brand);
      color: #fff;
      font-weight: 700;
      transition: transform 180ms ease, background 180ms ease;
    }

    button:hover {
      transform: translateY(-1px);
      background: var(--brand-strong);
    }

    button:disabled {
      cursor: not-allowed;
      opacity: 0.55;
      transform: none;
    }

    .ghost {
      background: transparent;
      color: var(--text);
    }

    @media (max-width: 880px) {
      .search-grid {
        grid-template-columns: 1fr;
      }

      .actions {
        width: 100%;
      }

      button {
        flex: 1 1 140px;
      }
    }
  `]
})
export class SearchFormComponent {
  @Output() search = new EventEmitter<{ idType: string; idValue: string }>();
  @Output() clear = new EventEmitter<void>();

  idType = 'DNI';
  idValue = '';

  onSearch(): void {
    this.search.emit({ idType: this.idType, idValue: this.idValue.trim() });
  }

  onClear(): void {
    this.idType = 'DNI';
    this.idValue = '';
    this.clear.emit();
  }
}
