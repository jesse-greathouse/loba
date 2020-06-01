import { Injectable, Inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';

import { MessageService } from './message.service';
import { Transformable } from './transformable';

@Injectable({
  providedIn: 'root'
})
export abstract class BaseService implements Transformable {

  protected apiUrl: string;
  private capResourceName: string;

  httpOptions = {
    headers: new HttpHeaders({ 'Content-Type': 'application/json' })
  };

  constructor(
    @Inject(String) protected resourceName: string,
    protected http: HttpClient,
    protected messageService: MessageService) {
      this.apiUrl = 'api/' + this.resourceName;
      this.capResourceName = this.resourceName[0].toUpperCase() + this.resourceName.slice(1);
  }

  protected getAll(): Observable<any[]> {
    return this.http.get<any[]>(this.apiUrl).pipe(
      // tap(_ => this.log('fetched obs')),
      map((resp: any) => {
        return resp.data;
      }),
      catchError(this.handleError<any[]>(`get${this.capResourceName}s`, []))
    );
  }

  /** GET object by id. Will 404 if id not found */
  protected get(id: number): Observable<any> {
    const url = `${this.apiUrl}/${id}`;
    return this.http.get<any>(url).pipe(
      tap(_ => this.log(`fetched ${this.resourceName} id: ${id}`)),
      map((resp: any) => {
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`get${this.capResourceName}: ${id}`))
    );
  }

  /** PUT: update the object */
  protected update(ob: any): Observable<any> {
    const url = `${this.apiUrl}/${ob.id}`;
    return this.http.put(url, ob, this.httpOptions).pipe(
      map((resp: any) => {
        this.log(resp.meta.message, 'success');
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`update${this.capResourceName}`))
    );
  }

  /** POST: add a new object */
  protected add(ob: any): Observable<any> {
    return this.http.post<any>(this.apiUrl, ob, this.httpOptions).pipe(
      map((resp: any) => {
        this.log(resp.meta.message, 'success');
        return this.transform(resp.data);
      }),
      catchError(this.handleError<any>(`add${this.capResourceName}`))
    );
  }

  /** DELETE: delete the object from the server */
  delete(ob: any | number): Observable<any> {
    const id = typeof ob === 'number' ? ob : ob.id;
    const url = `${this.apiUrl}/${id}`;

    return this.http.delete<any>(url, this.httpOptions).pipe(
      tap(_ => this.log(`deleted ${this.resourceName} with id: ${id}`)),
      catchError(this.handleError<any>(`delete${this.capResourceName}`))
    );
  }

  transform(data: any): any {
    return this.clean(data);
  }

  protected clean(data: any) {
    if (data === null || typeof(data) !== "object") return data;

    Object.keys(data).forEach((key, i) => {
      if (typeof(data[key]) === "object") {
        data[key] = this.clean(data[key]);
      } else {
        if (data[key] === "NULL") data[key] = null;
      }
    })
    return data;
  }

  /** Log a SiteService message with the MessageService */
  protected log(message: string, level: string|false = false) {
    this.messageService.add(message, level, `${this.capResourceName}Service: `);
  }

  /**
   * Handle Http operation that failed.
   * Let the app continue.
   * @param operation - name of the operation that failed
   * @param result - optional value to return as the observable result
   */
  protected handleError<T>(operation = 'operation', result?: T) {
    return (error: any): Observable<T> => {
      const message = (typeof error.error !== "undefined"  && typeof error.error.meta !== "undefined") 
        ? error.error.meta.message : error.message;

      // TODO: send the error to remote logging infrastructure
      console.error(error);

      this.log(`${operation} failed -- ${message}`, 'danger');

      // Let the app keep running by returning an empty result.
      return of(result as T);
    };
  }
}
