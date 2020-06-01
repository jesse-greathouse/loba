import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { RemoveServerConfirmComponent } from './remove-server-confirm.component';

describe('RemoveServerConfirmComponent', () => {
  let component: RemoveServerConfirmComponent;
  let fixture: ComponentFixture<RemoveServerConfirmComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ RemoveServerConfirmComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(RemoveServerConfirmComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
