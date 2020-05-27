import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';

import { BaseService } from './base.service';
import { MessageService } from './message.service';
import { Site } from './site';

@Injectable({
  providedIn: 'root'
})
export class SiteService extends BaseService {

  constructor(
      protected http: HttpClient,
      protected messageService: MessageService) {
        super('site', http, messageService);
  }

  getSites(): Observable<Site[]> {
    return this.getAll();
  }

  /** GET site by domain. Will 404 if id not found */
  getSiteByDomain(domain: string): Observable<Site> {
    const url = `${this.apiUrl}?domain=${domain}`;
    return this.http.get<Site>(url).pipe(
      tap(_ => this.log(`fetched site domain: ${domain}`, false)),
      map((resp: any) => {
        return resp.data;
      }),
      catchError(this.handleError<Site>(`getSiteByDomain: ${domain}`))
    );
  }

  /** GET site by id. Will 404 if id not found */
  getSite(id: number): Observable<Site> {
    return this.get(id);
  }

  /** PUT: update the site */
  updateSite(site: Site): Observable<any> {
    return this.update(site);
  }

  /** POST: add a new site */
  addSite(site: Site): Observable<Site> {
    return this.add(site);
  }

  /** DELETE: delete the site from the server */
  deleteSite(site: Site | number): Observable<Site> {
    return this.delete(site);
  }
}
