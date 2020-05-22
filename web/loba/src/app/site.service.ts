import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';

import { MessageService } from './message.service';
import { Site } from './site';

@Injectable({
  providedIn: 'root'
})

export class SiteService {

  private siteUrl = 'api/site';

  httpOptions = {
    headers: new HttpHeaders({ 'Content-Type': 'application/json' })
  };

  constructor(
      private http: HttpClient,
      private messageService: MessageService) { 
  }

  /** Log a SiteService message with the MessageService */
  private log(message: string) {
    this.messageService.add(`SiteService: ${message}`);
  }

  getSites(): Observable<Site[]> {
    return this.http.get<Site[]>(this.siteUrl).pipe(
      tap(_ => this.log('fetched sites')),
      map((resp: any) => {
        return resp.data;
      }),
      catchError(this.handleError<Site[]>('getSites', []))
    );
  }

  /** GET site by domain. Will 404 if id not found */
  getSiteByDomain(domain: string): Observable<Site> {
    const url = `${this.siteUrl}?domain=${domain}`;
    return this.http.get<Site>(url).pipe(
      tap(_ => this.log(`fetched site domain: ${domain}`)),
      map((resp: any) => {
        return resp.data;
      }),
      catchError(this.handleError<Site>(`getSiteByDomain: ${domain}`))
    );
  }

  /** GET site by id. Will 404 if id not found */
  getSite(id: number): Observable<Site> {
    const url = `${this.siteUrl}/${id}`;
    return this.http.get<Site>(url).pipe(
      tap(_ => this.log(`fetched site id: ${id}`)),
      map((resp: any) => {
        return resp.data;
      }),
      catchError(this.handleError<Site>(`getSite: ${id}`))
    );
  }

  /** PUT: update the site */
  updateSite(site: Site): Observable<any> {
    const url = `${this.siteUrl}/${site.id}`;
    return this.http.put(url, site, this.httpOptions).pipe(
      tap(_ => this.log(`updated site: ${site.domain}`)),
      map((resp: any) => {
        return resp.data;
      }),
      catchError(this.handleError<any>('updateSite'))
    );
  }

  /** POST: add a new site */
  addSite(site: Site): Observable<Site> {
    return this.http.post<Site>(this.siteUrl, site, this.httpOptions).pipe(
      tap((newSite: Site) => this.log(`added site: ${newSite.domain}`)),
      map((resp: any) => {
        return resp.data;
      }),
      catchError(this.handleError<Site>('addSite'))
    );
  }

  /** DELETE: delete the site from the server */
  deleteSite(site: Site | number): Observable<Site> {
    const id = typeof site === 'number' ? site : site.id;
    const url = `${this.siteUrl}/${id}`;

    return this.http.delete<Site>(url, this.httpOptions).pipe(
      tap(_ => this.log(`deleted site with id: ${id}`)),
      catchError(this.handleError<Site>('deleteSite'))
    );
  }

  /**
   * Handle Http operation that failed.
   * Let the app continue.
   * @param operation - name of the operation that failed
   * @param result - optional value to return as the observable result
   */
  private handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {

      // TODO: send the error to remote logging infrastructure
      console.error(error); // log to console instead

      // TODO: better job of transforming error for user consumption
      this.log(`${operation} failed: ${error.message}`);

      // Let the app keep running by returning an empty result.
      return of(result as T);
    };
  }
}
