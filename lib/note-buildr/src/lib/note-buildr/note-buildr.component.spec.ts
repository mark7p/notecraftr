import { ComponentFixture, TestBed } from '@angular/core/testing';
import { NoteBuildrComponent } from './note-buildr.component';

describe('NoteBuildrComponent', () => {
  let component: NoteBuildrComponent;
  let fixture: ComponentFixture<NoteBuildrComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NoteBuildrComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(NoteBuildrComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
