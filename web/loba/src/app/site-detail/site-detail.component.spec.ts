import { ComponentFixture, TestBed, waitForAsync } from '@angular/core/testing';

import { SiteDetailComponent } from './site-detail.component';

describe('SiteDetailComponent', () => {
  let component: SiteDetailComponent;
  let fixture: ComponentFixture<SiteDetailComponent>;

  beforeEach(waitForAsync(() => {
    TestBed.configureTestingModule({
      declarations: [ SiteDetailComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(SiteDetailComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
