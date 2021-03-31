import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RemoveUserConfirmComponent } from './remove-user-confirm.component';

describe('RemoveUserConfirmComponent', () => {
  let component: RemoveUserConfirmComponent;
  let fixture: ComponentFixture<RemoveUserConfirmComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ RemoveUserConfirmComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(RemoveUserConfirmComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
