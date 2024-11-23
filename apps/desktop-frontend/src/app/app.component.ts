import { Component } from '@angular/core';
import { RouterModule } from '@angular/router';
import { SharedUiComponent } from '@notecraftr/shared-ui';
import { PlaygroundComponent } from '@notecraftr/note-buildr';

@Component({
  standalone: true,
  imports: [ RouterModule, SharedUiComponent, PlaygroundComponent],
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  title = 'desktop-frontend';
}
