import { ComponentFixture, TestBed, waitForAsync } from '@angular/core/testing';

import { RemoveSiteConfirmComponent } from './remove-site-confirm.component';

describe('RemoveSiteConfirmComponent', () => {
  let component: RemoveSiteConfirmComponent;
  let fixture: ComponentFixture<RemoveSiteConfirmComponent>;

  beforeEach(waitForAsync(() => {
    TestBed.configureTestingModule({
      declarations: [ RemoveSiteConfirmComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(RemoveSiteConfirmComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
