import { TestBed } from '@angular/core/testing';

import { RequireAdminGuard } from './require-admin.guard';

describe('RequireAdminGuard', () => {
  let guard: RequireAdminGuard;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    guard = TestBed.inject(RequireAdminGuard);
  });

  it('should be created', () => {
    expect(guard).toBeTruthy();
  });
});
