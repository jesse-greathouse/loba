import { ComponentFixture, TestBed, waitForAsync } from '@angular/core/testing';

import { SelfSignedConfirmComponent } from './self-signed-confirm.component';

describe('SelfSignedConfirmComponent', () => {
  let component: SelfSignedConfirmComponent;
  let fixture: ComponentFixture<SelfSignedConfirmComponent>;

  beforeEach(waitForAsync(() => {
    TestBed.configureTestingModule({
      declarations: [ SelfSignedConfirmComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(SelfSignedConfirmComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
