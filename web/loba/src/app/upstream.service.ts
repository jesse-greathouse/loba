import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { BaseService } from './base.service';
import { MessageService } from './message.service';
import { Upstream } from './upstream';

@Injectable({
  providedIn: 'root'
})
export class UpstreamService extends BaseService {

  constructor(
    protected http: HttpClient,
    protected messageService: MessageService) { 
      super('upstream', http, messageService);
  }

  getUpstreams(): Observable<Upstream[]> {
    return this.getAll();
  }

  /** GET upstream by id. Will 404 if id not found */
  getUpstream(id: number): Observable<Upstream> {
    return this.get(id);
  }

  /** PUT: update the upstream */
  updateUpstream(upstream: Upstream): Observable<any> {
    return this.update(upstream);
  }

  /** POST: add a new upstream */
  addUpstream(upstream: Upstream): Observable<Upstream> {
    return this.add(upstream);
  }

  /** DELETE: delete the upstream from the server */
  deleteUpstream(upstream: Upstream | number): Observable<Upstream> {
    return this.delete(upstream);
  }
}
