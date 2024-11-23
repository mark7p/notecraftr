import { AfterViewInit, Component, ElementRef, EventEmitter, HostListener, OnInit, viewChild } from '@angular/core';
import { Observable } from 'rxjs';

@Component({
  selector: 'lib-note-buildr-playground',
  standalone: true,
  imports: [],
  templateUrl: './playground.component.html',
  styleUrl: './playground.component.scss'
})
export class PlaygroundComponent implements OnInit {
  gdFrame = viewChild.required<ElementRef<HTMLIFrameElement>>('gdframe');

  ngOnInit() {
    console.log(1)
    window.addEventListener('godotMessage', (args) => {
      console.log('Message received from Godot!', args);
    });
  }

  checkwindow(){
    // console.log(this.gdFrame().nativeElement.contentWindow)
    const godotWindow: any = this.gdFrame().nativeElement.contentWindow;
    // (window as any).Godot = godotWindow.Godot
    // (window as any).Engine = godotWindow.Engine
    console.log(godotWindow)
  }
  
  callGodotFunction(message: string) {
    const godotWindow: any = this.gdFrame().nativeElement.contentWindow;
    godotWindow.frontend_message = JSON.stringify({ detail: message });
    godotWindow.dispatchEvent(new CustomEvent('frontendMessage', { detail: message }));
  }


  
  
}