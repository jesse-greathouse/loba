import { TestBed } from '@angular/core/testing';

import { RequireAuthenticationGuard } from './require-authentication.guard';

describe('RequireAuthenticationGuard', () => {
  let guard: RequireAuthenticationGuard;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    guard = TestBed.inject(RequireAuthenticationGuard);
  });

  it('should be created', () => {
    expect(guard).toBeTruthy();
  });
});
