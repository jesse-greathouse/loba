import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { RemoveSiteConfirmComponent } from './remove-site-confirm.component';

describe('RemoveSiteConfirmComponent', () => {
  let component: RemoveSiteConfirmComponent;
  let fixture: ComponentFixture<RemoveSiteConfirmComponent>;

  beforeEach(async(() => {
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
