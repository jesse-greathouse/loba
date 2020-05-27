import { TestBed } from '@angular/core/testing';

import { MethodService } from './method.service';

describe('MethodService', () => {
  let service: MethodService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(MethodService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
