import { ComponentFixture, TestBed, waitForAsync } from '@angular/core/testing';

import { RemoveCertificateConfirmComponent } from './remove-certificate-confirm.component';

describe('RemoveCertificateConfirmComponent', () => {
  let component: RemoveCertificateConfirmComponent;
  let fixture: ComponentFixture<RemoveCertificateConfirmComponent>;

  beforeEach(waitForAsync(() => {
    TestBed.configureTestingModule({
      declarations: [ RemoveCertificateConfirmComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(RemoveCertificateConfirmComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
