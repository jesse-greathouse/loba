import { ComponentFixture, TestBed, waitForAsync } from '@angular/core/testing';

import { RemoveKeyConfirmComponent } from './remove-key-confirm.component';

describe('RemoveKeyConfirmComponent', () => {
  let component: RemoveKeyConfirmComponent;
  let fixture: ComponentFixture<RemoveKeyConfirmComponent>;

  beforeEach(waitForAsync(() => {
    TestBed.configureTestingModule({
      declarations: [ RemoveKeyConfirmComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(RemoveKeyConfirmComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
