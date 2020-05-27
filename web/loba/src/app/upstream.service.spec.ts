import { TestBed } from '@angular/core/testing';

import { UpstreamService } from './upstream.service';

describe('UpstreamService', () => {
  let service: UpstreamService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(UpstreamService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
